from django import forms
from django.contrib.auth.forms import UserCreationForm
from .models import Usuario

class LocadorCreateForm(UserCreationForm):
    class Meta:
        model = Usuario
        fields = ['username', 'email', 'telefone', 'bio', 'password1', 'password2']

    def save(self, commit=True):
        user = super().save(commit=False)
        user.tipo = 'locador'
        if commit:
            user.save()
        return user


class InquilinoCreateForm(UserCreationForm):
    class Meta:
        model = Usuario
        fields = ['username', 'email', 'telefone', 'data_nascimento', 'password1', 'password2']

    def save(self, commit=True):
        user = super().save(commit=False)
        user.tipo = 'inquilino'
        if commit:
            user.save()
        return user
