from rest_framework import serializers
from .models import Propriedade, FotoPropriedade, Comentario
from usuarios.serializers import UsuarioSerializer

class FotoPropriedadeSerializer(serializers.ModelSerializer):
    class Meta:
        model = FotoPropriedade
        fields = ['id', 'imagem', 'principal']

class PropriedadeSerializer(serializers.ModelSerializer):
    fotos = FotoPropriedadeSerializer(many=True, read_only=True)
    proprietario = UsuarioSerializer(read_only=True)
    endereco = serializers.CharField(max_length=255, required=False, allow_blank=True, allow_null=True)
    comentarios = serializers.SerializerMethodField()
    favorito = serializers.SerializerMethodField()
    
    class Meta:
        model = Propriedade
        fields = [
            'id', 'proprietario', 'titulo', 'descricao', 'tipo', 'preco',
            'endereco', 'cidade', 'estado', 'cep', 'quartos', 'banheiros',
            'area', 'mobiliado', 'aceita_pets', 'internet', 'estacionamento',
            'data_criacao', 'data_atualizacao', 'fotos'
            , 'comentarios',
            'favorito',
        ]
        read_only_fields = ['id', 'data_criacao', 'data_atualizacao', 'proprietario']
    
    def create(self, validated_data):
        return Propriedade.objects.create(**validated_data)
    
    def get_comentarios(self, obj):
        qs = obj.comentarios.all()
        return ComentarioSerializer(qs, many=True).data

    def get_favorito(self, obj):
        # retorna True se o usuário na request favoritou este imóvel
        request = self.context.get('request') if self.context else None
        if request is None:
            return False
        user = getattr(request, 'user', None)
        if user is None or not user.is_authenticated:
            return False
        return obj.favoritos.filter(pk=user.pk).exists()

class ComentarioSerializer(serializers.ModelSerializer):
    autor = UsuarioSerializer(read_only=True)

    class Meta:
        model = Comentario
        fields = ['id', 'imovel', 'autor', 'texto', 'nota', 'data_criacao', 'data_atualizacao']
        read_only_fields = ['autor', 'data_criacao', 'data_atualizacao']