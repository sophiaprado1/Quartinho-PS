import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputRightIcon extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const InputRightIcon({
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    super.key,
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
          color: Colors.black.withAlpha(115),
        ),
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF2F3F9),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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