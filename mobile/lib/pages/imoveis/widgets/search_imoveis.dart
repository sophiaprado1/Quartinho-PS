import 'package:flutter/material.dart';

class SearchImoveis extends StatelessWidget {
  const SearchImoveis({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Procure por kitnet, casa...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Color(0xFFF5F5F7),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          // Aqui você pode filtrar a lista de imóveis em tempo real
        },
      ),
    );
  }
}
