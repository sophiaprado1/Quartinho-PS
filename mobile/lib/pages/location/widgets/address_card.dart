import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressCard extends StatelessWidget {
  final TextEditingController controller;

  const AddressCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.black54, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.lato(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Digite o endereço",
                hintStyle: GoogleFonts.lato(
                  fontSize: 15,
                  color: Colors.black45,
                ),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
        ],
      ),
    );
  }
}