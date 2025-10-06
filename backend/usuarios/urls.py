from django.urls import path
from .views import UsuarioCreateView, CheckEmailView, LoginView, UserPreferenceView

urlpatterns = [
    path('usercreate/', UsuarioCreateView.as_view(), name='usuario-create'),
    path('check-email/', CheckEmailView.as_view(), name='check-email'),
    path('login/', LoginView.as_view(), name='login'),
    path('preferences/', UserPreferenceView.as_view(), name='user-preferences'),
]
