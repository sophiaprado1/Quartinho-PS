from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from pycpfcnpj import cpf


class Imovel(models.Model):
    TIPO_IMOVEL = (
        ('casa', 'Casa'),
        ('apartamento', 'Apartamento'),
        ('kitnet', 'Kitnet'),
    )
    dono = models.ForeignKey('Usuario', on_delete=models.CASCADE, related_name='imoveis')
    titulo = models.CharField(max_length=100)
    descricao = models.TextField()
    endereco = models.CharField(max_length=255)
    cidade = models.CharField(max_length=100)
    preco_total = models.DecimalField(max_digits=12, decimal_places=2)
    qtd_vagas = models.PositiveIntegerField()
    vagas_disponiveis = models.PositiveIntegerField()
    tipo = models.CharField(max_length=20, choices=TIPO_IMOVEL, default='casa')
    data_publicacao = models.DateTimeField(auto_now_add=True)
    ativo = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.titulo} - {self.cidade}"


class Imovel_Foto(models.Model):
    imovel = models.ForeignKey('Imovel', on_delete=models.CASCADE, related_name='fotos')
    imagem = models.ImageField(upload_to='imoveis_fotos/', blank=True, null=True)

    def __str__(self):
        return f"Foto do imóvel {self.imovel_id}"

def validar_cpf(value):
    if not cpf.validate(value):
        raise ValidationError('CPF inválido.')

class Usuario(AbstractUser):
    ESCOLHA_SEXO = (
        ('M', 'Masculino'),
        ('F', 'Feminino'),
        ('O', 'Outro'),
    )    
    TIPOS = (
        ('locador', 'Locador'),
        ('inquilino', 'Inquilino'),
    )
    tipo = models.CharField(max_length=10, choices=TIPOS)
    telefone = models.CharField(max_length=20, blank=True, null=True)
    data_nascimento = models.DateField(blank=True, null=True)
    bio = models.TextField(blank=True, null=True)
    cpf = models.CharField(max_length=14, blank=True, null=True, unique=True, validators=[validar_cpf])
    sexo = models.CharField(max_length=1, choices=ESCOLHA_SEXO, blank=True, null=True)
    email = models.EmailField(unique=True, blank=True, null=True)
    
    def __str__(self):
        return f"{self.username} - {self.tipo}"