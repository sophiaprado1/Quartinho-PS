import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/constants.dart';

class FavoritesService {
  static String get baseUrl => backendHost;

  /// Toggle favorite: POST /api/propriedades/propriedade/<id>/favoritar/
  /// Returns true if now favorited, false otherwise.
  static Future<bool?> toggleFavorite(int propriedadeId, {required String token}) async {
    final url = Uri.parse('$baseUrl/propriedades/propriedade/$propriedadeId/favoritar/');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body);
        return data['favorito'] as bool?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get list of favorites
  static Future<List<dynamic>?> listFavorites({required String token}) async {
    final url = Uri.parse('$baseUrl/propriedades/favoritos/');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return jsonDecode(resp.body) as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
