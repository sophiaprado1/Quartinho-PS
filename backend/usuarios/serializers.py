from rest_framework import serializers
from .models import Usuario, Imovel, Imovel_Foto
class UsuarioPerfilSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'username', 'first_name', 'email', 'bio']

class ImovelFotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Imovel_Foto
        fields = '__all__'

class ImovelSerializer(serializers.ModelSerializer):
    fotos = ImovelFotoSerializer(many=True, read_only=True)
    dono = UsuarioPerfilSerializer(read_only=True)

    class Meta:
        model = Imovel
        fields = '__all__'
from django.contrib.auth.hashers import make_password
from pycpfcnpj import cpf
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth import get_user_model

class LocadorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'username', 'first_name', 'email', 'telefone', 'bio', 'cpf', 'sexo', 'password']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        validated_data['tipo'] = 'locador'  
        return super().create(validated_data)

    def validate_cpf(self, value):
        if not cpf.validate(value):
            raise serializers.ValidationError("CPF inválido.")
        return value    

class InquilinoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'username', 'first_name', 'email', 'telefone', 'cpf', 'sexo', 'data_nascimento', 'password']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        validated_data['tipo'] = 'inquilino'  
        return super().create(validated_data)
    
    def validate_cpf(self, value):
        if not cpf.validate(value):
            raise serializers.ValidationError("CPF inválido.")
        return value

class EmailTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        return super().get_token(user)

    def validate(self, attrs):
        User = get_user_model()
        email = attrs.get('email')
        password = attrs.get('password')
        if email and password:
            try:
                user = User.objects.get(email=email)
                attrs['username'] = user.username
            except User.DoesNotExist:
                raise serializers.ValidationError({'email': 'Usuário com este e-mail não existe.'})
        return super().validate(attrs)

class EmailTokenObtainPairView(TokenObtainPairView):
    serializer_class = EmailTokenObtainPairSerializer
