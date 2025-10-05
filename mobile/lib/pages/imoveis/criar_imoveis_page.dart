// criar_imoveis_page.dart
// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'criar_imovel_localizacao_page.dart';

class CriarImoveisPage extends StatefulWidget {
  final String firstName; // opcional, para mostrar "Oi, {nome}!"
  const CriarImoveisPage({super.key, this.firstName = ''});

  @override
  State<CriarImoveisPage> createState() => _CriarImoveisPageState();
}

class _CriarImoveisPageState extends State<CriarImoveisPage> {
  final _tituloCtrl = TextEditingController();

  int _listingType = 0; // 0 = Colega de quarto, 1 = República
  int _tipoImovel = 0;  // 0 = Apartamento, 1 = Casa, 2 = Kitnet

  static const Color _bgPage = Color(0xFFF3F4F7);
  static const Color _accent = Color(0xFFFF8A34);
  static const Color _textDark = Color(0xFF1B1D28);

  @override
  void dispose() {
    _tituloCtrl.dispose();
    super.dispose();
  }

  String get _helloName {
    final n = widget.firstName.trim();
    if (n.isEmpty) return '';
    return n[0].toUpperCase() + n.substring(1);
  }

  Future<void> _onNext() async {
    if (_tituloCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dê um título para o seu anúncio.')),
      );
      return;
    }

    final payload = <String, dynamic>{
      'titulo': _tituloCtrl.text.trim(),
      'listing_type': _listingType == 0 ? 'colega_de_quarto' : 'republica',
      'tipo_imovel': ['apartamento', 'casa', 'kitnet'][_tipoImovel],
    };

    // Navega para Localização e espera o resultado final do fluxo.
    final resultado = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => CriarImovelLocalizacaoPage(dadosIniciais: payload),
      ),
    );

    if (resultado != null) {
      // Devolve para quem abriu (InicialPage)
      Navigator.pop(context, resultado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        backgroundColor: _bgPage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Adicionar listagem',
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _helloName.isEmpty
                    ? 'Oi! Conte mais sobre seu imóvel'
                    : 'Oi, $_helloName! Conte mais sobre seu imóvel',
                style: GoogleFonts.poppins(
                  color: _textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 18),

              _RoundedTextField(
                controller: _tituloCtrl,
                hintText: 'Quarto com varanda',
                suffix: const Icon(Icons.home_outlined, color: _textDark),
              ),
              const SizedBox(height: 24),

              Text('Listing type', style: _sectionTitle),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Pill(
                    text: 'Colega de quarto',
                    selected: _listingType == 0,
                    onTap: () => setState(() => _listingType = 0),
                  ),
                  _Pill(
                    text: 'República',
                    selected: _listingType == 1,
                    onTap: () => setState(() => _listingType = 1),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text('Tipo de imóvel', style: _sectionTitle),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Pill(
                    text: 'Apartamento',
                    selected: _tipoImovel == 0,
                    onTap: () => setState(() => _tipoImovel = 0),
                  ),
                  _Pill(
                    text: 'Casa',
                    selected: _tipoImovel == 1,
                    onTap: () => setState(() => _tipoImovel = 1),
                  ),
                  _Pill(
                    text: 'Kitnet',
                    selected: _tipoImovel == 2,
                    onTap: () => setState(() => _tipoImovel = 2),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _onNext,
                  child: Text(
                    'Próximo',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _sectionTitle => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textDark,
      );
}

/// ---------- Widgets auxiliares ----------
class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? suffix;

  const _RoundedTextField({
    required this.controller,
    required this.hintText,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: Colors.black.withValues(alpha: .45),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F4FA),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: suffix == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffix,
              ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  static const Color _selected = Color(0xFF6E56CF);
  static const Color _unselected = Color(0xFFF0F1F5);
  static const Color _textDark = Color(0xFF1B1D28);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _selected : _unselected,
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _selected.withValues(alpha: .25),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : _textDark,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}