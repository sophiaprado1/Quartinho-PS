from rest_framework import serializers
from .models import Propriedade, FotoPropriedade
from usuarios.serializers import UsuarioSerializer

class FotoPropriedadeSerializer(serializers.ModelSerializer):
    class Meta:
        model = FotoPropriedade
        fields = ['id', 'imagem', 'principal']

class PropriedadeSerializer(serializers.ModelSerializer):
    fotos = FotoPropriedadeSerializer(many=True, read_only=True)
    proprietario = UsuarioSerializer(read_only=True)
    endereco = serializers.CharField(max_length=255, required=False, allow_blank=True, allow_null=True)
    
    class Meta:
        model = Propriedade
        fields = [
            'id', 'proprietario', 'titulo', 'descricao', 'tipo', 'preco',
            'endereco', 'cidade', 'estado', 'cep', 'quartos', 'banheiros',
            'area', 'mobiliado', 'aceita_pets', 'internet', 'estacionamento',
            'data_criacao', 'data_atualizacao', 'fotos'
        ]
        read_only_fields = ['id', 'data_criacao', 'data_atualizacao', 'proprietario']
    
    def create(self, validated_data):
        return Propriedade.objects.create(**validated_data)