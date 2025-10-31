import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/messages_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants.dart';
import '../../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final int ownerId;
  final String ownerName;
  const ChatPage({super.key, required this.ownerId, required this.ownerName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _ctrl = TextEditingController();
  int? _myUserId;
  final List<Map<String, dynamic>> _messages = [];
  Timer? _pollTimer;
  ChatService? _chatService;

  @override
  void initState() {
    super.initState();
    // determine current user id (to show sender alignment)
    AuthService.getSavedToken().then((t) async {
      if (t != null) {
        final me = await AuthService.me(token: t);
        if (me != null) setState(() => _myUserId = me['id'] is int ? me['id'] as int : int.tryParse(me['id']?.toString() ?? ''));
        // initial load
        final initial = await MessagesService.loadMessagesWithUser(widget.ownerId, token: t);
        setState(() {
          _messages.clear();
          _messages.addAll(initial);
        });
        // start polling as a safety net (in case WS disconnects)
        _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
          final list = await MessagesService.loadMessagesWithUser(widget.ownerId, token: t);
          if (mounted) setState(() { _messages
            ..clear()
            ..addAll(list);
          });
        });
        // connect websocket for realtime
        _chatService = ChatService(baseUrl: backendHost);
        _chatService!.connectWebSocket(backendHost, t);
        _chatService!.messages.listen((evt) {
          final m = evt['message'];
          if (m is Map) {
            final sender = m['sender'] as Map?;
            final recipient = m['recipient'] as Map?;
            final sid = sender != null ? int.tryParse(sender['id'].toString()) : null;
            final rid = recipient != null ? int.tryParse(recipient['id'].toString()) : null;
            if (sid == widget.ownerId || rid == widget.ownerId) {
              if (mounted) setState(() => _messages.add(Map<String, dynamic>.from(m)));
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pollTimer?.cancel();
    _chatService?.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final token = await AuthService.getSavedToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faça login para enviar mensagens')));
      return;
    }
    // try websocket first for instant delivery; fallback to HTTP
    if (_chatService != null) {
      _chatService!.sendMessage(widget.ownerId, text);
      _ctrl.clear();
      return;
    }
    final res = await MessagesService.sendMessageTo(widget.ownerId, text, token: token);
    if (res != null) {
      _ctrl.clear();
      // fetch will be refreshed by the polling stream; optionally force a local rebuild
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha ao enviar mensagem')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.ownerName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Conversar com proprietário', style: GoogleFonts.poppins(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(builder: (ctx) {
              final list = _messages;
              if (list.isEmpty) {
                  return Center(child: Text('Nenhuma mensagem ainda. Seja o primeiro a enviar uma pergunta.', style: GoogleFonts.poppins()));
              }
              return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final m = list[i];
                    final sender = m['sender'] is Map ? m['sender'] as Map<String, dynamic> : <String, dynamic>{};
                    final from = (sender['nome_completo'] ?? sender['username'] ?? sender['email'] ?? 'Usuário').toString();
                    final text = m['text']?.toString() ?? '';
                    final ts = m['created_at'] != null ? DateTime.tryParse(m['created_at'].toString()) : null;
                    final time = ts != null ? '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}' : '';
                    final isMe = _myUserId != null && sender['id'] != null && (sender['id'] is int ? sender['id'] == _myUserId : int.tryParse(sender['id'].toString()) == _myUserId);

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFFFEFD6) : const Color(0xFFEFEFFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(from, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(text, style: GoogleFonts.poppins(fontSize: 14)),
                            const SizedBox(height: 6),
                            Text(time, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(hintText: 'Escreva uma mensagem...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _send,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A34)),
                  child: const Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
