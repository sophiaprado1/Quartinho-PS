from rest_framework import generics, permissions
from .models import Usuario
from rest_framework.views import APIView
from .serializers import UsuarioSerializer, LoginSerializer, UserPreferenceSerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import login
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser
import json
import urllib.request
import urllib.error

class UsuarioCreateView(generics.CreateAPIView):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioSerializer


class UsuarioDetailView(generics.RetrieveAPIView):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioSerializer
    permission_classes = [permissions.IsAuthenticated]

class UserPreferenceView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = UserPreferenceSerializer(data=request.data)
        if serializer.is_valid():
            request.user.preference = serializer.validated_data['preference_type']
            request.user.save()
            return Response({'message': 'Preferência salva com sucesso'}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
class CheckEmailView(APIView):
    def get(self, request):
        email = request.query_params.get("email")  
        if not email:
            return Response({"detail": "Email não fornecido"}, status=status.HTTP_400_BAD_REQUEST)

        exists = Usuario.objects.filter(email=email).exists()
        return Response({"exists": exists}, status=status.HTTP_200_OK)
        
    def post(self, request):
        email = request.data.get("email")
        if not email:
            return Response({"detail": "Email não fornecido"}, status=status.HTTP_400_BAD_REQUEST)
            
        exists = Usuario.objects.filter(email=email).exists()
        return Response({"exists": exists}, status=status.HTTP_200_OK)

class LoginView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            login(request, user)
            
            # Gerar token JWT
            refresh = RefreshToken.for_user(user)
            
            return Response({
                'tokens': {
                    'refresh': str(refresh),
                    'access': str(refresh.access_token),
                },
                'user': {
                    'id': user.id,
                    'email': user.email,
                    'full_name': user.username,
                    'preference': user.preference
                }
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# ---- Social Login Endpoints ----

def _ensure_unique_username(base: str) -> str:
    base = (base or 'user').strip().replace(' ', '')
    candidate = base
    idx = 1
    while Usuario.objects.filter(username=candidate).exists():
        candidate = f"{base}{idx}"
        idx += 1
    return candidate

class GoogleSocialLoginView(APIView):
    """Recebe id_token do Google (One Tap/Sign In) e retorna JWT da aplicação."""
    def post(self, request):
        id_token = request.data.get('id_token')
        if not id_token:
            return Response({'detail': 'id_token é obrigatório'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            with urllib.request.urlopen(f'https://oauth2.googleapis.com/tokeninfo?id_token={id_token}') as resp:
                info = json.loads(resp.read().decode('utf-8'))
        except urllib.error.HTTPError as e:
            return Response({'detail': 'id_token inválido', 'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'detail': 'Falha ao verificar token', 'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        email = info.get('email')
        name = info.get('name') or info.get('given_name') or (email.split('@')[0] if email else None)
        sub = info.get('sub')
        if not sub:
            return Response({'detail': 'Token Google sem sujeito (sub)'}, status=status.HTTP_400_BAD_REQUEST)

        if not email:
            # fallback quando email não disponível
            email = f"google_{sub}@google.local"
        username = _ensure_unique_username(name or email.split('@')[0])

        user, created = Usuario.objects.get_or_create(email=email, defaults={'username': username})
        if not created and not user.username:
            user.username = username
            user.save()

        refresh = RefreshToken.for_user(user)
        return Response({
            'tokens': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            },
            'user': {
                'id': user.id,
                'email': user.email,
                'full_name': user.username,
                'preference': getattr(user, 'preference', None)
            }
        }, status=status.HTTP_200_OK)

class FacebookSocialLoginView(APIView):
    """Recebe access_token do Facebook e retorna JWT da aplicação."""
    def post(self, request):
        access_token = request.data.get('access_token')
        if not access_token:
            return Response({'detail': 'access_token é obrigatório'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            url = f'https://graph.facebook.com/me?fields=id,name,email&access_token={access_token}'
            with urllib.request.urlopen(url) as resp:
                info = json.loads(resp.read().decode('utf-8'))
        except urllib.error.HTTPError as e:
            return Response({'detail': 'access_token inválido', 'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'detail': 'Falha ao verificar token', 'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        fid = info.get('id')
        name = info.get('name')
        email = info.get('email')
        if not fid:
            return Response({'detail': 'Token Facebook sem id'}, status=status.HTTP_400_BAD_REQUEST)
        if not email:
            email = f"fb_{fid}@facebook.local"
        username = _ensure_unique_username((name or email.split('@')[0]))

        user, created = Usuario.objects.get_or_create(email=email, defaults={'username': username})
        if not created and not user.username:
            user.username = username
            user.save()

        refresh = RefreshToken.for_user(user)
        return Response({
            'tokens': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            },
            'user': {
                'id': user.id,
                'email': user.email,
                'full_name': user.username,
                'preference': getattr(user, 'preference', None)
            }
        }, status=status.HTTP_200_OK)

class UserMeView(APIView):
    permission_classes = [IsAuthenticated]
    # allow multipart/form-data parsing for PATCH (so request.FILES is populated)
    parser_classes = [MultiPartParser, FormParser]

    def get(self, request):
        user = request.user
        avatar_url = None
        try:
            if getattr(user, 'avatar', None):
                avatar_url = request.build_absolute_uri(user.avatar.url)
        except Exception:
            avatar_url = None
        return Response({
            'id': user.id,
            'email': getattr(user, 'email', None),
            'username': getattr(user, 'username', None),
            'preference': getattr(user, 'preference', None),
            'cpf': getattr(user, 'cpf', None),
            'data_nascimento': getattr(user, 'data_nascimento', None),
            'avatar': avatar_url,
            'telefone': getattr(user, 'telefone', None),
        }, status=status.HTTP_200_OK)

    def patch(self, request):
        user = request.user
        data = request.data or {}
        # debug: log incoming files and keys to help diagnose avatar upload issues
        try:
            print('DEBUG UserMeView.patch - request.FILES keys:', list(request.FILES.keys()))
            print('DEBUG UserMeView.patch - request.data keys:', list(request.data.keys()))
        except Exception:
            pass
        allowed = ['username', 'email', 'cpf', 'data_nascimento', 'telefone']
        changed = False
        for k in allowed:
            if k in data:
                setattr(user, k, data.get(k))
                changed = True
        # aceitar upload de avatar via multipart
        if 'avatar' in request.FILES:
            user.avatar = request.FILES['avatar']
            changed = True
        else:
            # fallback: some clients place files in request.data for certain methods
            avatar_candidate = data.get('avatar')
            try:
                if avatar_candidate is not None and hasattr(avatar_candidate, 'file'):
                    user.avatar = avatar_candidate
                    changed = True
            except Exception:
                pass
        if changed:
            user.save()
            avatar_url = None
            try:
                if user.avatar:
                    avatar_url = request.build_absolute_uri(user.avatar.url)
            except Exception:
                avatar_url = None
            return Response({
                'id': user.id,
                'email': getattr(user, 'email', None),
                'username': getattr(user, 'username', None),
                'cpf': getattr(user, 'cpf', None),
                'data_nascimento': getattr(user, 'data_nascimento', None),
                'avatar': avatar_url,
                'telefone': getattr(user, 'telefone', None),
            }, status=status.HTTP_200_OK)
        return Response({'detail': 'Nenhuma alteração'}, status=status.HTTP_200_OK)