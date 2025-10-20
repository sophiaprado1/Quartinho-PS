from django.db import models
from usuarios.models import Usuario

class Propriedade(models.Model):
    TIPO_CHOICES = [
        ('apartamento', 'Apartamento'),
        ('casa', 'Casa'),
        ('kitnet', 'Kitnet'),
        ('republica', 'República'),
    ]
    
    proprietario = models.ForeignKey(Usuario, on_delete=models.CASCADE, related_name='propriedades')
    titulo = models.CharField(max_length=100)
    descricao = models.TextField(blank=True)
    tipo = models.CharField(max_length=20, choices=TIPO_CHOICES)
    preco = models.DecimalField(max_digits=10, decimal_places=2)
    endereco = models.CharField(max_length=255, blank=True, null=True)
    cidade = models.CharField(max_length=100)
    estado = models.CharField(max_length=2)
    cep = models.CharField(max_length=9)
    quartos = models.IntegerField(default=1)
    banheiros = models.IntegerField(default=1)
    area = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    mobiliado = models.BooleanField(default=False)
    aceita_pets = models.BooleanField(default=False)
    internet = models.BooleanField(default=False)
    estacionamento = models.BooleanField(default=False)
    data_criacao = models.DateTimeField(auto_now_add=True)
    data_atualizacao = models.DateTimeField(auto_now=True)
    favoritos = models.ManyToManyField(Usuario, related_name='propriedades_favoritas', blank=True)

    def __str__(self):
        return self.titulo

class FotoPropriedade(models.Model):
    propriedade = models.ForeignKey(Propriedade, on_delete=models.CASCADE, related_name='fotos')
    imagem = models.FileField(upload_to='propriedades/')
    principal = models.BooleanField(default=False)
    
    def __str__(self):
        return f"Foto de {self.propriedade.titulo}"