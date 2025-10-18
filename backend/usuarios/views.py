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

class UsuarioCreateView(generics.CreateAPIView):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
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

class UserPreferenceView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        serializer = UserPreferenceSerializer(data=request.data)
        if serializer.is_valid():
            preference_type = serializer.validated_data['preference_type']
            
            # Atualizar o usuário com a preferência
            user = request.user
            user.preference = preference_type
            user.save()
            
            return Response({
                'status': 'success',
                'preference': preference_type
            })
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

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
        allowed = ['username', 'email', 'cpf', 'data_nascimento']
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
            }, status=status.HTTP_200_OK)
        return Response({'detail': 'Nenhuma alteração'}, status=status.HTTP_200_OK)