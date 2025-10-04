
from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Usuario, Imovel, Imovel_Foto
from .serializers import LocadorSerializer, InquilinoSerializer, ImovelSerializer, ImovelFotoSerializer

# ViewSet para Imovel_Foto
class ImovelFotoViewSet(viewsets.ModelViewSet):
    queryset = Imovel_Foto.objects.all()
    serializer_class = ImovelFotoSerializer
    permission_classes = [IsAuthenticated]

class ImovelViewSet(viewsets.ModelViewSet):
    queryset = Imovel.objects.all().order_by('-data_publicacao')
    serializer_class = ImovelSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        user = self.request.user
        if hasattr(user, 'tipo') and user.tipo == 'locador':
            serializer.save(dono=user)
        else:
            raise PermissionError('Apenas locadores podem cadastrar imóveis.')

    def create(self, request, *args, **kwargs):
        try:
            return super().create(request, *args, **kwargs)
        except PermissionError as e:
            return Response({'detail': str(e)}, status=status.HTTP_403_FORBIDDEN)



class AllowPostAnyReadAuthenticated(permissions.BasePermission):

    def has_permission(self, request, view):
        if request.method == 'POST':
            return True
        
        return request.user and request.user.is_authenticated


class LocadorViewSet(viewsets.ModelViewSet):
    serializer_class = LocadorSerializer
    permission_classes = [AllowPostAnyReadAuthenticated]
    def get_queryset(self):
        if not self.request.user.is_authenticated:
            return Usuario.objects.none()
        return Usuario.objects.filter(tipo='locador')

class InquilinoViewSet(viewsets.ModelViewSet): 
    serializer_class = InquilinoSerializer
    permission_classes = [AllowPostAnyReadAuthenticated]
    def get_queryset(self):
  
        if not self.request.user.is_authenticated:
            return Usuario.objects.none()
        
        return Usuario.objects.filter(tipo='inquilino')