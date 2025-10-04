import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = backendHost;

  static Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/api/locadores/'); // ou /api/inquilinos/ conforme o tipo
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': nome, 'email': email, 'password': senha}),
    );
    return response.statusCode == 201;
  }

  static Future<String?> login({
    required String username,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/token/');
    print('Enviando login para: ' + url.toString());
    print('Body: ' + jsonEncode({'username': username, 'password': senha}));
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': senha}),
      );
      print('Status code: ' + response.statusCode.toString());
      print('Response body: ' + response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access'];
        // Salva o token localmente para login automático
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        return token;
      } else {
        throw response.body;
      }
    } catch (e) {
      print('Erro na requisição de login: $e');
      throw e.toString();
    }
  }
}
