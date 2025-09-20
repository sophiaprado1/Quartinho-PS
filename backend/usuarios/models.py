from django.contrib.auth.models import AbstractUser
from django.db import models
from django.core.exceptions import ValidationError
from pycpfcnpj import cpf

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
    
    def __str__(self):
        return f"{self.username} - {self.tipo}"