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
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/usuarios/login/');
    print('Enviando login para: ' + url.toString());
    print('Body: ' + jsonEncode({'email': email, 'password': senha}));
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': senha}),
      );
      print('Status code: ' + response.statusCode.toString());
      print('Response body: ' + response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // backend retorna tokens.access
        final token = (data['tokens'] != null)
            ? data['tokens']['access']
            : data['access'];
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

  static Future<Map<String, dynamic>?> me({required String token}) async {
    final url = Uri.parse('$baseUrl/usuarios/me/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Erro ao buscar /me: $e');
      return null;
    }
  }

  

  // Lê o token salvo localmente
  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Limpa o token e efetua logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
