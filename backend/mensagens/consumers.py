from channels.generic.websocket import AsyncJsonWebsocketConsumer
from django.contrib.auth import get_user_model
from channels.db import database_sync_to_async
from asgiref.sync import sync_to_async
from notificacoes.utils import send_fcm_to_user
import logging
from django.conf import settings

User = get_user_model()


class ChatConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        user = self.scope.get('user')
        if user and user.is_authenticated:
            self.user = user
            # use group per user for direct messages
            self.group_name = f'user_{user.id}'
            await self.channel_layer.group_add(self.group_name, self.channel_name)
            await self.accept()
            try:
                if settings.DEBUG:
                    logging.getLogger('chat').info(
                        'WS connect ok user=%s channel=%s group=%s',
                        getattr(user, 'id', 'unknown'), self.channel_name, self.group_name
                    )
            except Exception:
                pass
        else:
            try:
                if settings.DEBUG:
                    logging.getLogger('chat').warning('WS connect rejected: anonymous/invalid token')
            except Exception:
                pass
            await self.close()

    async def disconnect(self, code):
        if hasattr(self, 'group_name'):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)
        try:
            if settings.DEBUG:
                logging.getLogger('chat').info('WS disconnect code=%s channel=%s', code, self.channel_name)
        except Exception:
            pass

    async def receive_json(self, content, **kwargs):
        # expected: action payload
        # {"type":"message","to":123,"text":"hello"}
        # or {"type":"message","to":123,"message_type":"imovel","data":{"imovel_id":1}}
        action = content.get('type')
        if action == 'message':
            to_id = content.get('to')
            text = content.get('text')
            message_type = content.get('message_type') or 'text'
            data = content.get('data') or None
            try:
                if settings.DEBUG:
                    logging.getLogger('chat').info(
                        'WS receive message: from=%s to=%s type=%s has_text=%s',
                        getattr(getattr(self, 'user', None), 'id', 'unknown'), to_id, message_type, bool(text)
                    )
            except Exception:
                pass
            if not to_id:
                return
            if message_type == 'text' and not text:
                return
            # save message via sync function
            message_data = await self.create_message(self.user.id, to_id, text or '', message_type, data)
            # Verificar se houve erro na validação
            if message_data.get('error'):
                await self.send_json({'type': 'error', 'message': message_data.get('error')})
                return
            # send to recipient group
            await self.channel_layer.group_send(
                f'user_{to_id}',
                {
                    'type': 'chat.message',
                    'message': message_data,
                }
            )
            # also echo back to sender
            await self.send_json({'type': 'message_sent', 'message': message_data})
            # try to send push notification to recipient
            try:
                recipient = await database_sync_to_async(User.objects.get)(id=to_id)
                body = 'te enviou uma mensagem'
                if message_type == 'imovel':
                    body = 'enviou um imóvel'
                payload = {'type': 'chat', 'conversation': message_data.get('conversation'), 'from_user': self.user.id}
                if message_type == 'imovel':
                    data = content.get('data') or {}
                    if isinstance(data, dict) and data.get('imovel_id'):
                        payload['imovel'] = data.get('imovel_id')
                await sync_to_async(send_fcm_to_user, thread_sensitive=False)(
                    recipient,
                    'Nova mensagem',
                    f'{self.user} {body}',
                    payload
                )
            except Exception:
                pass

    async def chat_message(self, event):
        await self.send_json({'type': 'message', 'message': event['message']})

    @database_sync_to_async
    def create_message(self, sender_id, recipient_id, text, message_type='text', data=None):
        from .models import Message, Conversation
        from usuarios.models import Usuario

        sender = Usuario.objects.get(id=sender_id)
        recipient = Usuario.objects.get(id=recipient_id)
        
        # Validação: se for tipo 'imovel', verificar se existe
        if message_type == 'imovel' and isinstance(data, dict):
            imovel_id = data.get('imovel_id')
            if imovel_id:
                try:
                    from propriedades.models import Propriedade
                    if not Propriedade.objects.filter(id=imovel_id).exists():
                        # Retornar mensagem de erro sem criar
                        return {
                            'error': 'Imóvel não encontrado',
                            'id': None,
                        }
                except Exception:
                    pass  # Se modelo não existe, continuar
        
        conv = Conversation.objects.filter(participants=sender).filter(participants=recipient).first()
        if not conv:
            conv = Conversation.objects.create()
            conv.participants.add(sender)
            conv.participants.add(recipient)
        msg = Message.objects.create(
            conversation=conv,
            sender=sender,
            recipient=recipient,
            text=text or '',
            type=message_type,
            data=data,
        )
        try:
            from notificacoes.models import Notificacao
            Notificacao.objects.create(usuario=recipient, mensagem=f'{sender} te enviou uma mensagem')
        except Exception:
            pass
        return {
            'id': msg.id,
            'conversation': conv.id,
            'sender': {'id': sender.id, 'nome': getattr(sender, 'nome', '')},
            'recipient': {'id': recipient.id, 'nome': getattr(recipient, 'nome', '')},
            'text': msg.text,
            'type': getattr(msg, 'type', 'text'),
            'data': getattr(msg, 'data', None),
            'created_at': msg.created_at.isoformat(),
        }
