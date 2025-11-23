import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';

class UserPerfilPage extends StatefulWidget {
  final int userId;
  final String token;

  const UserPerfilPage({super.key, required this.userId, required this.token});

  @override
  State<UserPerfilPage> createState() => _UserPerfilPageState();
}

class _UserPerfilPageState extends State<UserPerfilPage> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse('$backendHost/usuarios/${widget.userId}/');
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer ${widget.token}',
      });
      if (!mounted) return;
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        setState(() {
          _user = data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Não foi possível carregar o perfil (HTTP ${resp.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar perfil: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final u = _user ?? {};
    final nome = (u['nome'] ?? u['nome_completo'] ?? u['username'] ?? 'Usuário').toString();
    final email = (u['email'] ?? '').toString();
    final cidade = (u['cidade'] ?? '').toString();
    final telefone = (u['telefone'] ?? '').toString();
    final rawFoto = u['foto_perfil'] ?? u['avatar'];
    String? fotoUrl;
    if (rawFoto != null && rawFoto.toString().isNotEmpty) {
      final s = rawFoto.toString();
      if (s.startsWith('http')) {
        fotoUrl = s;
      } else if (s.startsWith('/')) {
        fotoUrl = '$backendHost$s';
      } else {
        fotoUrl = '$backendHost/media/$s';
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
                  child: fotoUrl == null
                      ? Text(
                          nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                          style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  nome,
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                if (cidade.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    cidade,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Informações de contato'),
          const SizedBox(height: 12),
          if (email.isNotEmpty)
            _InfoRow(icon: Icons.email_outlined, label: 'E-mail', value: email),
          if (telefone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.phone_outlined, label: 'Telefone', value: telefone),
          ],
          const SizedBox(height: 24),
          _SectionTitle('Sobre'),
          const SizedBox(height: 8),
          Text(
            'Informações adicionais sobre o usuário podem aparecer aqui no futuro.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF23235B)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6E56CF)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
