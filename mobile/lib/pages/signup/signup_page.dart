import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/pages/choose_role/choose_role_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // controllers para manter o texto ao voltar
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool showPassword = false;

  // cores de layout
  static const Color bgPage = Color(0xFFF3F4F7);
  static const Color fieldBg = Color(0xFFF2F3F9);
  static const Color accent = Color(0xFFFF8533);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
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
                  // Botão de voltar (pill)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: BackPillButton(),
                  ),

                  // título — Roboto
                  Text(
                    'Crie sua conta',
                    style: GoogleFonts.roboto(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // subtítulo — Lato
                  Text(
                    'Conte um pouquinho sobre você',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.55),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campos
                  _InputRightIcon(
                    controller: _nameCtrl,
                    hint: 'Marta Ferreira',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Informe seu nome" : null,
                  ),
                  const SizedBox(height: 12),

                  _InputRightIcon(
                    controller: _emailCtrl,
                    hint: 'ferreira.marta@uft.edu.br',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Informe seu e-mail";
                      if (!v.contains("@")) return "E-mail inválido";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  _InputRightIcon(
                    controller: _passwordCtrl,
                    hint: '****************',
                    icon: Icons.lock_outline,
                    obscure: !showPassword,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Informe a senha";
                      if (v.length < 6) return "Mínimo 6 caracteres";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Linha inferior
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

                  // Botão principal
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChooseRolePage(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Registre-se!',
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