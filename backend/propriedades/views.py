from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.decorators import action, api_view, permission_classes
from django.db.models import Q
from .models import Propriedade, FotoPropriedade, Comentario
from .serializers import PropriedadeSerializer, FotoPropriedadeSerializer, ComentarioSerializer
from .models import ContratoSolicitacao
from .serializers import ContratoSolicitacaoSerializer
from .permissions import IsOwnerOrReadOnly, IsAuthorOrReadOnly
from .pagination import StandardResultsSetPagination
from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from rest_framework.permissions import IsAuthenticated
from django.conf import settings
import logging
from rest_framework.permissions import AllowAny
from notificacoes.models import Notificacao
from notificacoes.utils import send_fcm_to_user
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
import mercadopago
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.http import HttpResponse

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_IMAGE_SIZE_BYTES = 5 * 1024 * 1024  # 5MB

class PropriedadeViewSet(viewsets.ModelViewSet):
    queryset = Propriedade.objects.all()
    serializer_class = PropriedadeSerializer
    pagination_class = StandardResultsSetPagination
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]
    
    def perform_create(self, serializer):
        serializer.save(proprietario=self.request.user)
    
    def get_queryset(self):
        queryset = Propriedade.objects.all()

        params = self.request.query_params

        # Busca genérica por vários campos
        q = params.get('q')
        if q is not None:
            sq = str(q).strip()
            if sq:
                queryset = queryset.filter(
                    Q(titulo__icontains=sq) |
                    Q(descricao__icontains=sq) |
                    Q(cidade__icontains=sq) |
                    Q(estado__icontains=sq) |
                    Q(tipo__icontains=sq) |
                    Q(proprietario__username__icontains=sq) |
                    Q(proprietario__email__icontains=sq)
                )

        # Filtrar por tipo de propriedade (aceita sinônimos e 'tudo/all')
        tipo = params.get('tipo')
        if tipo:
            st = str(tipo).strip().lower()
            if st not in {'tudo', 'todos', 'all'}:
                map_tipo = {
                    'studio': 'kitnet',
                    'apartment': 'apartamento',
                    'apartamento': 'apartamento',
                    'kitnet': 'kitnet',
                    'house': 'casa',
                    'casa': 'casa',
                    'republica': 'republica',
                }
                queryset = queryset.filter(tipo=map_tipo.get(st, st))

        # Filtrar por faixa de preço (ignorar valores vazios)
        preco_min = params.get('preco_min')
        if preco_min:
            queryset = queryset.filter(preco__gte=preco_min)

        preco_max = params.get('preco_max')
        if preco_max:
            queryset = queryset.filter(preco__lte=preco_max)

        # Filtrar por cidade
        cidade = params.get('cidade')
        if cidade:
            sc = str(cidade).strip()
            if sc:
                queryset = queryset.filter(cidade__icontains=sc)

        # Filtrar por estado (UF)
        estado = params.get('estado')
        if estado:
            se = str(estado).strip()
            if se:
                queryset = queryset.filter(estado__iexact=se)

        # Filtrar por quartos (min/max)
        quartos_min = params.get('quartos_min')
        if quartos_min:
            queryset = queryset.filter(quartos__gte=quartos_min)
        quartos_max = params.get('quartos_max')
        if quartos_max:
            queryset = queryset.filter(quartos__lte=quartos_max)

        # Filtros booleanos (ignorar valores vazios/indefinidos)
        def parse_bool(val):
            return str(val).lower() in {"true", "1", "yes", "sim"}

        for field in ["mobiliado", "aceita_pets", "internet", "estacionamento"]:
            val = params.get(field)
            # Ignorar quando o parâmetro vier vazio ou como 'null'/'undefined'
            if val is None:
                continue
            sval = str(val).strip().lower()
            if sval in {"", "null", "undefined"}:
                continue
            queryset = queryset.filter(**{field: parse_bool(val)})

        # Filtrar por proprietário específico (para "Ver anúncios" no chat)
        owner = params.get('owner') or params.get('proprietario') or params.get('owner_id')
        if owner:
            queryset = queryset.filter(proprietario_id=owner)

        # Ordenação com whitelist
        ordering = params.get('ordering')
        if ordering:
            allowed = {"preco", "-preco", "data_criacao", "-data_criacao"}
            if ordering in allowed:
                queryset = queryset.order_by(ordering)
        else:
            queryset = queryset.order_by('-data_criacao')

        return queryset
    
    @action(detail=True, methods=['post'], parser_classes=[MultiPartParser, FormParser])
    def upload_fotos(self, request, pk=None):
        propriedade = self.get_object()
        
        # Verificar se o usuário é o proprietário
        if propriedade.proprietario != request.user:
            return Response(
                {"detail": "Você não tem permissão para adicionar fotos a esta propriedade."},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Processar as imagens enviadas
        imagens = request.FILES.getlist('imagens')
        principal = request.data.get('principal', None)
        
        # Sanitização: validar mimetype e tamanho
        erros = []
        for i, img in enumerate(imagens):
            ct = getattr(img, 'content_type', None)
            size = getattr(img, 'size', None)
            if ct not in ALLOWED_IMAGE_TYPES:
                erros.append({"index": i, "error": "Tipo de arquivo não permitido", "content_type": ct})
            if size is not None and size > MAX_IMAGE_SIZE_BYTES:
                erros.append({"index": i, "error": "Arquivo excede tamanho máximo de 5MB", "size": size})
        if erros:
            return Response({"detail": "Uploads inválidos", "errors": erros}, status=status.HTTP_400_BAD_REQUEST)

        fotos_salvas = []
        
        for i, img in enumerate(imagens):
            # Verificar se esta imagem deve ser a principal
            is_principal = str(i) == principal if principal else False
            
            # Se esta for marcada como principal, desmarcar as outras
            if is_principal:
                FotoPropriedade.objects.filter(propriedade=propriedade, principal=True).update(principal=False)
            
            # Criar a nova foto
            foto = FotoPropriedade.objects.create(
                propriedade=propriedade,
                imagem=img,
                principal=is_principal
            )
            fotos_salvas.append(foto)
        
        serializer = FotoPropriedadeSerializer(fotos_salvas, many=True)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=False, methods=['get'])
    def minhas_propriedades(self, request):
        propriedades = Propriedade.objects.filter(proprietario=request.user)
        serializer = self.get_serializer(propriedades, many=True)
        return Response(serializer.data)
    def update(self, request, *args, **kwargs):
        obj = self.get_object()
        self.check_object_permissions(request, obj)
        return super().update(request, *args, **kwargs)

    def partial_update(self, request, *args, **kwargs):
        obj = self.get_object()
        self.check_object_permissions(request, obj)
        return super().partial_update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        obj = self.get_object()
        self.check_object_permissions(request, obj)
        return super().destroy(request, *args, **kwargs)
    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def favoritar_propriedade(request, propriedade_id):
    propriedade = get_object_or_404(Propriedade, id=propriedade_id)
    
    if propriedade in request.user.propriedades_favoritas.all():
        propriedade.favoritos.remove(request.user)
        is_favorited = False
    else:
        propriedade.favoritos.add(request.user)
        is_favorited = True
        
    return Response({'status': 'sucesso', 'favorito': is_favorited})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def lista_favoritos(request):

    propriedades_favoritadas = request.user.propriedades_favoritas.all()
    
    serializer = PropriedadeSerializer(propriedades_favoritadas, many=True, context={'request': request})
    return Response(serializer.data)


class ComentarioViewSet(viewsets.ModelViewSet):
    queryset = Comentario.objects.all()
    serializer_class = ComentarioSerializer
    # permitir leitura pública (GET) mas exigir autenticação para criação/edição
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsAuthorOrReadOnly]

    def perform_create(self, serializer):
        serializer.save(autor=self.request.user)

    def get_queryset(self):
        imovel_id = self.request.query_params.get('imovel')
        qs = Comentario.objects.all()
        if imovel_id:
            qs = qs.filter(imovel_id=imovel_id)
        return qs


class ContratoSolicitacaoViewSet(viewsets.ModelViewSet):
    queryset = ContratoSolicitacao.objects.all()
    serializer_class = ContratoSolicitacaoSerializer
    # Accept JSON as well as multipart/form-data and form-encoded requests.
    parser_classes = [MultiPartParser, FormParser, JSONParser]
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        # proprietarios veem solicitações dos seus imóveis
        qs_owner = ContratoSolicitacao.objects.filter(imovel__proprietario=user)
        # solicitantes veem suas próprias solicitações
        qs_user = ContratoSolicitacao.objects.filter(solicitante=user)
        # unir (owner pode ser solicitante em casos, mas distinct)
        return (qs_owner | qs_user).distinct().order_by('-data_criacao')

    def perform_create(self, serializer):
        serializer.save(solicitante=self.request.user)

    @action(detail=True, methods=['post'])
    def set_status(self, request, pk=None):
        # Apenas o proprietário do imóvel pode alterar o status
        obj = self.get_object()
        user = request.user
        if obj.imovel.proprietario != user:
            return Response({'detail': 'Sem permissão.'}, status=status.HTTP_403_FORBIDDEN)

        status_val = request.data.get('status')
        if status_val not in dict(ContratoSolicitacao.STATUS_CHOICES):
            return Response({'detail': 'Status inválido.'}, status=status.HTTP_400_BAD_REQUEST)

        obj.status = status_val
        obj.resposta_do_proprietario = request.data.get('resposta_do_proprietario', obj.resposta_do_proprietario)
        obj.save()
        return Response(ContratoSolicitacaoSerializer(obj, context={'request': request}).data)

    @action(detail=True, methods=['post'], parser_classes=[MultiPartParser, FormParser, JSONParser])
    def upload_contrato(self, request, pk=None):
        """Allow the property owner to upload the final contract file for a solicitation.

        Expects multipart/form-data with a file field named 'contrato_final'. Optionally
        accepts 'status' to set the status (e.g., 'approved') and an optional 'resposta_do_proprietario'.
        Only the property owner may perform this action.
        """
        obj = self.get_object()
        user = request.user
        if obj.imovel.proprietario != user:
            return Response({'detail': 'Sem permissão.'}, status=status.HTTP_403_FORBIDDEN)

        # handle uploaded file
        uploaded = request.FILES.get('contrato_final')
        # Debug: if no file was provided, inform client
        if not uploaded and not request.data.get('status') and not request.data.get('resposta_do_proprietario'):
            return Response({'detail': 'Nenhum arquivo enviado (campo contrato_final).'}, status=status.HTTP_400_BAD_REQUEST)

        if uploaded:
            # simple debug log to help diagnose upload issues in dev
            try:
                print(f"upload_contrato: received file campo 'contrato_final' name={getattr(uploaded, 'name', None)} size={getattr(uploaded, 'size', None)} user={user.id}")
            except Exception:
                pass
            obj.contrato_final = uploaded

        status_val = request.data.get('status')
        if status_val:
            if status_val not in dict(ContratoSolicitacao.STATUS_CHOICES):
                return Response({'detail': 'Status inválido.'}, status=status.HTTP_400_BAD_REQUEST)
            obj.status = status_val

        obj.resposta_do_proprietario = request.data.get('resposta_do_proprietario', obj.resposta_do_proprietario)
        obj.save()
        return Response(ContratoSolicitacaoSerializer(obj, context={'request': request}).data)

    @action(detail=True, methods=['post'], parser_classes=[MultiPartParser, FormParser, JSONParser])
    def upload_contrato_assinado(self, request, pk=None):
        """Allow the solicitante (tenant) to upload a signed contract file.

        Expects multipart/form-data with a file field named 'contrato_assinado'.
        Only the original solicitante for this ContratoSolicitacao may upload here.
        """
        obj = self.get_object()
        user = request.user
        if obj.solicitante != user:
            return Response({'detail': 'Sem permissão.'}, status=status.HTTP_403_FORBIDDEN)

        uploaded = request.FILES.get('contrato_assinado')
        if not uploaded:
            return Response({'detail': 'Nenhum arquivo enviado (campo contrato_assinado).'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            print(f"upload_contrato_assinado: received file campo 'contrato_assinado' name={getattr(uploaded, 'name', None)} size={getattr(uploaded, 'size', None)} user={user.id}")
        except Exception:
            pass

        obj.contrato_assinado = uploaded
        # optionally the tenant might want to update a small message; accept it
        obj.resposta_do_proprietario = request.data.get('resposta_do_proprietario', obj.resposta_do_proprietario)
        obj.save()
        return Response(ContratoSolicitacaoSerializer(obj, context={'request': request}).data)

    @action(detail=True, methods=['post'])
    def create_stripe_checkout(self, request, pk=None):
        # Stripe integration was removed from this deployment. This endpoint is disabled.
        return Response({'detail': 'Stripe não está habilitado no servidor.'}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

    @action(detail=True, methods=['post'])
    def create_mercado_pago_preference(self, request, pk=None):
        """Create a Mercado Pago preference for paying the first rent of this contract.

        Returns preference id and init_point (checkout URL) on success.
        """
        obj = self.get_object()
        user = request.user
        if obj.solicitante != user:
            return Response({'detail': 'Sem permissão.'}, status=status.HTTP_403_FORBIDDEN)

        from django.conf import settings as djsettings
        if not djsettings.MERCADO_PAGO_ACCESS_TOKEN:
            return Response({'detail': 'Mercado Pago não configurado no servidor.'}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        try:
            price = float(obj.imovel.preco or 0)
        except Exception:
            price = 0.0

        if price <= 0:
            return Response({'detail': 'Valor do aluguel inválido para pagamento.'}, status=status.HTTP_400_BAD_REQUEST)

        mp = mercadopago.SDK(djsettings.MERCADO_PAGO_ACCESS_TOKEN)
        preference_data = {
            'items': [
                {
                    'title': f'Primeiro aluguel - {obj.imovel.titulo}',
                    'quantity': 1,
                    'unit_price': price,
                }
            ],
            'back_urls': {
                'success': f"{djsettings.FRONTEND_URL}/contratos/{obj.id}/pago?status=success",
                'failure': f"{djsettings.FRONTEND_URL}/contratos/{obj.id}/pago?status=failure",
                'pending': f"{djsettings.FRONTEND_URL}/contratos/{obj.id}/pago?status=pending",
            },
            'auto_return': 'approved',
            'metadata': {'contract_id': str(obj.id)},
        }

        try:
            pref = mp.preference().create(preference_data)
            response = pref.get('response', {}) if isinstance(pref, dict) else {}
            return Response({'preference_id': response.get('id'), 'init_point': response.get('init_point')})
        except Exception as e:
            try:
                print('Mercado Pago preference error', repr(e))
            except Exception:
                pass
            if getattr(djsettings, 'DEBUG', False):
                return Response({'detail': 'Erro ao criar preferência Mercado Pago.', 'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            return Response({'detail': 'Erro ao criar preferência Mercado Pago.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=True, methods=['post'])
    def confirm_payment(self, request, pk=None):
        """Mark the first rent as paid for this contract.

        This endpoint is intended for server-side/webhook use. Authorization rules:
        - If the caller is an authenticated user and is the property owner, allow.
        - Otherwise, if a PAYMENT_WEBHOOK_SECRET is configured, the caller may
          supply it in the POST body as {'secret': '<secret>'} to authorize.

        Request body: { 'value': true|false } optional (defaults to true),
        or { 'secret': '<secret>' } when called by a webhook.
        """
        obj = self.get_object()
        user = request.user if request.user and request.user.is_authenticated else None

        # Owner or the original solicitante may confirm payment (solicitante used for simulated flows)
        if user and (obj.imovel.proprietario == user or obj.solicitante == user):
            authorized = True
        else:
            authorized = False

        # Check webhook secret from settings
        from django.conf import settings as djsettings
        secret = request.data.get('secret')
        if not authorized and djsettings.PAYMENT_WEBHOOK_SECRET and secret and secret == djsettings.PAYMENT_WEBHOOK_SECRET:
            authorized = True

        if not authorized:
            return Response({'detail': 'Sem permissão para confirmar pagamento.'}, status=status.HTTP_403_FORBIDDEN)

        # get desired value (default true)
        v = request.data.get('value', True)
        if isinstance(v, str):
            v = v.lower() in ('1', 'true', 'yes')
        else:
            v = bool(v)

        obj.primeiro_aluguel_pago = v
        # If payment confirmed, mark contract status as 'paid' for clarity
        if v:
            try:
                # only set if the choice exists (we added 'paid' to STATUS_CHOICES)
                obj.status = 'paid'
            except Exception:
                pass
        obj.save()

        # notify proprietário and solicitante
        try:
            owner = obj.imovel.proprietario
            # create a Notificacao for the owner
            owner_notif = Notificacao.objects.create(usuario=owner, imovel=obj.imovel, mensagem=f'Pagamento do primeiro aluguel para a solicitação #{obj.id} foi confirmado.')
            try:
                # send FCM (title, body)
                send_fcm_to_user(owner, 'Pagamento confirmado', f'Contrato #{obj.id} — pagamento confirmado.')
            except Exception:
                pass
            # push via websocket (channels) to owner group
            try:
                channel_layer = get_channel_layer()
                payload = {
                    'id': owner_notif.id,
                    'mensagem': owner_notif.mensagem,
                    'imovel': obj.imovel.id if obj.imovel else None,
                    'lida': owner_notif.lida,
                    'data_criacao': owner_notif.data_criacao.isoformat(),
                }
                async_to_sync(channel_layer.group_send)(f'user_{owner.id}', {
                    'type': 'notification',
                    'notification': payload,
                })
            except Exception:
                pass
        except Exception:
            pass

        try:
            tenant = obj.solicitante
            tenant_notif = Notificacao.objects.create(usuario=tenant, imovel=obj.imovel, mensagem=f'Seu pagamento para a solicitação #{obj.id} foi recebido.')
            try:
                send_fcm_to_user(tenant, 'Pagamento recebido', f'Seu pagamento para o contrato #{obj.id} foi confirmado.')
            except Exception:
                pass
            # push via websocket to tenant
            try:
                channel_layer = get_channel_layer()
                payload = {
                    'id': tenant_notif.id,
                    'mensagem': tenant_notif.mensagem,
                    'imovel': obj.imovel.id if obj.imovel else None,
                    'lida': tenant_notif.lida,
                    'data_criacao': tenant_notif.data_criacao.isoformat(),
                }
                async_to_sync(channel_layer.group_send)(f'user_{tenant.id}', {
                    'type': 'notification',
                    'notification': payload,
                })
            except Exception:
                pass
        except Exception:
            pass

        return Response(ContratoSolicitacaoSerializer(obj, context={'request': request}).data)

    # Mercado Pago preference endpoint has been removed per project configuration.
    # Re-enable by implementing provider-specific logic in a dedicated module.
    # Payment endpoints (Mercado Pago / Stripe) have been removed per project configuration.
    # If you need to re-enable payments, implement provider-specific endpoints in a
    # dedicated module and add the necessary settings and secrets securely.


@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def stripe_webhook(request):
    # Stripe webhook handler removed — return 404 to indicate unavailable
    return HttpResponse(status=404)