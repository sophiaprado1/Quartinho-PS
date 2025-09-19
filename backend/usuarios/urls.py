from rest_framework import routers
from .views import LocadorViewSet, InquilinoViewSet

router = routers.DefaultRouter()
router.register(r'locadores', LocadorViewSet, basename='locador')
router.register(r'inquilinos', InquilinoViewSet, basename='inquilino')

urlpatterns = router.urls
