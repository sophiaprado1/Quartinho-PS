import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/pages/signup/widgets/buttom_back.dart';
import 'package:mobile/pages/imoveis/widgets/dono_imovel_perfil.dart';
import '../../core/constants.dart';

class ImovelDetalhePage extends StatelessWidget {
  final Map imovel;
  const ImovelDetalhePage({super.key, required this.imovel});

  @override
  Widget build(BuildContext context) {
  final fotos = imovel['fotos'] as List<dynamic>?;
  final fotosList = fotos ?? <dynamic>[];
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
                      itemCount: fotosList.length,
                      itemBuilder: (context, index) {
                        final item = fotosList[index];
                        String? raw;
                        if (item is Map) {
                          raw = item['imagem']?.toString();
                        } else if (item is String) {
                          raw = item;
                        } else {
                          // item might be an int id or unknown type -> no image
                          raw = null;
                        }

                        final url = (raw != null && raw.isNotEmpty)
                            ? (raw.startsWith('http') ? raw : '${backendHost}${raw}')
                            : null;

                        if (url != null) {
                          return ClipRRect(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        }

                        return Container(
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
                    'R\$ ${imovel['preco_total'] ?? imovel['preco'] ?? '-'} / mês',
                    style: GoogleFonts.lato(fontSize: 20, color: Color(0xFFCBACFF), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (imovel['descricao'] != null)
                    Text(
                      imovel['descricao'],
                      style: GoogleFonts.lato(fontSize: 16, color: Color(0xFF23235B)),
                    ),
                  // Card do dono 
                  if (imovel['dono'] is Map) ...[
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: DonoImovelPerfil(dono: imovel['dono']),
                    ),
                  ] else if (imovel['proprietario'] is Map) ...[
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: DonoImovelPerfil(dono: imovel['proprietario']),
                    ),
                  ] else if (imovel['dono'] != null || imovel['proprietario'] != null) ...[
                    const SizedBox(height: 18),
                    Text('Proprietário: ${imovel['dono'] ?? imovel['proprietario']}'),
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
                  const SizedBox(height: 12),
                  // Informações adicionais
                  Wrap(
                    runSpacing: 8,
                    spacing: 12,
                    children: [
                      if (imovel['quartos'] != null) _InfoChip(label: 'Quartos', value: imovel['quartos'].toString()),
                      if (imovel['banheiros'] != null) _InfoChip(label: 'Banheiros', value: imovel['banheiros'].toString()),
                      if (imovel['area'] != null) _InfoChip(label: 'Área', value: '${imovel['area']} m²'),
                      if (imovel['mobiliado'] != null) _InfoChip(label: 'Mobiliado', value: imovel['mobiliado'] ? 'Sim' : 'Não'),
                      if (imovel['aceita_pets'] != null) _InfoChip(label: 'Aceita pets', value: imovel['aceita_pets'] ? 'Sim' : 'Não'),
                      if (imovel['internet'] != null) _InfoChip(label: 'Internet', value: imovel['internet'] ? 'Sim' : 'Não'),
                      if (imovel['estacionamento'] != null) _InfoChip(label: 'Estacionamento', value: imovel['estacionamento'] ? 'Sim' : 'Não'),
                      if (imovel['estado'] != null) _InfoChip(label: 'Estado', value: imovel['estado'].toString()),
                      if (imovel['cep'] != null) _InfoChip(label: 'CEP', value: imovel['cep'].toString()),
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

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconForLabel(label),
          const SizedBox(width: 6),
          Text('$label: ', style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(value, style: GoogleFonts.lato(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _iconForLabel(String label) {
    final l = label.toLowerCase();
    IconData ic;
    if (l.contains('quartos') || l.contains('camas')) {
      ic = Icons.king_bed_outlined;
    } else if (l.contains('banheiro')) {
      ic = Icons.bathtub_outlined;
    } else if (l.contains('área') || l.contains('m²') || l.contains('area')) {
      ic = Icons.crop_square_outlined;
    } else if (l.contains('mobiliado')) {
      ic = Icons.chair_outlined;
    } else if (l.contains('pets')) {
      ic = Icons.pets_outlined;
    } else if (l.contains('internet')) {
      ic = Icons.wifi;
    } else if (l.contains('estacionamento')) {
      ic = Icons.local_parking_outlined;
    } else if (l.contains('estado')) {
      ic = Icons.map_outlined;
    } else if (l.contains('cep')) {
      ic = Icons.location_on_outlined;
    } else {
      ic = Icons.info_outline;
    }

    return Icon(ic, size: 16, color: const Color(0xFF6E56CF));
  }
}
