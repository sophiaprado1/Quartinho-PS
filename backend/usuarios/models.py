from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.forms import ValidationError

class UsuarioManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("O usuário precisa de um email")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        return self.create_user(email, password, **extra_fields)


def validar_cpf(value):
    if not value.isdigit() or len(value) != 11:
        raise ValidationError("CPF inválido. Deve conter 11 dígitos numéricos.")
    return value


class Usuario(AbstractBaseUser, PermissionsMixin):
    PREFERENCE_CHOICES = [
        ('roommate', 'Procurando colega de quarto'),
        ('room', 'Procurando quarto'),
    ]
    
    email = models.EmailField(unique=True)
    username = models.CharField(max_length=150)  # nome completo
    cpf = models.CharField(max_length=14, unique=True, null=True, blank=True, validators=[validar_cpf])
    data_nascimento = models.DateField(null=True, blank=True)
    preference = models.CharField(max_length=20, choices=PREFERENCE_CHOICES, null=True, blank=True)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UsuarioManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username"]

    def __str__(self):
        return self.email
