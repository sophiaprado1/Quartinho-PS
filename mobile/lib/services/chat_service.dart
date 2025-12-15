import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  final String baseUrl;
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messagesController = StreamController.broadcast();
  String? _lastUrl;
  String? _lastToken;
  bool _disposed = false;

  ChatService({required this.baseUrl});

  /// Busca lista de conversas do usuário autenticado
  Future<List<dynamic>> fetchConversations(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/mensagens/conversations/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return json.decode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to load conversations (HTTP ${res.statusCode})');
  }

  /// Atualiza uma conversa (mutar, deletar etc)
  Future<bool> updateConversation(
    String token,
    int conversationId, {
    bool? muted,
    bool? deleted,
    bool? markRead,
  }) async {
    final uri = Uri.parse('$baseUrl/mensagens/conversations/$conversationId/');
    final body = <String, dynamic>{};
    if (muted != null) body['muted'] = muted;
    if (deleted != null) body['deleted'] = deleted;
    if (markRead != null && markRead) body['mark_read'] = true;

    final res = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  /// Marca uma conversa como lida (convenience wrapper)
  Future<bool> markConversationRead(String token, int conversationId) {
    return updateConversation(token, conversationId, markRead: true);
  }

  /// Busca mensagens trocadas com um usuário específico
  Future<List<dynamic>> fetchMessages(String token, int withUserId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/mensagens/mensagens/?with_user=$withUserId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return json.decode(res.body) as List<dynamic>;
    } else if (res.statusCode == 404) {
      throw Exception('Endpoint /mensagens/mensagens/ não encontrado.');
    }
    throw Exception('Failed to load messages (HTTP ${res.statusCode})');
  }

  /// Conecta ao WebSocket do chat
  /// Se [force] for true, fecha e reconecta mesmo se já houver um canal.
  void connectWebSocket(String url, String token, {bool force = false}) {
    // Evita múltiplas conexões
    if (!force && _channel != null) return;

    _lastUrl = url;
    _lastToken = token;

    final wsUrl = url.replaceFirst(RegExp(r'^http'), 'ws') +
        '/ws/chat/?token=' +
        Uri.encodeComponent(token);

    // Se for reconexão forçada, fecha canal anterior
    try {
      if (force) {
        _channel?.sink.close();
        _channel = null;
      }
    } catch (_) {}

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel!.stream.listen((data) {
      try {
        final jsonData = json.decode(data as String) as Map<String, dynamic>;
        _messagesController.add(jsonData);
      } catch (e) {
        // ignora mensagens inválidas
      }
    }, onDone: _handleDisconnect, onError: (e) {
      _handleDisconnect();
    });
  }

  void _handleDisconnect() {
    _channel = null;
    if (!_disposed && _lastUrl != null && _lastToken != null) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!_disposed) connectWebSocket(_lastUrl!, _lastToken!);
      });
    }
  }

  /// Stream de mensagens recebidas em tempo real
  Stream<Map<String, dynamic>> get messages => _messagesController.stream;

  /// Envia uma mensagem de texto
  void sendMessage(int toId, String text) {
    // Evita duplicação: usa somente HTTP para persistir e deixar servidor emitir via WS.
    _postMessageHttp(toId: toId, text: text);
  }

  /// Envia mensagem com dados extras (ex: imóvel)
  void sendRichMessage({
    required int toId,
    String messageType = 'text',
    Map<String, dynamic>? data,
    String? text,
  }) {
    _postMessageHttp(toId: toId, text: text, messageType: messageType, data: data);
  }

  /// Envia mensagem via HTTP como fallback quando WS não está disponível
  Future<void> _postMessageHttp({
    required int toId,
    String? text,
    String messageType = 'text',
    Map<String, dynamic>? data,
  }) async {
    final token = _lastToken;
    if (token == null) return; // sem token não temos como enviar

    try {
      final uri = Uri.parse('$baseUrl/mensagens/mensagens/');
      final body = <String, dynamic>{
        'to': toId,
        'message_type': messageType,
      };
      if (text != null) body['text'] = text;
      if (data != null) body['data'] = data;
      await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      // Não emitimos no stream para evitar duplicar com a mensagem otimista.
    } catch (_) {}
  }

  /// Fecha conexões e libera recursos
  void dispose() {
    _disposed = true;
    _channel?.sink.close();
    _messagesController.close();
  }
}