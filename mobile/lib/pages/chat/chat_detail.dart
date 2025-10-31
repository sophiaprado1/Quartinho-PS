import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/chat_service.dart';
import '../../core/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../imoveis/imovel_detalhe_page.dart';
import '../../core/services/auth_service.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatService chatService;
  final String token;
  final int otherUserId;
  final String otherName;
  final String? otherPhoto;

  const ChatDetailPage({
    Key? key, 
    required this.chatService, 
    required this.token, 
    required this.otherUserId, 
    required this.otherName,
    this.otherPhoto,
  }) : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  List<dynamic> messages = [];
  TextEditingController _controller = TextEditingController();
  int? _myUserId;
  final ScrollController _scrollController = ScrollController();
  final Set<int> _messageIds = {}; // Para prevenir duplicação

  @override
  void initState() {
    super.initState();
    debugPrint('ChatDetailPage - otherName: "${widget.otherName}", otherUserId: ${widget.otherUserId}');
    _loadMessages();
  // Conecta no WebSocket usando o host configurado do app.
  // Usa force=true para garantir uma conexão nova ao entrar na tela.
  widget.chatService.connectWebSocket(backendHost, widget.token, force: true);
    widget.chatService.messages.listen((event) {
      if (event['type'] == 'message') {
        final msg = event['message'];
        final msgId = msg['id'];
        // Prevenir duplicação
        if (msgId != null && !_messageIds.contains(msgId)) {
          setState(() {
            messages.add(msg);
            _messageIds.add(msgId);
          });
          _scrollToBottom();
        }
      }
    });
    _resolveMyUser();
  }

  Future<void> _loadMessages() async {
    final data = await widget.chatService.fetchMessages(widget.token, widget.otherUserId);
    setState(() {
      messages = data;
      // Popular o set de IDs para prevenir duplicação
      _messageIds.clear();
      for (var msg in data) {
        if (msg['id'] != null) _messageIds.add(msg['id']);
      }
    });
    // Scroll para o final após carregar
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _resolveMyUser() async {
    try {
      final me = await AuthService.me(token: widget.token);
      if (me != null) {
        setState(() => _myUserId = me['id'] is int ? me['id'] as int : int.tryParse(me['id']?.toString() ?? ''));
      }
    } catch (_) {}
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showUserProfile(BuildContext context) {
    final displayName = widget.otherName.isEmpty ? 'Usuário' : widget.otherName;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.otherPhoto != null && widget.otherPhoto!.isNotEmpty
                  ? NetworkImage(widget.otherPhoto!)
                  : null,
              child: widget.otherPhoto == null || widget.otherPhoto!.isEmpty
                  ? Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${widget.otherUserId}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Aqui você pode adicionar mais informações do perfil no futuro
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    // Adiciona a mensagem localmente (otimistic update)
    if (_myUserId != null) {
      final tempMsg = {
        'id': DateTime.now().millisecondsSinceEpoch, // ID temporário
        'sender': {'id': _myUserId},
        'recipient': {'id': widget.otherUserId},
        'type': 'text',
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      setState(() {
        messages.add(tempMsg);
        _messageIds.add(tempMsg['id'] as int);
      });
      
      // Scroll para o final
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    
    // Envia via WebSocket
    widget.chatService.sendMessage(widget.otherUserId, text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.otherName.isEmpty ? 'Usuário' : widget.otherName;
    
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () => _showUserProfile(context),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.otherPhoto != null && widget.otherPhoto!.isNotEmpty
                    ? NetworkImage(widget.otherPhoto!)
                    : null,
                child: widget.otherPhoto == null || widget.otherPhoto!.isEmpty
                    ? Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayName, 
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.call),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final m = messages[i];
                final sender = m['sender'] ?? {};
                final sid = sender['id'];
                final isMe = _myUserId != null && (sid is int ? sid == _myUserId : int.tryParse('$sid') == _myUserId);
                final msgType = (m['type'] ?? 'text').toString();
                Widget bubbleChild;
                if (msgType == 'imovel') {
                  final data = m['data'] as Map?;
                  final imovelId = data != null ? (data['imovel_id'] as int? ?? int.tryParse('${data['imovel_id']}') ) : null;
                  bubbleChild = _ImovelCardInline(
                    imovelId: imovelId,
                    token: widget.token,
                    onOpen: () async {
                      if (imovelId == null) return;
                      // Mostrar loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );
                      try {
                        final uri = Uri.parse('$backendHost/propriedades/propriedades/$imovelId/');
                        final resp = await http.get(uri, headers: {
                          'Authorization': 'Bearer ${widget.token}',
                        });
                        if (mounted) Navigator.of(context).pop(); // Fechar loading
                        if (resp.statusCode >= 200 && resp.statusCode < 300) {
                          final map = jsonDecode(resp.body) as Map<String, dynamic>;
                          if (mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ImovelDetalhePage(imovel: map)),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Imóvel não encontrado')),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) Navigator.of(context).pop(); // Fechar loading se aberto
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Erro ao carregar imóvel')),
                          );
                        }
                      }
                    },
                  );
                } else {
                  bubbleChild = Text(
                    m['text'] ?? '',
                    style: GoogleFonts.poppins(color: isMe ? Colors.white : Colors.black87),
                  );
                }
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF6E56CF) : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: bubbleChild,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FA),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Escreva uma mensagem...',
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _send,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4BD37B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ImovelCardInline extends StatelessWidget {
  final int? imovelId;
  final String token;
  final VoidCallback onOpen;
  const _ImovelCardInline({required this.imovelId, required this.token, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Imóvel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            leading: const Icon(Icons.home_work_outlined),
            title: Text(imovelId != null ? 'Imóvel #$imovelId' : 'Imóvel'),
            subtitle: const Text('Toque para ver detalhes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpen,
          ),
        ),
      ],
    );
  }
}
