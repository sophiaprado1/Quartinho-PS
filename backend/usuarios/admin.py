from django.contrib import admin
from .models import Usuario


@admin.register(Usuario)
class UsuarioAdmin(admin.ModelAdmin):
	list_display = ('id', 'email', 'username', 'cpf', 'is_active', 'is_staff')
	search_fields = ('email', 'username', 'cpf')
	list_filter = ('is_active', 'is_staff')
