import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/pages/inicial/inicial_page.dart';

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

    // Debug: mostrar qual URL será usada e confirmar que o botão foi pressionado
    final debugUrl = '${AuthService.baseUrl}/usuarios/login/';
    print('Botão de login pressionado. Tentando POST para: $debugUrl');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tentando conectar em: $debugUrl')),
      );
    }

    try {
      final result = await AuthService.login(email: email, senha: senha);

      if (!mounted) return; // Guard context usage
      setState(() => loading = false);

      if (result != null && result['token'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login realizado com sucesso!')),
        );

        final user = result['user'] as Map<String, dynamic>?;
        final name = user != null ? (user['username'] ?? user['full_name'] ?? '') : '';
        final emailMe = user != null ? (user['email'] ?? email) : email;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InicialPage(
              name: name.isNotEmpty ? name : emailMe.split('@').first,
              city: '', // cidade pode ser preenchida depois pelo usuário/perfil
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email ou senha inválidos')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de rede ao tentar login. Verifique sua conexão.')),
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
