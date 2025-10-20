import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../search_results_page.dart';          // <-- 1 nível acima (imoveis/)
import '../../login/login_home_page.dart';     // <-- 2 níveis acima (pages/)
import '../../../core/services/auth_service.dart'; // <-- 3 níveis acima até lib/core/

class SearchImoveis extends StatefulWidget {
  const SearchImoveis({super.key});

  @override
  State<SearchImoveis> createState() => _SearchImoveisState();
}

class _SearchImoveisState extends State<SearchImoveis> {
  final _controller = TextEditingController();

  Future<void> _openSearch() async {
    final token = await AuthService.getSavedToken();
    if (!mounted) return; // evita use_build_context_synchronously
    if (token == null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginHomePage()));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(
          token: token,
          initialQuery: _controller.text.trim(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        readOnly: true,            // abre a tela dedicada de busca
        onTap: _openSearch,
        decoration: InputDecoration(
          hintText: 'Procure por kitnet, casa…',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.withAlpha(153), // 0.60 * 255 (evita deprec. withOpacity)
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF5F5F7),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}