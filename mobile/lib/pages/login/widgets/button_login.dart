import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonLogin extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController senhaController;

  const ButtonLogin({
    super.key,
    required this.emailController,
    required this.senhaController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF8533),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          final email = emailController.text.trim();
          final senha = senhaController.text.trim();

          if (email.isEmpty || senha.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Preencha e-mail e senha!')),
            );
            return;
          }
          // Aqui você pode chamar sua função de autenticação
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login válido!')),
          );
        },
        child: Text(
          'Entrar',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
