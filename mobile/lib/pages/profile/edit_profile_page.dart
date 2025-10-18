// edit_profile_page.dart
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  DateTime? _birth;
  Uint8List? _avatarBytes;
  String? _avatarUrl;
  final ImagePicker _picker = ImagePicker();
  String? _normalizeAvatarUrl(String? url) {
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
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    final token = await AuthService.getSavedToken();
    if (token == null) return;
    final me = await AuthService.me(token: token);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _nameCtrl.text = (me?['username'] ?? '') as String;
      _emailCtrl.text = (me?['email'] ?? '') as String;
      _cpfCtrl.text = (me?['cpf'] ?? '') as String;
  _avatarUrl = _normalizeAvatarUrl((me?['avatar'] ?? '') as String?);
      try {
        final d = me?['data_nascimento'];
        if (d is String && d.isNotEmpty) _birth = DateTime.parse(d);
      } catch (_) {}
    });
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _avatarBytes = bytes);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final token = await AuthService.getSavedToken();
    if (token == null) return;

    final body = <String, dynamic>{
      'username': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'cpf': _cpfCtrl.text.trim(),
      'data_nascimento': _birth != null ? _birth!.toIso8601String().substring(0, 10) : null,
    }..removeWhere((k, v) => v == null || (v is String && v.isEmpty));

    try {
      final url = Uri.parse('$backendHost/usuarios/me/');
      http.Response resp;
      if (_avatarBytes != null) {
        // enviar multipart PATCH
        final req = http.MultipartRequest('PATCH', url);
        req.headers['Authorization'] = 'Bearer $token';
        body.forEach((k, v) => req.fields[k] = v.toString());
        req.files.add(http.MultipartFile.fromBytes(
          'avatar',
          _avatarBytes!,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
        final streamed = await req.send();
        resp = await http.Response.fromStream(streamed);
      } else {
        resp = await http.patch(url, headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}, body: jsonEncode(body));
      }
      if (resp.statusCode == 200) {
        final respData = jsonDecode(resp.body) as Map<String, dynamic>;
        // if server returned avatar url, update local preview
        if (respData['avatar'] != null && (respData['avatar'] as String).isNotEmpty) {
          _avatarUrl = _normalizeAvatarUrl(respData['avatar'] as String);
        }
        Navigator.pop(context, respData);
      } else if (resp.statusCode == 401) {
        await AuthService.logout();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar perfil')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro na requisição')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _cpfCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      appBar: AppBar(title: const Text('Editar perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey.withValues(alpha: 0.35),
                          backgroundImage: _avatarBytes != null
                              ? MemoryImage(_avatarBytes!)
                              : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                  ? NetworkImage(_avatarUrl!) as ImageProvider
                                  : null,
                          child: (_avatarBytes == null && (_avatarUrl == null || _avatarUrl!.isEmpty))
                              ? Text(
                                  _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : '?',
                                  style: GoogleFonts.roboto(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nome completo'),
                        validator: (v) => v == null || v.isEmpty ? 'Informe seu nome' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) => v == null || v.isEmpty ? 'Informe seu email' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cpfCtrl,
                        decoration: const InputDecoration(labelText: 'CPF'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(_birth != null ? _birth!.toLocal().toIso8601String().substring(0, 10) : 'Data de nascimento'),
                          ),
                          TextButton(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _birth ?? DateTime(1995, 1, 1),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (d != null && mounted) setState(() => _birth = d);
                              },
                              child: const Text('Selecionar'))
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB268B4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: _saving ? null : _save,
                          child: Text(
                            _saving ? 'Salvando...' : 'Salvar',
                            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
