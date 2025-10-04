from rest_framework import serializers
from .models import Imovel,FotoImovel, Tag

class ImovelSerializer(serializers.ModelSerializer):
    tags = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Tag.objects.all(),
        required=False
    )

    class Meta:
        model = Imovel
        fields = [
        'id', 
        'titulo', 
        'listing_type', 
        'tipo_imovel', 
        'endereco', 
        'descricao', 
        'valor_aluguel', 
        'tipo_cobranca', 
        'numero_quartos', 
        'numero_banheiros', 
        'numero_garagens',
        'tags',
    ]
        read_only_fields = ['locador']

class FotoImovelSerializer(serializers.ModelSerializer):
    class Meta:
        model = FotoImovel
        fields = '__all__'