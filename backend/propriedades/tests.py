from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from usuarios.models import Usuario
from .models import Propriedade, FotoPropriedade
from io import BytesIO
from PIL import Image


def create_image_file(fmt='JPEG', size=(100, 100)):
    file_obj = BytesIO()
    image = Image.new('RGB', size, color=(255, 0, 0))
    image.save(file_obj, fmt)
    file_obj.seek(0)
    file_obj.name = f'test.{fmt.lower()}'
    return file_obj


class PropriedadesAPITests(APITestCase):
    def setUp(self):
        self.user = Usuario.objects.create_user(email='owner@example.com', password='pass123', username='Owner')
        self.other = Usuario.objects.create_user(email='other@example.com', password='pass123', username='Other')
        # Obter tokens
        resp = self.client.post(reverse('token_obtain_pair'), {"email": self.user.email, "password": "pass123"}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.access = resp.data['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.access}')

    def test_serializer_read_only_proprietario_and_creation(self):
        payload = {
            "titulo": "Apto Legal",
            "descricao": "Descrição",
            "tipo": "apartamento",
            "preco": "1200.00",
            "cidade": "São Paulo",
            "estado": "SP",
            "cep": "01000-000",
            "quartos": 2,
            "banheiros": 1,
            "mobiliado": True
        }
        url = reverse('propriedade-list')
        r = self.client.post(url, payload, format='json')
        self.assertEqual(r.status_code, status.HTTP_201_CREATED)
        prop = Propriedade.objects.get(id=r.data['id'])
        self.assertEqual(prop.proprietario, self.user)

    def test_filters_and_ordering(self):
        Propriedade.objects.create(
            proprietario=self.user, titulo='Casa 1', descricao='d', tipo='casa', preco=2000,
            cidade='Campinas', estado='SP', cep='13000-000', quartos=3, banheiros=2, mobiliado=False
        )
        Propriedade.objects.create(
            proprietario=self.user, titulo='Apto 2', descricao='d', tipo='apartamento', preco=1500,
            cidade='São Paulo', estado='SP', cep='01000-000', quartos=2, banheiros=1, mobiliado=True, aceita_pets=True
        )
        url = reverse('propriedade-list')
        # cidade icontains
        r = self.client.get(url, {"cidade": "Sao"})
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        # tipo
        r = self.client.get(url, {"tipo": "apartamento"})
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        # preco range
        r = self.client.get(url, {"preco_min": 1400, "preco_max": 1600})
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        # estado
        r = self.client.get(url, {"estado": "SP"})
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        # quartos
        r = self.client.get(url, {"quartos_min": 2, "quartos_max": 3})
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        # booleanos
        r = self.client.get(url, {"mobiliado": "true", "aceita_pets": "true"})
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        # ordering
        r = self.client.get(url, {"ordering": "-preco"})
        self.assertEqual(r.status_code, status.HTTP_200_OK)

    def test_permissions_owner_can_edit_delete(self):
        prop = Propriedade.objects.create(
            proprietario=self.user, titulo='Editável', descricao='d', tipo='casa', preco=1000,
            cidade='Santos', estado='SP', cep='11000-000', quartos=1, banheiros=1
        )
        url_detail = reverse('propriedade-detail', args=[prop.id])
        # owner update
        r = self.client.patch(url_detail, {"preco": "1300.00"}, format='json')
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        # other user cannot delete
        resp = self.client.post(reverse('token_obtain_pair'), {"email": self.other.email, "password": "pass123"}, format='json')
        other_access = resp.data['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {other_access}')
        r = self.client.delete(url_detail)
        self.assertEqual(r.status_code, status.HTTP_403_FORBIDDEN)

    def test_upload_sanitization(self):
        prop = Propriedade.objects.create(
            proprietario=self.user, titulo='Com Foto', descricao='d', tipo='kitnet', preco=800,
            cidade='São Paulo', estado='SP', cep='01000-000', quartos=1, banheiros=1
        )
        # voltar credenciais do owner
        resp = self.client.post(reverse('token_obtain_pair'), {"email": self.user.email, "password": "pass123"}, format='json')
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {resp.data['access']}')
        url_upload = reverse('propriedade-upload-fotos', args=[prop.id])
        # imagem válida JPEG
        img = create_image_file('JPEG')
        r = self.client.post(url_upload, {"imagens": [img], "principal": "0"}, format='multipart')
        self.assertEqual(r.status_code, status.HTTP_201_CREATED)
        # imagem com mimetype inválido
        bad = BytesIO(b"not an image")
        bad.name = 'bad.txt'
        r = self.client.post(url_upload, {"imagens": [bad]}, format='multipart')
        self.assertEqual(r.status_code, status.HTTP_400_BAD_REQUEST)
        # imagem grande
        big = create_image_file('PNG', size=(3000, 3000))
        big.seek(0, 2)
        if big.tell() < (5 * 1024 * 1024 + 1):
            # aumentar artificialmente
            big.write(b"\0" * (5 * 1024 * 1024 + 2 - big.tell()))
        big.seek(0)
        r = self.client.post(url_upload, {"imagens": [big]}, format='multipart')
        self.assertEqual(r.status_code, status.HTTP_400_BAD_REQUEST)