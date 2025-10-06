from rest_framework import generics, permissions
from .models import Usuario
from rest_framework.views import APIView
from .serializers import UsuarioSerializer, LoginSerializer, UserPreferenceSerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import login

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
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)