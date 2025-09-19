from rest_framework import serializers
from .models import Usuario
from django.contrib.auth.hashers import make_password

class LocadorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'username', 'email', 'telefone', 'bio', 'password']  
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        validated_data['tipo'] = 'locador'  
        return super().create(validated_data)


class InquilinoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'username', 'email', 'telefone', 'data_nascimento', 'password']  
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        validated_data['tipo'] = 'inquilino'  
        return super().create(validated_data)
