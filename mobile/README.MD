# Quartinho-PS Mobile

Este é o aplicativo Flutter do Quartinho-PS, que consome a API Django do backend.  
Siga as instruções abaixo para rodar o app no seu celular (Android ou iOS) usando o IP do backend.

## Pré-requisitos

- Flutter instalado ([guia oficial](https://docs.flutter.dev/get-started/install))
- Backend Django rodando na mesma rede, com IP acessível pelo celular
- Celular e computador conectados na mesma rede Wi-Fi

## Passos para rodar o app no celular

1. **Descubra o IP do seu computador**
   - No terminal, rode:  
     ```bash
     ip addr show
     ```
   - Procure por um IP do tipo `192.168.x.x` ou `10.0.x.x`.

2. **Altere o IP do backend no app**
   - No arquivo `lib/core/constants.dart`, defina:
     ```dart
     const String backendHost = 'http://SEU_IP:8000';
     ```
     Substitua `SEU_IP` pelo IP do seu computador.

3. **Conecte o celular via USB ou use emulador**
   - Para Android: ative a depuração USB e aceite a conexão.
   - Para iOS: use um Mac e siga as permissões do Xcode.

4. **Dê permissão de internet ao app**
   - No Android, confira se há a linha abaixo em `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <uses-permission android:name="android.permission.INTERNET"/>
     ```

5. **Rode o backend Django**
   - No terminal do backend, execute:
     ```bash
     python manage.py runserver 0.0.0.0:8000
     ```
   - O backend ficará acessível em `http://SEU_IP:8000`.

6. **Rode o app Flutter**
   - No terminal do projeto mobile, execute:
     ```bash
     flutter pub get
     flutter run
     ```
   - Escolha o dispositivo (celular ou emulador) para rodar o app.

## Observações

- O backend precisa estar rodando e acessível pelo IP configurado.
- Se não conseguir acessar, teste no navegador do celular:  
  `http://SEU_IP:8000/api/`
- Se usar emulador Android, pode usar `10.0.2.2` como IP do backend.

---

Se tiver dúvidas, consulte a documentação do Flutter ou peça ajuda ao time!