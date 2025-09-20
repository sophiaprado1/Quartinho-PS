import 'package:flutter/material.dart';

class InputsLogin extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController senhaController;

  const InputsLogin({
    super.key,
    required this.emailController,
    required this.senhaController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de e-mail
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'E-mail',
            hintText: 'Digite seu e-mail',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor:  Color(0xFFF2F3F9),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Informe seu e-mail';
            }
            if (!value.contains('@')) {
              return 'E-mail inválido';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        // Campo de senha
        TextFormField(
          controller: senhaController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Senha',
            hintText: 'Digite sua senha',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor:  Color(0xFFF2F3F9),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Informe sua senha';
            }
            if (value.length < 6) {
              return 'Senha muito curta';
            }
            return null;
          },
        ),
      ],
    );
  }
}