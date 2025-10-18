// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'criar_imovel_fotos_page.dart';

class CriarImovelLocalizacaoPage extends StatefulWidget {
  final Map<String, dynamic> dadosIniciais;
  const CriarImovelLocalizacaoPage({super.key, required this.dadosIniciais});

  @override
  State<CriarImovelLocalizacaoPage> createState() => _CriarImovelLocalizacaoPageState();
}

class _CriarImovelLocalizacaoPageState extends State<CriarImovelLocalizacaoPage> {
  final _enderecoCtrl = TextEditingController();

  static const Color _bgPage = Color(0xFFF3F4F7);
  static const Color _accent = Color(0xFFFF8A34);
  static const Color _textDark = Color(0xFF1B1D28);
  static const Color _pill = Color(0xFFF5F4FA);
  static const Color _purple = Color(0xFF6E56CF);

  @override
  void dispose() {
    _enderecoCtrl.dispose();
    super.dispose();
  }

  Future<void> _irParaFotos() async {
    if (_enderecoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o endereço do imóvel.')),
      );
      return;
    }

    final parcial = {
      ...widget.dadosIniciais,
      'endereco': _enderecoCtrl.text.trim(),
      // se futuramente tiver lat/lng, inclua aqui
    };

    // ⚠️ IMPORTANTE: aguarde o resultado da próxima tela
    final resultado = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => CriarImovelFotosPage(dadosParciais: parcial),
      ),
    );

    // Se voltou com dados, devolve para quem abriu esta tela
    if (resultado != null) {
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
                'Qual é o endereço?',
                style: GoogleFonts.poppins(
                  color: _textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // "Pílula" com endereço digitado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _pill,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.location_on_outlined, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _enderecoCtrl,
                        maxLines: 2,
                        style: GoogleFonts.poppins(fontSize: 13.5, height: 1.3),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Condomínio dos Jacarés, avenida das Rosas,\nNúmero 66. 77025-666',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.black.withValues(alpha: .45),
                            fontSize: 13.5,
                            height: 1.3,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Mapa "fake" (placeholder visual)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFECEBFF), Color(0xFFFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // marcador
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _purple.withValues(alpha: .20),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF8A34),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.circle, size: 8, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      // botão "Selecionar no mapa" (placeholder)
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // implemente aqui a seleção no mapa quando tiver o plugin
                          },
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .92),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Selecionar no mapa',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                  onPressed: _irParaFotos,
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
}