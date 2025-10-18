// extra_signup_page.dart
// ignore: unnecessary_import
import 'dart:typed_data';
// ignore: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/pages/inicial/inicial_page.dart';
import 'package:mobile/pages/login/login.dart';

class ExtraSignUpPage extends StatefulWidget {
  final String name;
  final String email;
  final String cpf;
  final DateTime birthDate;
  final String? city;

  const ExtraSignUpPage({
    super.key,
    required this.name,
    required this.email,
    required this.cpf,
    required this.birthDate,
    this.city,
  });

  @override
  State<ExtraSignUpPage> createState() => _ExtraSignUpPageState();
}

class _ExtraSignUpPageState extends State<ExtraSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  Uint8List? _avatarBytes; // << vamos passar isso pra InicialPage
  final ImagePicker _picker = ImagePicker();
  bool _submitting = false;

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _avatarBytes = bytes);
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  String get _birthFormatted =>
      '${widget.birthDate.day.toString().padLeft(2, '0')}/${widget.birthDate.month.toString().padLeft(2, '0')}/${widget.birthDate.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 16),

                Text('Complete suas informações',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Você pode mudar essa configuração depois',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(fontSize: 14, color: Colors.black.withValues(alpha: 0.55))),
                const SizedBox(height: 24),

                // Avatar (editável)
                GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.withValues(alpha: 0.35),
                    backgroundImage: _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                    child: _avatarBytes == null
                        ? Text(
                            widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                            style: GoogleFonts.roboto(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 32),

                // Somente leitura
                _ReadonlyField(value: widget.name, icon: Icons.person_outline),
                const SizedBox(height: 12),
                _ReadonlyField(value: widget.email, icon: Icons.email_outlined),
                const SizedBox(height: 12),
                _ReadonlyField(value: widget.cpf, icon: Icons.badge_outlined),
                const SizedBox(height: 12),
                _ReadonlyField(value: _birthFormatted, icon: Icons.cake_outlined),
                const SizedBox(height: 12),

                // Telefone
                _InputField(
                  controller: _phoneCtrl,
                  hint: '+55 63 99999-9999',
                  icon: Icons.phone_outlined,
                  validator: (v) => v == null || v.isEmpty ? 'Informe seu telefone' : null,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 +()-]'))],
                  textInputAction: TextInputAction.done,
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
                    onPressed: _submitting
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _submitting = true);
                              _showSuccessBottomSheet(context).whenComplete(
                                () => setState(() => _submitting = false),
                              );
                            }
                          },
                    child: Text(
                      _submitting ? 'Enviando...' : 'Prontinho!',
                      style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSuccessBottomSheet(BuildContext context) async {
    FocusScope.of(context).unfocus(); // fecha teclado

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.40),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ mantém "check + tiny house" (assets)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFF3E0)),
                      child: Image.asset('assets/images/check.png', width: 56, height: 56),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Image.asset('assets/images/tinyhouse.png', width: 40, height: 40),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Text('Conta criada', style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('com sucesso!',
                    style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4C3F91))),
                const SizedBox(height: 8),

                Text('Agora é só procurar seu quartinho!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(fontSize: 14, color: Colors.black.withValues(alpha: 0.6))),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8533),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InicialPage(
                            name: widget.name,
                            city: widget.city ?? '',
                            avatarBytes: _avatarBytes,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text('Pronto', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ----- widgets auxiliares (iguais aos seus atuais) -----
class _ReadonlyField extends StatelessWidget {
  final String value;
  final IconData icon;
  const _ReadonlyField({required this.value, required this.icon});
  @override
  Widget build(BuildContext context) { /* ... igual ao seu ... */ return TextFormField(
    initialValue: value,
    readOnly: true,
    style: GoogleFonts.lato(),
    decoration: InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF2F3F9),
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );}
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
  });
  @override
  Widget build(BuildContext context) { /* ... igual ao seu ... */ return TextFormField(
    controller: controller,
    validator: validator,
    style: GoogleFonts.lato(),
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    textInputAction: textInputAction,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF2F3F9),
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );}
}