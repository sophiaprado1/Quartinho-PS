from django.db import migrations, models
from django.conf import settings


class Migration(migrations.Migration):

	dependencies = [
		('mensagens', '0001_initial'),
		migrations.swappable_dependency(settings.AUTH_USER_MODEL),
	]

	operations = [
		migrations.AddField(
			model_name='conversation',
			name='deleted_by',
			field=models.ManyToManyField(blank=True, related_name='deleted_conversations', to=settings.AUTH_USER_MODEL),
		),
		migrations.AddField(
			model_name='conversation',
			name='muted_by',
			field=models.ManyToManyField(blank=True, related_name='muted_conversations', to=settings.AUTH_USER_MODEL),
		),
		migrations.AddField(
			model_name='message',
			name='data',
			field=models.JSONField(blank=True, null=True),
		),
		migrations.AddField(
			model_name='message',
			name='type',
			field=models.CharField(default='text', max_length=20),
		),
		migrations.AlterField(
			model_name='message',
			name='text',
			field=models.TextField(blank=True),
		),
	]

