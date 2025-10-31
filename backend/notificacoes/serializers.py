from rest_framework import serializers
from .models import Notificacao, Device

class NotificacaoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notificacao
        fields = [
            'id', 
            'usuario', 
            'imovel', 
            'mensagem', 
            'lida', 
            'data_criacao'
        ]


class DeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Device
        fields = ['id', 'usuario', 'registration_id', 'platform', 'criado_em']