
from django.contrib import admin
from .models import Usuario, Imovel, Imovel_Foto

@admin.register(Usuario)
class UsuarioAdmin(admin.ModelAdmin):
	list_display = ('id', 'username', 'email', 'tipo', 'is_active')
	search_fields = ('username', 'email', 'cpf')


@admin.register(Imovel)
class ImovelAdmin(admin.ModelAdmin):
	list_display = ('id', 'titulo', 'dono', 'cidade', 'preco_total', 'ativo')
	search_fields = ('titulo', 'cidade', 'dono__username')
	list_filter = ('cidade', 'ativo')


@admin.register(Imovel_Foto)
class ImovelFotoAdmin(admin.ModelAdmin):
	list_display = ('id', 'imovel', 'imagem')
	search_fields = ('imovel__titulo',)
