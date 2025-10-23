from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.decorators import action, api_view, permission_classes
from django.db.models import Q
from .models import Propriedade, FotoPropriedade, Comentario
from .serializers import PropriedadeSerializer, FotoPropriedadeSerializer, ComentarioSerializer
from .permissions import IsOwnerOrReadOnly, IsAuthorOrReadOnly
from .pagination import StandardResultsSetPagination
from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from rest_framework.permissions import IsAuthenticated

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