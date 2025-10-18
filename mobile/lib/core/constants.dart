// Defina aqui o endereço do backend para todo o app
// Para Android emulador use 10.0.2.2, para dispositivo físico use seu IP
import 'package:flutter/foundation.dart' show kIsWeb;

const String _hostWeb = 'http://localhost:8000';
const String _hostLan = 'http://192.168.10.125:8000';
const String _hostAndroidEmu = 'http://10.0.2.2:8000';

// Seleção de host por plataforma: no Web usa localhost; caso contrário, LAN
const String backendHost = kIsWeb ? _hostWeb : _hostLan;
