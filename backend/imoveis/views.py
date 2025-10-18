# imoveis/views.py

from rest_framework import viewsets, permissions
from .models import Imovel, FotoImovel
from .serializers import ImovelSerializer, FotoImovelSerializer

class ImovelViewSet(viewsets.ModelViewSet):
    queryset = Imovel.objects.all()
    serializer_class = ImovelSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(locador=self.request.user)


class FotoImovelViewSet(viewsets.ModelViewSet):
    queryset = FotoImovel.objects.all()
    serializer_class = FotoImovelSerializer
    permission_classes = [permissions.IsAuthenticated]

