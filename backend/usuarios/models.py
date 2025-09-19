from django.contrib.auth.models import AbstractUser
from django.db import models

class Usuario(AbstractUser):
    TIPOS = (
        ('locador', 'Locador'),
        ('inquilino', 'Inquilino'),
    )
    tipo = models.CharField(max_length=10, choices=TIPOS)
    telefone = models.CharField(max_length=20, blank=True, null=True)
    data_nascimento = models.DateField(blank=True, null=True)
    bio = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.username} - {self.tipo}"
