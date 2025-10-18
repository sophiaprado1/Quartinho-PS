import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'criar_imovel_detalhes_page.dart';

class CriarImovelFotosPage extends StatefulWidget {
  final Map<String, dynamic> dadosParciais;
  const CriarImovelFotosPage({super.key, required this.dadosParciais});

  @override
  State<CriarImovelFotosPage> createState() => _CriarImovelFotosPageState();
}

class _CriarImovelFotosPageState extends State<CriarImovelFotosPage> {
  static const Color _bgPage = Color(0xFFF3F4F7);
  static const Color _accent = Color(0xFFFF8A34);
  static const Color _textDark = Color(0xFF1B1D28);
  static const Color _purple = Color(0xFF6E56CF);

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _fotos = [];

  Future<void> _adicionarFoto() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _fotos.add(picked));
    }
  }

  void _removerFoto(int index) {
    setState(() => _fotos.removeAt(index));
  }

  Future<void> _proximo() async {
    if (_fotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos uma foto.')),
      );
      return;
    }

    final parcial = {
      ...widget.dadosParciais,
      'fotos_paths': _fotos.map((f) => f.path).toList(),
    };

    // ⚠️ IMPORTANTE: aguarde a tela de Detalhes e propague o resultado pra trás
    final resultado = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => CriarImovelDetalhesPage(dadosParciais: parcial),
      ),
    );

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicione fotos para seu\nanúncio',
                style: GoogleFonts.poppins(
                  color: _textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  itemCount: _fotos.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    if (index == _fotos.length) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _adicionarFoto,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .06),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F1F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add, size: 26),
                            ),
                          ),
                        ),
                      );
                    }

                    final file = _fotos[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Image.file(
                              File(file.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: InkWell(
                            onTap: () => _removerFoto(index),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _purple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

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
                  onPressed: _proximo,
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