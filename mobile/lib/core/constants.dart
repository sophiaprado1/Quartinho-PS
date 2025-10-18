// Defina aqui o endereço do backend para todo o app
// Para Android emulador use 10.0.2.2, para dispositivo físico use seu IP
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

const String _hostWeb = 'http://localhost:8000';
// IP da sua máquina na rede local (dispositivo físico) - use o IP da sua rede
const String _hostLan = 'http://192.168.10.124:8000';
// Emulador Android padrão
const String _hostAndroidEmu = 'http://192.168.10.124:8000';

/// Seleciona o backend correto conforme o ambiente:
/// - Web: localhost
/// - Emulador Android: 10.0.2.2
/// - iOS simulador: localhost
/// - Dispositivo físico: IP local
String get backendHost {
	if (kIsWeb) return _hostWeb;
	try {
		if (Platform.isAndroid) return _hostAndroidEmu;
		// Para o simulador iOS, use a mesma faixa de IP da rede (útil para testar com backend
		// rodando na máquina host em um dispositivo físico ou quando preferir não usar localhost)
		if (Platform.isIOS) return _hostLan;
	} catch (_) {
		// Se não conseguir detectar platform, usar LAN
		return _hostLan;
	}
	return _hostLan;
}
