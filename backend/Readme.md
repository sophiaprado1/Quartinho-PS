
criando o banco de dados, no terminal:
$python manage.py makemigrations usuarios
$python manage.py makemigrations imoveis
$python manage.py migrate

para iniciar:
python manage.py runserver

adicionar inquilino:
http://127.0.0.1:8000/api/inquilinos/

adicionar locador:
http://127.0.0.1:8000/api/locadores/

para um Locador adicionar um imovel, url: http://127.0.0.1:8000/api/imoveis/

para o locador adicionar uma foto de um imovel:
http://127.0.0.1:8000/api/fotos/


Deletar/alterar:
http://127.0.0.1:8000/api/imoveis/1/



Fazer modificações no banco de dados como administrador:
http://127.0.0.1:8000/admin/

*necessario um login de administrador. no terminal, o comando:
$python manage.py createsuperuser
(inserir email não é obrigatório)