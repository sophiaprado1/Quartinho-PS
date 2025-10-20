import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/pages/signup/extra_signup_page.dart';

class SkipPill extends StatelessWidget {
  final String name;
  final String email;
  final String cpf;
  final DateTime birthDate;
  final VoidCallback? onSkip; // opcional

  const SkipPill({
    super.key,
    required this.name,
    required this.email,
    required this.cpf,
    required this.birthDate,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (onSkip != null) {
          onSkip!();
          return;
        }
        // Fallback SEMPRE com todos os params:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ExtraSignUpPage(
      name: name,
      email: email,
      cpf: cpf,
      birthDate: birthDate,
      // city: null, // opcional
    ),
  ),
);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "skip",
          style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
        ),
      ),
    );
  }
}