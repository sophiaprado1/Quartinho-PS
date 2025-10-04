from rest_framework import routers
from .views import ImovelViewSet
from .views import ImovelViewSet, FotoImovelViewSet

router = routers.DefaultRouter()
router.register(r'imoveis', ImovelViewSet, basename='imovel')
router.register(r'fotos', FotoImovelViewSet, basename='foto-imovel')

urlpatterns = router.urls
