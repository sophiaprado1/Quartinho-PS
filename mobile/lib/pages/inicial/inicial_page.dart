import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InicialPage extends StatelessWidget {
  const InicialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      appBar: AppBar(
        title: Text(
          "Inicial",
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF8533),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Bem-vindo ao Quartinho! 🏠",
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}