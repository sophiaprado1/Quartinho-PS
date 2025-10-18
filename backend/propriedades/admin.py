from django.contrib import admin
from .models import Propriedade, FotoPropriedade


class FotoInline(admin.TabularInline):
    model = FotoPropriedade
    extra = 1


@admin.register(Propriedade)
class PropriedadeAdmin(admin.ModelAdmin):
    list_display = ('id', 'titulo', 'proprietario', 'cidade', 'preco', 'tipo', 'data_criacao')
    search_fields = ('titulo', 'cidade', 'proprietario__email', 'proprietario__username')
    list_filter = ('cidade', 'tipo', 'mobiliado', 'aceita_pets')
    inlines = [FotoInline]


@admin.register(FotoPropriedade)
class FotoPropriedadeAdmin(admin.ModelAdmin):
    list_display = ('id', 'propriedade', 'principal')
    search_fields = ('propriedade__titulo',)
