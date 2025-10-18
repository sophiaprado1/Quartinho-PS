import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            backgroundColor: Color(0xFFCBACFF),
            child: Text(
              _getInitial(dono),
              style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dono['first_name']?.isNotEmpty == true
                      ? dono['first_name']
                      : dono['username'] ?? '',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF23235B)),
                ),
                if (dono['bio'] != null && dono['bio'].toString().isNotEmpty)
                  Text(
                    dono['bio'],
                    style: GoogleFonts.lato(fontSize: 14, color: Color(0xFF23235B).withOpacity(0.7)),
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
    final firstName = dono['first_name']?.toString() ?? '';
    final username = dono['username']?.toString() ?? '';
    if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (username.isNotEmpty) {
      return username[0].toUpperCase();
    } else {
      return '?';
    }
  }
}
