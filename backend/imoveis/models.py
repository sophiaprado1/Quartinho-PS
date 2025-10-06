from django.db import models
from django.conf import settings


class Tag(models.Model):
    nome = models.CharField(max_length=50, unique=True)

    def __str__(self):
        return self.nome


class Imovel(models.Model):

    class ListingType(models.TextChoices):
        COLEGA_DE_QUARTO = 'COLEGA', 'Colega de quarto'
        REPUBLICA = 'REPUBLICA', 'República'

    class TipoImovel(models.TextChoices):
        APARTAMENTO = 'APARTAMENTO', 'Apartamento'
        CASA = 'CASA', 'Casa'
        KITNET = 'KITNET', 'Kitnet'

    class TipoCobranca(models.TextChoices):
        MENSAL = 'MENSAL', 'Mensal'
        ANUAL = 'ANUAL', 'Anual'

    #conecta o imovel ao usuario que ta logado
    locador = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    tags = models.ManyToManyField(Tag, blank=True)

    titulo = models.CharField(max_length=200)
    listing_type = models.CharField(max_length=20, choices=ListingType.choices, default=ListingType.COLEGA_DE_QUARTO) # <-- ADICIONE O DEFAULT
    tipo_imovel = models.CharField(max_length=20, choices=TipoImovel.choices, default=TipoImovel.APARTAMENTO) # <-- ADICIONE O DEFAULT

    endereco = models.CharField(max_length=255)

    descricao = models.TextField(blank=True)
    valor_aluguel = models.DecimalField(max_digits=10, decimal_places=2, default=0.00) # <-- ADICIONE O DEFAULT
    tipo_cobranca = models.CharField(max_length=10, choices=TipoCobranca.choices, default=TipoCobranca.MENSAL)
    
    numero_quartos = models.PositiveIntegerField(default=1)
    numero_banheiros = models.PositiveIntegerField(default=1)
    numero_garagens = models.PositiveIntegerField(default=0)

    disponivel = models.BooleanField(default=True)
    data_criacao = models.DateTimeField(auto_now_add=True)
    data_atualizacao = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = "Imóvel"
        verbose_name_plural = "Imóveis"
        ordering = ['-data_criacao']

    def __str__(self):
        return self.titulo


class FotoImovel(models.Model):

    imovel = models.ForeignKey(Imovel, related_name='fotos', on_delete=models.CASCADE)
    
    imagem = models.FileField(upload_to='fotos_imoveis/')

    def __str__(self):
        return f"Foto de {self.imovel.titulo}"