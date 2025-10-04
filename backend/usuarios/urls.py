from rest_framework import routers
from .views import LocadorViewSet, InquilinoViewSet, ImovelViewSet, ImovelFotoViewSet



router = routers.DefaultRouter()
router.register(r'locadores', LocadorViewSet, basename='locador')
router.register(r'inquilinos', InquilinoViewSet, basename='inquilino')
router.register(r'imoveis', ImovelViewSet, basename='imovel')
router.register(r'imoveis_foto', ImovelFotoViewSet, basename='imoveis_foto')

urlpatterns = router.urls
