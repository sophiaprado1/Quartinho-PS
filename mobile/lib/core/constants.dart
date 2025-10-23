import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

const String _hostWeb = 'http://localhost:8000';
// IP local do computador (para celular físico)
const String _hostLan = 'http://192.168.10.109:8000';
// IP do host quando está rodando em emulador Android
const String _hostAndroidEmu = 'http://10.0.2.2:8000';

String get backendHost {
  if (kIsWeb) return _hostWeb;
  try {
    if (Platform.isAndroid) {
      // Detecta se está em emulador via variável opcional
      const bool isEmulator = bool.fromEnvironment('IS_EMULATOR', defaultValue: false);
      return isEmulator ? _hostAndroidEmu : _hostLan;
    }
    if (Platform.isIOS) return _hostLan;
  } catch (_) {
    return _hostLan;
  }
  return _hostLan;
}