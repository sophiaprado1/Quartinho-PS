import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/pages/home_page.dart';

class ButtonLogin extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController senhaController;

  const ButtonLogin({
    super.key, // Use super parameter
    required this.emailController,
    required this.senhaController,
  });

  @override
  State<ButtonLogin> createState() => _ButtonLoginState();
}

class _ButtonLoginState extends State<ButtonLogin> {
  bool loading = false;

  void _login() async {
    setState(() => loading = true);
    final email = widget.emailController.text;
    final senha = widget.senhaController.text;

    final token = await AuthService.login(username: email, senha: senha); // Use correct parameter

    if (!mounted) return; // Guard context usage

    setState(() => loading = false);

    if (token != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login realizado com sucesso!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(token: token),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email ou senha inválidos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF8533),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _login,
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
