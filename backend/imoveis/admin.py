from django.contrib import admin
from .models import Imovel, Tag, FotoImovel

class FotoImovelInline(admin.TabularInline):
    model = FotoImovel
    extra = 1

class ImovelAdmin(admin.ModelAdmin):
    inlines = [FotoImovelInline]
    list_display = ('titulo', 'locador', 'valor_aluguel', 'disponivel')
    list_filter = ('disponivel', 'tipo_imovel')
    search_fields = ('titulo', 'endereco')

admin.site.register(Imovel, ImovelAdmin)
admin.site.register(Tag)