import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/services/auth_service.dart';

class ComentariosSection extends StatefulWidget {
  final dynamic imovelId;
  const ComentariosSection({super.key, required this.imovelId});

  @override
  State<ComentariosSection> createState() => _ComentariosSectionState();
}

class _ComentariosSectionState extends State<ComentariosSection> {
  List<dynamic> comentarios = [];
  final _controller = TextEditingController();
  bool _loading = false;
  int? _myUserId;
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _fetchComentarios();
    _loadCurrentUser();
  }

  String _getAuthorDisplayName(dynamic autor) {
    try {
      if (autor == null) return 'Usuário';
      if (autor is Map) {
        final nomeCompleto = (autor['nome_completo'] ?? '').toString();
        if (nomeCompleto.isNotEmpty) return nomeCompleto;
        final firstName = (autor['first_name'] ?? '').toString();
        if (firstName.isNotEmpty) return firstName;
        final username = (autor['username'] ?? '').toString();
        if (username.isNotEmpty) return username;
        final email = (autor['email'] ?? '').toString();
        if (email.isNotEmpty) return email.contains('@') ? email.split('@').first : email;
        return 'Usuário';
      } else {
        final s = autor.toString();
        if (s.isEmpty) return 'Usuário';
        if (s.contains('@')) return s.split('@').first;
        return s;
      }
    } catch (_) {
      return 'Usuário';
    }
  }

  String _formatDate(dynamic raw) {
    try {
      if (raw == null) return '';
      final s = raw.toString();
      if (s.isEmpty) return '';
      final dt = DateTime.parse(s).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inSeconds < 10) return 'agora';
      if (diff.inSeconds < 60) return 'há ${diff.inSeconds} segundos';
      if (diff.inMinutes < 60) return 'há ${diff.inMinutes} minutos';
      if (diff.inHours < 24) return 'há ${diff.inHours} horas';
      if (diff.inDays < 7) return 'há ${diff.inDays} dias';
      if (diff.inDays < 30) return 'há ${ (diff.inDays / 7).floor() } semanas';
      // fallback para data completa se for muito antiga
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yy = dt.year.toString();
      return '$dd/$mm/$yy';
    } catch (_) {
      return raw?.toString() ?? '';
    }
  }

  Future<void> _fetchComentarios() async {
    setState(() => _loading = true);
    try {
      final url = Uri.parse('$backendHost/propriedades/comentarios/?imovel=${widget.imovelId}');
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        setState(() => comentarios = jsonDecode(resp.body) as List<dynamic>);
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadCurrentUser() async {
    final token = await AuthService.getSavedToken();
    if (token == null) return;
    final me = await AuthService.me(token: token);
    if (me != null && me['id'] != null) {
      setState(() => _myUserId = me['id'] as int);
    }
  }

  Future<void> _postComentario() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final token = await AuthService.getSavedToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faça login para comentar')));
      return;
    }
    final url = Uri.parse('$backendHost/propriedades/comentarios/');
    final resp = await http.post(url,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}, body: jsonEncode({'imovel': widget.imovelId, 'texto': text, 'nota': _selectedRating}));
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      _controller.clear();
      setState(() => _selectedRating = 5);
      _fetchComentarios();
      _loadCurrentUser();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao publicar comentário')));
    }
  }

  String? _normalizeAvatarUrl(dynamic avatarField) {
    try {
      if (avatarField == null) return null;
      final s = avatarField.toString();
      if (s.isEmpty) return null;
      if (s.startsWith('http')) return s;
      final path = s.startsWith('/') ? s : '/$s';
      return '$backendHost$path';
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteComentario(int id) async {
    final token = await AuthService.getSavedToken();
    if (token == null) return;
    final url = Uri.parse('$backendHost/propriedades/comentarios/$id/');
    final resp = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    if (resp.statusCode == 204 || resp.statusCode == 200) {
      _fetchComentarios();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao deletar comentário')));
    }
  }

  Future<void> _editComentario(int id, String currentText) async {
    final token = await AuthService.getSavedToken();
    if (token == null) return;
    final textCtrl = TextEditingController(text: currentText);
    int editRating = 5;
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setStateDialog) => AlertDialog(
        title: const Text('Editar comentário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: textCtrl, maxLines: 5),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Nota: ', style: TextStyle(fontWeight: FontWeight.w600)),
              ...List.generate(5, (i) {
                final val = i + 1;
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(val <= editRating ? Icons.star : Icons.star_border, color: const Color(0xFFFFC107)),
                  onPressed: () => setStateDialog(() => editRating = val),
                );
              }),
            ])
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Salvar')),
        ],
      )),
    );
    if (res != true) return;
    final url = Uri.parse('$backendHost/propriedades/comentarios/$id/');
    final resp = await http.patch(url, headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}, body: jsonEncode({'texto': textCtrl.text, 'nota': editRating}));
    if (resp.statusCode == 200) {
      _fetchComentarios();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao editar comentário')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumo de avaliações (mover para cima do título 'Comentários' abaixo)
        if (comentarios.isNotEmpty) ...[
          Builder(builder: (ctx) {
            final notas = comentarios.map((c) => (c['nota'] ?? c['rating'] ?? 0) as int).where((n) => n > 0).toList();
            final count = notas.length;
            final avg = count > 0 ? (notas.reduce((a, b) => a + b) / count) : 0.0;
            // coletar avatares
            final avatars = <String>[];
            for (final c in comentarios) {
              final autor = c['autor'];
              if (autor is Map) {
                final av = autor['avatar'] ?? autor['avatar_url'] ?? autor['foto'];
                final url = _normalizeAvatarUrl(av);
                if (url != null) avatars.add(url);
              }
              if (avatars.length >= 3) break;
            }
            return Card(
              color: const Color(0xFFFBEAFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 36, color: Color(0xFFFFC107)),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(avg > 0 ? avg.toStringAsFixed(1) : '0.0', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text(count > 0 ? 'De $count usuários' : 'Sem avaliações', style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[700])),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: avatars.map((a) => Padding(padding: const EdgeInsets.only(right: 6), child: CircleAvatar(radius: 12, backgroundImage: NetworkImage(a)))).toList()),
                    ])
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        Text('Comentários', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_loading) const Center(child: CircularProgressIndicator()),
        if (comentarios.isEmpty && !_loading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('Ainda não há comentários. Seja o primeiro a comentar!', style: GoogleFonts.lato(color: Colors.grey[700])),
          ),
        ...comentarios.map((c) {
          final id = c['id'];
          final author = _getAuthorDisplayName(c['autor']);
          final texto = c['texto'] ?? '';
          final nota = c['nota'] ?? c['rating'] ?? 0;
          final autorId = c['autor'] != null ? (c['autor']['id'] ?? c['autor']['pk']) : null;
          final isMine = autorId != null && _myUserId != null && autorId == _myUserId;
          return Card(
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(author),
                      Text(_formatDate(c['data_criacao']), style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(children: List.generate(5, (i) => Icon(i < (nota ?? 0) ? Icons.star : Icons.star_border, size: 16, color: const Color(0xFFFFC107)))),
                ],
              ),
              subtitle: Text(texto),
              trailing: isMine
                  ? PopupMenuButton<String>(onSelected: (v) async {
                      if (v == 'editar') await _editComentario(id, texto);
                      if (v == 'apagar') await _deleteComentario(id);
                    }, itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'editar', child: Text('Editar')),
                        const PopupMenuItem(value: 'apagar', child: Text('Apagar')),
                      ])
                  : null,
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
        // Rating selector
        Row(children: [
          const Text('Sua nota: ', style: TextStyle(fontWeight: FontWeight.w600)),
          ...List.generate(5, (i) {
            final val = i + 1;
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(val <= _selectedRating ? Icons.star : Icons.star_border, color: const Color(0xFFFFC107)),
              onPressed: () => setState(() => _selectedRating = val),
            );
          }),
        ]),

        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Adicione um comentário...'))),
          IconButton(onPressed: _postComentario, icon: const Icon(Icons.send))
        ]),
      ],
    );
  }
}
