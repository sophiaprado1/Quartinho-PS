import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/services/auth_service.dart';
import '../../core/constants.dart';
import 'package:mobile/pages/login/login_home_page.dart';
import 'package:mobile/pages/profile/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final token = await AuthService.getSavedToken();
    if (token == null) {
      setState(() => loading = false);
      return;
    }
    final me = await AuthService.me(token: token);
    setState(() {
      user = me;
      loading = false;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginHomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    String? normalizeAvatar(String? url) {
      if (url == null || url.isEmpty) return null;
      try {
        final backendUri = Uri.parse(backendHost);
        final u = Uri.parse(url);
        final ts = DateTime.now().millisecondsSinceEpoch.toString();
        if (!u.hasScheme) {
          final path = url.startsWith('/') ? url : '/$url';
          return '${backendHost}${path}?t=$ts';
        }
        if (u.host != backendUri.host) {
          final newUri = Uri(
            scheme: backendUri.scheme,
            host: backendUri.host,
            port: backendUri.hasPort ? backendUri.port : null,
            path: u.path,
            queryParameters: {'t': ts},
          );
          return newUri.toString();
        }
        return url.contains('?') ? '$url&t=$ts' : '$url?t=$ts';
      } catch (_) {
        return url;
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFCBACFF),
          backgroundImage: (user != null && (user!['avatar'] ?? '').toString().isNotEmpty)
            ? NetworkImage(normalizeAvatar((user!['avatar'] ?? '').toString())!) as ImageProvider
            : null,
                    child: (user == null || (user!['avatar'] ?? '').toString().isEmpty)
                        ? Text(
                            _initial(),
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName(),
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF23235B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    userEmail(),
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: const Color(0xFF23235B).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Editar perfil'),
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfilePage()),
                      );
                      if (updated != null) {
                        _loadUser();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado')));
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Configurações'),
                    onTap: () {},
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6363),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sair'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _initial() {
    final n = userName();
    return n.isNotEmpty ? n[0].toUpperCase() : '?';
  }

  String userName() {
    final u = user ?? {};
    final fn = (u['first_name'] ?? '').toString();
    final un = (u['username'] ?? '').toString();
    return fn.isNotEmpty ? fn : un;
  }

  String userEmail() {
    final u = user ?? {};
    return (u['email'] ?? '').toString();
  }
}