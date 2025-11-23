from django.db import models
from django.conf import settings
from django.db.models import JSONField
from django.utils import timezone


class Conversation(models.Model):
    # lightweight: conversation between two users; extend later
    participants = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name='conversations')
    muted_by = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name='muted_conversations', blank=True)
    deleted_by = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name='deleted_conversations', blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Conversation {self.id}'


class ConversationUserMeta(models.Model):
    """Metadata por usuário dentro de uma conversa (ex: último momento em que ele leu)."""
    conversation = models.ForeignKey(Conversation, related_name='user_meta', on_delete=models.CASCADE)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, related_name='conversation_meta', on_delete=models.CASCADE)
    last_read_at = models.DateTimeField(null=True, blank=True)
    # Momento em que o usuário optou por "excluir" a conversa. Usado para ocultar histórico anterior.
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        unique_together = ('conversation', 'user')

    def mark_read_now(self):
        self.last_read_at = timezone.now()
        self.save(update_fields=['last_read_at'])

    def mark_deleted_now(self):
        self.deleted_at = timezone.now()
        self.save(update_fields=['deleted_at'])


class Message(models.Model):
    conversation = models.ForeignKey(Conversation, related_name='messages', on_delete=models.CASCADE, null=True, blank=True)
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, related_name='sent_messages', on_delete=models.CASCADE)
    recipient = models.ForeignKey(settings.AUTH_USER_MODEL, related_name='received_messages', on_delete=models.CASCADE)
    text = models.TextField(blank=True)
    type = models.CharField(max_length=20, default='text')  # 'text' | 'imovel' | others
    data = JSONField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f'Message {self.id} from {self.sender_id} to {self.recipient_id}'
