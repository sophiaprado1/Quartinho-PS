import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../imoveis/imovel_detalhe_page.dart';

class UserAnunciosPage extends StatefulWidget {
  final int ownerId;
  final String token;

  const UserAnunciosPage({super.key, required this.ownerId, required this.token});

  @override
  State<UserAnunciosPage> createState() => _UserAnunciosPageState();
}

class _UserAnunciosPageState extends State<UserAnunciosPage> {
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse('$backendHost/propriedades/propriedades/?owner=${widget.ownerId}');
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer ${widget.token}',
      });
      if (!mounted) return;
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body);
        List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          final inner = decoded['results'] ?? decoded['results_list'] ?? decoded['data'];
          if (inner is List) {
            list = inner;
          } else {
            list = [];
          }
        } else {
          list = [];
        }
        setState(() {
          _items = list;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Não foi possível carregar os anúncios';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar anúncios';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anúncios'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _items.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum anúncio encontrado.',
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final item = _items[i] as Map<String, dynamic>;
                          return _AnuncioCard(
                            imovel: item,
                            onTap: () async {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ImovelDetalhePage(imovel: item),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

class _AnuncioCard extends StatelessWidget {
  final Map<String, dynamic> imovel;
  final VoidCallback onTap;

  const _AnuncioCard({required this.imovel, required this.onTap});

  String? _getThumb() {
    final fotos = imovel['fotos'] as List<dynamic>?;
    if (fotos == null || fotos.isEmpty) return null;
    final first = fotos.first;
    String? raw;
    if (first is Map) {
      raw = first['imagem']?.toString();
    } else if (first is String) {
      raw = first;
    }
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    if (raw.startsWith('/')) return '$backendHost$raw';
    return '$backendHost/media/$raw';
  }

  @override
  Widget build(BuildContext context) {
    final thumb = _getThumb();
    final titulo = (imovel['titulo'] ?? '').toString();
    final cidade = (imovel['cidade'] ?? '').toString();
    final preco = (imovel['preco_total'] ?? imovel['preco'] ?? '-').toString();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: thumb != null
                  ? Image.network(
                      thumb,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 96,
                      height: 96,
                      color: const Color(0xFFF2F2F7),
                      child: const Icon(Icons.home_outlined, color: Colors.grey),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF23235B)),
                    ),
                    const SizedBox(height: 4),
                    if (cidade.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Color(0xFFCBACFF)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              cidade,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ $preco / mês',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF6E56CF)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
