from django import forms
from .models import Usuario
from django.contrib.auth.forms import UserCreationForm

class UsuarioForm(UserCreationForm):
    nome_completo = forms.CharField(
        max_length=255,
        widget=forms.TextInput(attrs={'placeholder': 'Digite seu nome completo'})
    )
    data_nascimento = forms.DateField(
        widget=forms.DateInput(attrs={'type': 'date'})
    )
    cpf = forms.CharField(
        max_length=14,
        widget=forms.TextInput(attrs={'placeholder': '000.000.000-00'})
    )
    email = forms.EmailField(
        widget=forms.EmailInput(attrs={'placeholder': 'Digite seu e-mail'})
    )

    class Meta:
        model = Usuario
        fields = ['nome_completo', 'data_nascimento', 'cpf', 'email', 'password1', 'password2']
