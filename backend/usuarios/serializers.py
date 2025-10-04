from rest_framework import serializers
from .models import Usuario
from django.contrib.auth.hashers import make_password
from pycpfcnpj import cpf

class LocadorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'username', 'email', 'telefone', 'bio', 'cpf', 'sexo', 'password']  
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
        fields = ['id', 'username', 'email', 'telefone', 'cpf', 'sexo', 'data_nascimento', 'password']  
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        validated_data['tipo'] = 'inquilino'  
        return super().create(validated_data)
    
    def validate_cpf(self, value):
        if not cpf.validate(value):
            raise serializers.ValidationError("CPF inválido.")
        return value    
