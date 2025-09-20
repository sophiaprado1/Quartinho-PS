import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SkipPill extends StatelessWidget {
  const SkipPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "skip",
        style: GoogleFonts.lato(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}