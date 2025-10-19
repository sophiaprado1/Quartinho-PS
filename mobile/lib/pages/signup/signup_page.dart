import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/pages/login/login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _birthCtrl = TextEditingController(); // exibe a data formatada

  DateTime? _birthDate;
  bool showPassword = false;
  bool _loading = false;

  // cores
  static const Color bgPage = Color(0xFFF3F4F7);
  static const Color fieldBg = Color(0xFFF2F3F9);
  static const Color accent = Color(0xFFFF8533);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _cpfCtrl.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 100, 1, 1);
    final last = now;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: first,
      lastDate: last,
      helpText: 'Selecione sua data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  String? _validateCpf(String? v) {
    if (v == null || v.isEmpty) return 'Informe seu CPF';
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 11) return 'CPF deve ter 11 dígitos';
    return null;
  }

  String? _validateBirth(String? _) {
    if (_birthDate == null) return 'Informe sua data de nascimento';
    final now = DateTime.now();
    var age = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month ||
        (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      age--;
    }
    if (age < 16) return 'Idade mínima: 16 anos';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // Montei o payload redundante para bater com possíveis campos do backend:
    final payload = <String, dynamic>{
      // você usava 'nome_completo'; adiciono 'full_name' e 'username' também
      'nome_completo': _nameCtrl.text.trim(),
      'full_name': _nameCtrl.text.trim(),
      'username': _nameCtrl.text.trim(),

      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'cpf': _cpfCtrl.text.trim(),
      'data_nascimento': _birthDate != null
          ? '${_birthDate!.year.toString().padLeft(4, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
          : null,
    }..removeWhere((k, v) => v == null);

    final uri = Uri.parse('${AuthService.baseUrl}/usuarios/usercreate/');

    try {
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      // Debug opcional:
      // print('[SIGNUP] ${resp.statusCode} ${resp.body}');

      setState(() => _loading = false);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso. Faça login.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
          (route) => false,
        );
      } else {
        String msg = 'Erro ao cadastrar usuário';
        try {
          final data = jsonDecode(resp.body);
          if (data is Map && data['detail'] != null) {
            msg = data['detail'].toString();
          } else if (data is Map && data.isNotEmpty) {
            // junta mensagens de campo: {"email":["já existe"], "password":["fraca"]}
            msg = data.entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n');
          } else if (data is List && data.isNotEmpty) {
            msg = data.join('\n');
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on SocketException {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem conexão. Verifique Wi-Fi/dados e o IP do backend.')),
      );
    } on HttpException {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha HTTP ao conectar no servidor.')),
      );
    } on FormatException {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resposta inválida do servidor.')),
      );
    } on TimeoutException {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tempo esgotado. O servidor não respondeu.')),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: BackPillButton(),
                  ),
                  Text(
                    'Crie sua conta',
                    style: GoogleFonts.roboto(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conte um pouquinho sobre você',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.55),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nome
                  _InputRightIcon(
                    controller: _nameCtrl,
                    hint: 'Marta Ferreira',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Informe seu nome' : null,
                  ),
                  const SizedBox(height: 12),

                  // Email
                  _InputRightIcon(
                    controller: _emailCtrl,
                    hint: 'ferreira.marta@uft.edu.br',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe seu e-mail';
                      if (!v.contains('@')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // CPF
                  _InputRightIcon(
                    controller: _cpfCtrl,
                    hint: '000.000.000-00',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    validator: _validateCpf,
                  ),
                  const SizedBox(height: 12),

                  // Data de nascimento (readOnly + datepicker)
                  TextFormField(
                    controller: _birthCtrl,
                    readOnly: true,
                    validator: _validateBirth,
                    style: GoogleFonts.lato(),
                    onTap: _pickBirthDate,
                    decoration: InputDecoration(
                      hintText: 'DD/MM/AAAA',
                      hintStyle: GoogleFonts.lato(
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: fieldBg,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.calendar_today_outlined, size: 20),
                      ),
                      suffixIconConstraints:
                          const BoxConstraints(minWidth: 0, minHeight: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Senha
                  _InputRightIcon(
                    controller: _passwordCtrl,
                    hint: '****************',
                    icon: Icons.lock_outline,
                    obscure: !showPassword,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe a senha';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: _flatBtnStyle,
                        onPressed: () {},
                        child: Text(
                          'Termos de serviço',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      TextButton(
                        style: _flatBtnStyle,
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                        child: Text(
                          showPassword ? 'Ocultar senha' : 'Mostrar senha',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 280,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: _loading ? null : _submit,
                        child: Text(
                          _loading ? 'Enviando...' : 'Registre-se!',
                          style: GoogleFonts.lato(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: .2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle get _flatBtnStyle => TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
}

/// Botão de voltar em formato pill
class BackPillButton extends StatelessWidget {
  final VoidCallback? onTap;
  const BackPillButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.06),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap ?? () => Navigator.pop(context),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
      ),
    );
  }
}

/// Campo de input com ícone à direita
class _InputRightIcon extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const _InputRightIcon({
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: GoogleFonts.lato(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(
          color: Colors.black.withValues(alpha: 0.45),
        ),
        isDense: true,
        filled: true,
        fillColor: _SignUpPageState.fieldBg,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(icon, size: 20),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}