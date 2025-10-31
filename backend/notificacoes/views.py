from django.shortcuts import render


from rest_framework import viewsets, permissions, status
from .models import Notificacao
from .serializers import NotificacaoSerializer
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from .serializers import DeviceSerializer
from .models import Device

class NotificacaoViewSet(viewsets.ModelViewSet):
    """
    Este endpoint lista, recupera e deleta as notificações
    APENAS para o usuário autenticado.
    """
    serializer_class = NotificacaoSerializer
    permission_classes = [permissions.IsAuthenticated] # Exige que o usuário esteja logado

    def get_queryset(self):
        # Filtra o queryset para retornar apenas
        # notificações do usuário logado
        return Notificacao.objects.filter(usuario=self.request.user)
    
    @action(detail=False, methods=['get'])
    def contagem_nao_lida(self, request):
        """
        Retorna apenas a contagem de notificações não lidas
        para o usuário logado.
        """
        # Pega o queryset (que já está filtrado pelo get_queryset)
        queryset = self.get_queryset()
        
        # Filtra mais uma vez por 'lida=False' e pega a contagem
        contagem = queryset.filter(lida=False).count()
        
        # Retorna um JSON simples
        return Response({'count': contagem})
    
    @action(detail=False, methods=['post']) # Usamos POST porque altera dados
    def marcar_todas_como_lidas(self, request):
        """
        Marca todas as notificações não lidas do usuário como lidas.
        """
        # Pega o queryset (já filtrado para o usuário logado)
        queryset = self.get_queryset()
        
        # Filtra pelas não lidas e atualiza o campo 'lida' para True
        queryset.filter(lida=False).update(lida=True)
        
        # Retorna uma resposta de sucesso sem conteúdo
        return Response(status=status.HTTP_204_NO_CONTENT)
    
    @action(detail=False, methods=['delete'])
    def excluir_todas(self, request):
        """
        Exclui todas as notificações do usuário logado.
        """
        # Pega o queryset (já filtrado para o usuário logado)
        queryset = self.get_queryset()
        
        # Deleta todas as notificações do usuário
        count = queryset.count()
        queryset.delete()
        
        # Retorna uma resposta de sucesso
        return Response({'deleted': count}, status=status.HTTP_200_OK)    


class RegisterDeviceView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        token = request.data.get('token') or request.data.get('registration_id')
        platform = request.data.get('platform')
        if not token:
            return Response({'detail': 'token required'}, status=status.HTTP_400_BAD_REQUEST)
        device, created = Device.objects.get_or_create(usuario=request.user, registration_id=token, defaults={'platform': platform})
        if not created and platform and device.platform != platform:
            device.platform = platform
            device.save()
        serializer = DeviceSerializer(device)
        return Response(serializer.data)
