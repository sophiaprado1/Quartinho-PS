from django import forms
from django.contrib.auth.forms import UserCreationForm
from .models import Usuario
from django.contrib.auth.hashers import make_password
from pycpfcnpj import cpf

class LocadorCreateForm(UserCreationForm):
    class Meta:
        model = Usuario
        fields = ['username', 'email', 'telefone', 'cpf', 'sexo', 'bio', 'password1', 'password2']  

    def save(self, commit=True):
        user = super().save(commit=False)
        user.tipo = 'locador'  
        if commit:
            user.save()
        return user
    
    def clean_cpf(self):
        cpf_data = self.cleaned_data.get("cpf")
        if cpf_data and not cpf.is_valid(cpf_data):
            raise forms.ValidationError("Este CPF é inválido.")
        return cpf_data    


class InquilinoCreateForm(UserCreationForm):
    class Meta:
        model = Usuario
        fields = ['username', 'email', 'telefone', 'cpf', 'sexo', 'data_nascimento', 'password1', 'password2']  

    def save(self, commit=True):
        user = super().save(commit=False)
        user.tipo = 'inquilino'  
        if commit:
            user.save()
        return user
    
    def clean_cpf(self):
        cpf_data = self.cleaned_data.get("cpf")
        if cpf_data and not cpf.validate(cpf_data):
            raise forms.ValidationError("Este CPF é inválido.")
        return cpf_data    
