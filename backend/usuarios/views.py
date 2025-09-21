from rest_framework import viewsets, permissions
from .models import Usuario
from .serializers import LocadorSerializer, InquilinoSerializer

from rest_framework.permissions import IsAuthenticated

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