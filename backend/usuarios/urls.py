from django.urls import path
from .views import (
    UsuarioCreateView,
    CheckEmailView,
    LoginView,
    UserPreferenceView,
    UserMeView,
    GoogleSocialLoginView,
    FacebookSocialLoginView,
    UsuarioDetailView,
)

urlpatterns = [
    path('usercreate/', UsuarioCreateView.as_view(), name='usuario-create'),
    path('check-email/', CheckEmailView.as_view(), name='check-email'),
    path('login/', LoginView.as_view(), name='login'),
    path('preferences/', UserPreferenceView.as_view(), name='user-preferences'),
    path('me/', UserMeView.as_view(), name='user-me'),
    path('social/google/', GoogleSocialLoginView.as_view(), name='social-google'),
    path('social/facebook/', FacebookSocialLoginView.as_view(), name='social-facebook'),
    path('<int:pk>/', UsuarioDetailView.as_view(), name='usuario-detail'),
]
