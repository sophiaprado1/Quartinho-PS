import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';

class DonoImovelPerfil extends StatelessWidget {
  final Map dono;
  const DonoImovelPerfil({super.key, required this.dono});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0XFFf5f4f8),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFCBACFF),
            backgroundImage: _avatarProvider(dono),
            child: _avatarProvider(dono) == null
                ? Text(
                    _getInitial(dono),
                    style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDisplayName(dono),
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 17, color: const Color(0xFF23235B)),
                ),
                // subtitle: prefer occupation/role, then bio, then email
                if (_getSubtitle(dono).isNotEmpty)
                  Text(
                    _getSubtitle(dono),
                    style: GoogleFonts.lato(fontSize: 14, color: const Color(0xFF23235B).withOpacity(0.7)),
                  ),
              ],
            ),
          ),
          Icon(Icons.chat_bubble_outline, color: Color(0xFFCBACFF)),
        ],
      ),
    );
  }

  String _getInitial(Map dono) {
    final display = _getDisplayName(dono);
    if (display.isNotEmpty) return display[0].toUpperCase();
    return '?';
  }

  String _getDisplayName(Map dono) {
    // try different keys the backend might return
    final nomeCompleto = dono['nome_completo']?.toString() ?? '';
    if (nomeCompleto.isNotEmpty) return nomeCompleto;
    final firstName = dono['first_name']?.toString() ?? '';
    if (firstName.isNotEmpty) return firstName;
    final username = dono['username']?.toString() ?? '';
    if (username.isNotEmpty) return username;
    final email = dono['email']?.toString() ?? '';
    if (email.isNotEmpty) return email.split('@').first;
    return '';
  }

  ImageProvider? _avatarProvider(Map dono) {
    try {
      final avatar = dono['avatar'] ?? dono['avatar_url'] ?? dono['foto'] ?? dono['imagem'];
      if (avatar == null) return null;
      final s = avatar.toString();
      if (s.isEmpty) return null;
      if (s.startsWith('http')) return NetworkImage(s);
      final path = s.startsWith('/') ? s : '/$s';
      return NetworkImage(backendHost + path);
    } catch (_) {
      return null;
    }
  }

  String _getSubtitle(Map dono) {
    final ocupacao = dono['ocupacao']?.toString() ?? dono['role']?.toString() ?? dono['cargo']?.toString() ?? '';
    if (ocupacao.isNotEmpty) return ocupacao;
    final bio = dono['bio']?.toString() ?? '';
    if (bio.isNotEmpty) return bio;
    final email = dono['email']?.toString() ?? '';
    if (email.isNotEmpty) return email;
    return '';
  }
}
