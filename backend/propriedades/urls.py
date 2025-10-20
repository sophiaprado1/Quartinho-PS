from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PropriedadeViewSet
from . import views

router = DefaultRouter()
router.register(r'propriedades', PropriedadeViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('propriedade/<int:propriedade_id>/favoritar/', views.favoritar_propriedade, name='favoritar_propriedade'),
    path('favoritos/', views.lista_favoritos, name='lista_favoritos'),    
]