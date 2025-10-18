import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/pages/signup/widgets/buttom_back.dart';
import 'package:mobile/pages/imoveis/widgets/dono_imovel_perfil.dart';

class ImovelDetalhePage extends StatelessWidget {
  final Map imovel;
  const ImovelDetalhePage({super.key, required this.imovel});

  @override
  Widget build(BuildContext context) {
    final fotos = imovel['fotos'] as List<dynamic>?;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fotos != null && fotos.isNotEmpty)
              SizedBox(
                height: 240,
                width: double.infinity,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: fotos.length,
                      itemBuilder: (context, index) {
                        final img = fotos[index]['imagem'];
                        final url = (img != null && img.toString().isNotEmpty)
                            ? (img.toString().startsWith('http') ? img : 'http://localhost:8000$img')
                            : null;
                        return url != null
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Container(
                                color: Colors.white,
                                child: const Icon(Icons.image, size: 60),
                              );
                      },
                    ),
                    Positioned(
                      top: 32,
                      left: 8,
                      child: ButtomBack(),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                //Titulo do anincio
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    imovel['titulo'] ?? '',
                    style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF23235B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${imovel['preco_total'] ?? '-'} / mês',
                    style: GoogleFonts.lato(fontSize: 20, color: Color(0xFFCBACFF), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (imovel['descricao'] != null)
                    Text(
                      imovel['descricao'],
                      style: GoogleFonts.lato(fontSize: 16, color: Color(0xFF23235B)),
                    ),
                  // Card do dono 
                  if (imovel['dono'] != null) ...[
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: DonoImovelPerfil(dono: imovel['dono']),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (imovel['endereco'] != null)
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Color(0xFFCBACFF)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            imovel['endereco'],
                            style: GoogleFonts.lato(fontSize: 15, color: Color(0xFF23235B)),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (imovel['cidade'] != null)
                    Row(
                      children: [
                        Icon(Icons.location_city, color: Color(0xFFCBACFF)),
                        const SizedBox(width: 6),
                        Text(
                          imovel['cidade'],
                          style: GoogleFonts.lato(fontSize: 15, color: Color(0xFF23235B)),
                        ),
                      ],
                    ),
                  // Adicione mais informações detalhadas conforme desejar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
