from rest_framework import viewsets
from .models import Usuario
from .serializers import LocadorSerializer, InquilinoSerializer

class LocadorViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.filter(tipo='locador')
    serializer_class = LocadorSerializer

class InquilinoViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.filter(tipo='inquilino')
    serializer_class = InquilinoSerializer
