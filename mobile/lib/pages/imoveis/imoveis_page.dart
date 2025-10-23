import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/core/constants.dart';
import 'package:mobile/core/utils/property_utils.dart';
import 'package:mobile/pages/imoveis/widgets/header_imo.dart';
import 'package:mobile/pages/imoveis/widgets/search_imoveis.dart';
import 'package:mobile/pages/imoveis/widgets/imovel_card.dart';
import 'package:mobile/pages/imoveis/widgets/filtros_imoveis.dart';
import 'package:mobile/pages/imoveis/imovel_detalhe_page.dart';

class ImoveisPage extends StatefulWidget {
  final String token;
  const ImoveisPage({Key? key, required this.token}) : super(key: key);

  @override
  State<ImoveisPage> createState() => _ImoveisPageState();
}

class _ImoveisPageState extends State<ImoveisPage> {
  final List<String> filtros = const ['Tudo', 'Casa', 'Apartamento', 'Kitnet'];
  int filtroSelecionado = 0;

  List<dynamic> imoveis = [];
  bool loading = true;
  String? firstName;

  List<dynamic> get imoveisFiltrados {
    if (filtroSelecionado == 0) return imoveis;
    final tipoChip = filtros[filtroSelecionado].toLowerCase();
    return imoveis.where((imo) {
      final t = ((imo['tipo'] ?? imo['tipo_imovel']) ?? '').toString().toLowerCase();
      return t == tipoChip;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchUserFirstName();
    fetchImoveis();
  }

  Future<void> fetchUserFirstName() async {
    try {
      final resp = await http.get(
        Uri.parse('$backendHost/usuarios/me/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );
      if (resp.statusCode == 200) {
        final Map<String, dynamic> user = json.decode(utf8.decode(resp.bodyBytes));
        final nome = (user['first_name']?.toString().trim().isNotEmpty ?? false)
            ? user['first_name'].toString()
            : (user['username']?.toString() ?? '');
        if (!mounted) return;
        setState(() => firstName = nome);
      } else if (resp.statusCode == 401) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sessão expirada. Faça login novamente.')),
        );
      }
    } catch (_) {/* ok em modo demo */}
  }

  Future<void> fetchImoveis() async {
    setState(() => loading = true);
    try {
      final resp = await http.get(
        Uri.parse('$backendHost/propriedades/propriedades/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );
      if (resp.statusCode == 200) {
        final data = json.decode(utf8.decode(resp.bodyBytes));
        if (!mounted) return;
        setState(() {
          // normalize items so UI consumes consistent shape
          imoveis = (data is List) ? (data.map((e) => normalizeProperty(e)).toList()) : <dynamic>[];
          loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar imóveis (HTTP ${resp.statusCode})')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha de conexão ao buscar imóveis')),
      );
    }
  }

  Future<Map<String, dynamic>?> _fetchImovelById(dynamic id) async {
    if (id == null) return null;
    try {
      final resp = await http.get(
        Uri.parse('$backendHost/propriedades/propriedades/$id/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );
      if (resp.statusCode == 200) {
        return json.decode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  String? _primeiraFotoUrl(dynamic item) {
    String? raw;
    if (item is Map && item['imagem'] != null) {
      raw = item['imagem'].toString();
    } else if (item is String) {
      raw = item;
    }
    if (raw == null || raw.isEmpty) return null;
    return raw.startsWith('http') ? raw : '$backendHost$raw';
  }

  Future<void> _onRefresh() async {
    await fetchImoveis();
    await fetchUserFirstName();
  }

  Future<void> _abrirDetalhe(dynamic imovelLista) async {
    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    Map<String, dynamic> envio = Map<String, dynamic>.from(imovelLista as Map);
    final id = envio['id'];
    final det = await _fetchImovelById(id);

    if (mounted) Navigator.of(context).pop(); // fecha loading

      if (det != null) {
        // normalize the detailed object so downstream UI (detail page) consumes a consistent shape
        envio = normalizeProperty(det);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível carregar os detalhes. Mostrando resumo.')),
      );
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ImovelDetalhePage(imovel: envio)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Hero/header/busca
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  // círculo decorativo
                  const Positioned(
                    top: -115,
                    left: -110,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFEBDBFC),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 360, height: 360),
                    ),
                  ),
                  // Saudação
                  Positioned(
                    top: 100,
                    left: 32,
                    child: Text(
                      (firstName != null && firstName!.isNotEmpty) ? 'Oi, $firstName!' : 'Oi',
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const HeaderImo(),
                  const Positioned(
                    top: 200,
                    left: 16,
                    right: 16,
                    child: SearchImoveis(),
                  ),
                ],
              ),
            ),

            // Filtros
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
              child: FiltrosImoveis(
                filtros: filtros,
                filtroSelecionado: filtroSelecionado,
                onFiltroSelecionado: (index) => setState(() => filtroSelecionado = index),
              ),
            ),

            // Lista
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: imoveisFiltrados.length,
                        itemBuilder: (context, index) {
                          final imovel = imoveisFiltrados[index];

                          final fotos = imovel['fotos'] as List<dynamic>? ?? const <dynamic>[];
                          String? fotoUrl;
                          for (final f in fotos) {
                            final u = _primeiraFotoUrl(f);
                            if (u != null) {
                              fotoUrl = u;
                              break;
                            }
                          }

                          final preco = (imovel['preco_total'] ?? imovel['preco']);
                          final precoStr = (preco != null) ? 'R\$ $preco' : '-';
                          final titulo = (imovel['titulo'] ?? '').toString();

                          final rating = (imovel['rating'] is num) ? (imovel['rating'] as num).toDouble() : double.tryParse((imovel['rating'] ?? '').toString()) ?? 0.0;
                          final distancia = imovel['distance']?.toString() ?? (index % 2 == 0 ? '200 m' : '1.5 km');

                          return GestureDetector(
                            onTap: () => _abrirDetalhe(imovel),
                            child: ImovelCard(
                              imageUrl: fotoUrl,
                              title: titulo,
                              preco: precoStr,
                              rating: rating,
                              distancia: distancia,
                              favorito: imovel['favorito'] == true,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}