from rest_framework import permissions


class IsOwnerOrReadOnly(permissions.BasePermission):
    """Permite leitura para qualquer autenticado; escrita apenas ao proprietário."""

    def has_object_permission(self, request, view, obj):
        # Métodos de leitura (GET, HEAD, OPTIONS) são permitidos
        if request.method in permissions.SAFE_METHODS:
            return True

        # Para métodos de escrita, apenas o proprietário
        owner = getattr(obj, 'proprietario', None)
        return owner == request.user


class IsAuthorOrReadOnly(permissions.BasePermission):
    """Permite leitura para qualquer usuário autenticado; escrita apenas para o autor do objeto."""

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        author = getattr(obj, 'autor', None)
        return author == request.user