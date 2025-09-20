import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;

  const RegisterButton({
    super.key,
    required this.onPressed,
    this.color = const Color(0xFFFF8533),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: onPressed,
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
    );
  }
}