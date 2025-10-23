import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/pages/signup/widgets/buttom_back.dart';
import 'package:mobile/pages/imoveis/widgets/dono_imovel_perfil.dart';
import '../../core/constants.dart';
import 'comentarios_section.dart';
import 'map_preview.dart';

class ImovelDetalhePage extends StatelessWidget {
  final Map imovel;
  const ImovelDetalhePage({super.key, required this.imovel});

  String? _normalizeImageUrl(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString();
    if (s.isEmpty) return null;
    return s.startsWith('http') ? s : '$backendHost$s';
  }

  @override
  Widget build(BuildContext context) {
    final fotos = imovel['fotos'] as List<dynamic>?;
    final fotosList = fotos ?? <dynamic>[];

    bool boolOf(dynamic v) {
      if (v is bool) return v;
      if (v == null) return false;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1' || s == 'sim';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fotosList.isNotEmpty)
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
                        }
                        final url = _normalizeImageUrl(raw);
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
                    const Positioned(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    (imovel['titulo'] ?? '').toString(),
                    style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF23235B)),
                  ),
                  const SizedBox(height: 8),

                  // Preço
                  Text(
                    'R\$ ${(imovel['preco_total'] ?? imovel['preco'] ?? '-').toString()} / mês',
                    style: GoogleFonts.lato(fontSize: 20, color: const Color(0xFFCBACFF), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  if (imovel['descricao'] != null && (imovel['descricao'].toString().isNotEmpty))
                    Text(
                      imovel['descricao'].toString(),
                      style: GoogleFonts.lato(fontSize: 16, color: const Color(0xFF23235B)),
                    ),

                  // Dono
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

                  // Endereço
                  if (imovel['endereco'] != null && imovel['endereco'].toString().isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFCBACFF)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            imovel['endereco'].toString(),
                            style: GoogleFonts.lato(fontSize: 15, color: const Color(0xFF23235B)),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Cidade
                  if (imovel['cidade'] != null && imovel['cidade'].toString().isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_city, color: Color(0xFFCBACFF)),
                        const SizedBox(width: 6),
                        Text(
                          imovel['cidade'].toString(),
                          style: GoogleFonts.lato(fontSize: 15, color: const Color(0xFF23235B)),
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  // Chips informativos (inclusive VARANDAS!)
                  Wrap(
                    runSpacing: 8,
                    spacing: 12,
                    children: [
                      if (imovel['quartos'] != null)
                        _InfoChip(label: 'Quartos', value: imovel['quartos'].toString()),
                      if (imovel['banheiros'] != null)
                        _InfoChip(label: 'Banheiros', value: imovel['banheiros'].toString()),
                      if (imovel['varandas'] != null)
                        _InfoChip(label: 'Varandas', value: imovel['varandas'].toString()),
                      if (imovel['area'] != null)
                        _InfoChip(label: 'Área', value: '${imovel['area']} m²'),

                      // booleans (lançados pelo mapeamento das tags na criação)
                      if (imovel.containsKey('mobiliado'))
                        _InfoChip(label: 'Mobiliado', value: boolOf(imovel['mobiliado']) ? 'Sim' : 'Não'),
                      if (imovel.containsKey('aceita_pets'))
                        _InfoChip(label: 'Aceita pets', value: boolOf(imovel['aceita_pets']) ? 'Sim' : 'Não'),
                      if (imovel.containsKey('internet'))
                        _InfoChip(label: 'Internet', value: boolOf(imovel['internet']) ? 'Sim' : 'Não'),
                      if (imovel.containsKey('estacionamento'))
                        _InfoChip(label: 'Estacionamento', value: boolOf(imovel['estacionamento']) ? 'Sim' : 'Não'),

                      if (imovel['estado'] != null)
                        _InfoChip(label: 'Estado', value: imovel['estado'].toString()),
                      if (imovel['cep'] != null)
                        _InfoChip(label: 'CEP', value: imovel['cep'].toString()),
                    ],
                  ),

                  // ░░░ TAGS TEXTUAIS ░░░
                  if (imovel['tags'] is List && (imovel['tags'] as List).isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Características adicionais',
                      style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF23235B)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (imovel['tags'] as List)
                          .map<Widget>((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECEBFF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  t.toString(),
                                  style: GoogleFonts.lato(fontSize: 13, color: const Color(0xFF6E56CF)),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Preview do mapa (static image)
                  if ((imovel['latitude'] != null && imovel['longitude'] != null) ||
                      (imovel['endereco'] != null && imovel['endereco'].toString().isNotEmpty)) ...[
                    const SizedBox(height: 8),
                    MapPreview(
                      latitude: imovel['latitude'] != null
                          ? double.tryParse(imovel['latitude'].toString())
                          : null,
                      longitude: imovel['longitude'] != null
                          ? double.tryParse(imovel['longitude'].toString())
                          : null,
                      address: imovel['endereco'] != null ? imovel['endereco'].toString() : null,
                      height: 160,
                    ),
                  ],
                ],
              ),
            ),
            // Comentários
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ComentariosSection(imovelId: imovel['id']),
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
    } else if (l.contains('varanda')) {
      ic = Icons.balcony_outlined; // ícone para varandas
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