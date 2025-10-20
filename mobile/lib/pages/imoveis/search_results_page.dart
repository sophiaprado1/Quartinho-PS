// search_results_page.dart
// Tela de Busca com filtros, chips de tipo e grade de resultados

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../../core/services/auth_service.dart';
import '../imoveis/imovel_detalhe_page.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key, required this.token, this.initialQuery});
  final String token;
  final String? initialQuery;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  // ----- estado de UI -----
  final TextEditingController _queryCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  // ----- filtros rápidos (chips) -----
  final List<String> _tipos = const ['Tudo', 'Casa', 'Apartamento', 'Kitnet'];
  int _tipoIndex = 0;

  // ----- filtros avançados (bottom sheet) -----
  // (espelham os campos do seu backend)
  String? _cidade;
  String? _estado;
  double? _precoMin;
  double? _precoMax;

  bool? _mobiliado;
  bool? _aceitaPets;
  bool? _internet;
  bool? _estacionamento;

  // ----- dados -----
  final List<Map<String, dynamic>> _results = [];
  int _page = 1;
  bool _hasNext = true;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _queryCtrl.text = widget.initialQuery!;
    }
    _scroll.addListener(_onScrollEnd);
    _search(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _queryCtrl.dispose();
    super.dispose();
  }

  // ---------------- API ----------------

  Future<void> _search({bool reset = false}) async {
    if (_loading || _loadingMore) return;

    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _results.clear();
        _hasNext = true;
      });
    } else {
      if (!_hasNext) return;
      setState(() => _loadingMore = true);
    }

    try {
      final params = <String, String>{};

      // texto livre
      final q = _queryCtrl.text.trim();
      if (q.isNotEmpty) params['q'] = q;

      // chip tipo
      if (_tipoIndex != 0) {
        params['tipo'] = _tipos[_tipoIndex].toLowerCase(); // casa|apartamento|kitnet
      }

      // filtros avançados
      if (_cidade?.isNotEmpty == true) params['cidade'] = _cidade!;
      if (_estado?.isNotEmpty == true) params['estado'] = _estado!;
      if (_precoMin != null) params['preco_min'] = _precoMin!.toString();
      if (_precoMax != null) params['preco_max'] = _precoMax!.toString();
      if (_mobiliado != null) params['mobiliado'] = _mobiliado! ? '1' : '0';
      if (_aceitaPets != null) params['aceita_pets'] = _aceitaPets! ? '1' : '0';
      if (_internet != null) params['internet'] = _internet! ? '1' : '0';
      if (_estacionamento != null) params['estacionamento'] = _estacionamento! ? '1' : '0';

      // paginação (seu backend pode ignorar; sem problemas)
      params['page'] = _page.toString();

      final uri = Uri.parse('$backendHost/propriedades/propriedades/')
          .replace(queryParameters: params.isEmpty ? null : params);

      final resp = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body);

        // Aceita tanto lista pura quanto paginação estilo {results:[], next:..., count:...}
        List list;
        bool hasNext;
        if (data is Map && data['results'] is List) {
          list = (data['results'] as List);
          hasNext = data['next'] != null;
        } else if (data is List) {
          list = data;
          // se o backend não pagina, considera que não há próxima
          hasNext = false;
        } else {
          list = const [];
          hasNext = false;
        }

        final mapped = list.map<Map<String, dynamic>>(_normalize).toList();

        setState(() {
          _results.addAll(mapped);
          _hasNext = hasNext;
          if (reset) {
            _loading = false;
          } else {
            _loadingMore = false;
          }
          _page += 1;
        });
      } else if (resp.statusCode == 401) {
        await AuthService.logout();
        setState(() {
          _error = 'Sessão expirada. Faça login novamente.';
          _loading = false;
          _loadingMore = false;
        });
      } else {
        setState(() {
          _error = 'Erro ${resp.statusCode} ao buscar';
          _loading = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Falha de conexão';
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Map<String, dynamic> _normalize(dynamic raw) {
    final m = Map<String, dynamic>.from(raw as Map);
    // título
    final titulo = (m['titulo'] ?? '').toString();
    // preço pode vir como preco/preco_total/valor_aluguel
    final preco = (m['preco'] ?? m['preco_total'] ?? m['valor_aluguel'] ?? '').toString();
    // fotos: aceita [{imagem:...}] ou lista de strings
    final List<dynamic> fotos = [];
    if (m['fotos'] is List) {
      for (final f in (m['fotos'] as List)) {
        if (f is Map && f['imagem'] != null) {
          fotos.add({'imagem': _absUrl(f['imagem'].toString())});
        } else if (f is String) {
          fotos.add({'imagem': _absUrl(f)});
        }
      }
    } else if (m['fotos_paths'] is List) {
      for (final f in (m['fotos_paths'] as List)) {
        fotos.add({'imagem': _absUrl(f.toString())});
      }
    }
    return {
      ...m,
      'titulo': titulo,
      'preco': preco,
      'fotos': fotos,
    };
  }

  String _absUrl(String path) {
    if (path.startsWith('http')) return path;
    final p = path.startsWith('/') ? path : '/$path';
    return '$backendHost$p';
  }

  // ---------------- UI + interação ----------------

  void _onQueryChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(reset: true);
    });
  }

  void _onScrollEnd() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _search(reset: false);
    }
  }

  void _openFilters() async {
    final r = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FiltersSheet(
        cidade: _cidade,
        estado: _estado,
        precoMin: _precoMin,
        precoMax: _precoMax,
        mobiliado: _mobiliado,
        aceitaPets: _aceitaPets,
        internet: _internet,
        estacionamento: _estacionamento,
      ),
    );
    if (r == null) return;
    setState(() {
      _cidade = r.cidade;
      _estado = r.estado;
      _precoMin = r.precoMin;
      _precoMax = r.precoMax;
      _mobiliado = r.mobiliado;
      _aceitaPets = r.aceitaPets;
      _internet = r.internet;
      _estacionamento = r.estacionamento;
    });
    _search(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final count = _results.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados da busca', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(onPressed: _openFilters, icon: const Icon(Icons.tune_rounded)),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: TextField(
              controller: _queryCtrl,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(reset: true),
              decoration: InputDecoration(
                hintText: 'Internet inclusa, “centro”, preço…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF5F5F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
            ),
          ),

          // Chips de tipo (Tudo / Casa / Apartamento / Kitnet)
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final sel = i == _tipoIndex;
                return ChoiceChip(
                  label: Text(_tipos[i]),
                  selected: sel,
                  onSelected: (_) {
                    setState(() => _tipoIndex = i);
                    _search(reset: true);
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _tipos.length,
            ),
          ),

          // Header de contagem
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Text(
                  _loading && count == 0 ? 'Buscando…' : 'Encontrados $count imóveis',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.grid_view_rounded),
                  onPressed: () {}, // já está em grid
                ),
              ],
            ),
          ),

          // Conteúdo
          Expanded(
            child: _error != null
                ? Center(child: Text(_error!, style: GoogleFonts.poppins()))
                : _loading && count == 0
                    ? const Center(child: CircularProgressIndicator())
                    : count == 0
                        ? Center(child: Text('Nenhum imóvel encontrado.', style: GoogleFonts.poppins()))
                        : RefreshIndicator(
                            onRefresh: () => _search(reset: true),
                            child: GridView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.68,
                              ),
                              itemCount: _results.length + (_loadingMore ? 1 : 0),
                              itemBuilder: (_, index) {
                                if (index >= _results.length) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                final m = _results[index];
                                final fotos = m['fotos'] as List<dynamic>?;
                                final foto = (fotos != null &&
                                        fotos.isNotEmpty &&
                                        fotos[0] is Map &&
                                        fotos[0]['imagem'] != null)
                                    ? fotos[0]['imagem'].toString()
                                    : '';

                                final title = (m['titulo'] ?? '').toString();
                                final preco = (m['preco'] ?? m['preco_total'] ?? '').toString();
                                return _PropertyCard(
                                  imageUrl: foto,
                                  title: title,
                                  price: preco.isEmpty ? '-' : 'R\$ $preco',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => ImovelDetalhePage(imovel: m)),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFilters,
        icon: const Icon(Icons.tune_rounded),
        label: const Text('Filtros'),
      ),
    );
  }
}

// ---------------- Cards ----------------

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.onTap,
  });

  final String imageUrl;
  final String title;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // imagem
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              child: imageUrl.isEmpty
                  ? _placeholderBox()
                  : Image.network(
                      imageUrl,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderBox(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A34),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  price,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox() => Container(
        height: 130,
        width: double.infinity,
        color: const Color(0xFFEFEFF5),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, size: 28, color: Colors.grey),
      );
}

// ---------------- Bottom Sheet de Filtros ----------------

class _FilterResult {
  final String? cidade;
  final String? estado;
  final double? precoMin;
  final double? precoMax;
  final bool? mobiliado;
  final bool? aceitaPets;
  final bool? internet;
  final bool? estacionamento;

  _FilterResult({
    this.cidade,
    this.estado,
    this.precoMin,
    this.precoMax,
    this.mobiliado,
    this.aceitaPets,
    this.internet,
    this.estacionamento,
  });
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({
    required this.cidade,
    required this.estado,
    required this.precoMin,
    required this.precoMax,
    required this.mobiliado,
    required this.aceitaPets,
    required this.internet,
    required this.estacionamento,
  });

  final String? cidade;
  final String? estado;
  final double? precoMin;
  final double? precoMax;
  final bool? mobiliado;
  final bool? aceitaPets;
  final bool? internet;
  final bool? estacionamento;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late final TextEditingController _cidadeCtrl;
  late final TextEditingController _estadoCtrl;
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;

  bool? _mobiliado;
  bool? _aceitaPets;
  bool? _internet;
  bool? _estacionamento;

  @override
  void initState() {
    super.initState();
    _cidadeCtrl = TextEditingController(text: widget.cidade ?? '');
    _estadoCtrl = TextEditingController(text: widget.estado ?? '');
    _minCtrl = TextEditingController(text: widget.precoMin?.toString() ?? '');
    _maxCtrl = TextEditingController(text: widget.precoMax?.toString() ?? '');
    _mobiliado = widget.mobiliado;
    _aceitaPets = widget.aceitaPets;
    _internet = widget.internet;
    _estacionamento = widget.estacionamento;
  }

  @override
  void dispose() {
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  double? _parseDouble(String s) {
    var t = s.trim();
    if (t.isEmpty) return null;
    t = t.replaceAll(RegExp(r'[^0-9,\.]'), '');
    if (t.contains(',') && t.contains('.')) {
      t = t.replaceAll('.', '').replaceAll(',', '.'); // 1.234,56 -> 1234.56
    } else if (t.contains(',')) {
      t = t.replaceAll(',', '.');
    }
    return double.tryParse(t);
  }

  Widget _boolTri(String label, bool? value, ValueChanged<bool?> onChanged) {
    // Tri-state: null = indif., true = Sim, false = Não
    String text;
    if (value == null) text = 'Indiferente';
    else if (value) text = 'Sim';
    else text = 'Não';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Indiferente'),
              selected: value == null,
              onSelected: (_) => onChanged(null),
            ),
            ChoiceChip(
              label: const Text('Sim'),
              selected: value == true,
              onSelected: (_) => onChanged(true),
            ),
            ChoiceChip(
              label: const Text('Não'),
              selected: value == false,
              onSelected: (_) => onChanged(false),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, ctrl) {
          return SingleChildScrollView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Filtros', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _cidadeCtrl.clear();
                          _estadoCtrl.clear();
                          _minCtrl.clear();
                          _maxCtrl.clear();
                          _mobiliado = null;
                          _aceitaPets = null;
                          _internet = null;
                          _estacionamento = null;
                        });
                      },
                      child: const Text('Limpar'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text('Local', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cidadeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Cidade',
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: _estadoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          filled: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text('Faixa de preço (R\$)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Mínimo',
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Máximo',
                          filled: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _boolTri('Mobiliado', _mobiliado, (v) => setState(() => _mobiliado = v)),
                const SizedBox(height: 12),
                _boolTri('Aceita pets', _aceitaPets, (v) => setState(() => _aceitaPets = v)),
                const SizedBox(height: 12),
                _boolTri('Internet', _internet, (v) => setState(() => _internet = v)),
                const SizedBox(height: 12),
                _boolTri('Estacionamento', _estacionamento, (v) => setState(() => _estacionamento = v)),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        _FilterResult(
                          cidade: _cidadeCtrl.text.trim().isEmpty ? null : _cidadeCtrl.text.trim(),
                          estado: _estadoCtrl.text.trim().isEmpty ? null : _estadoCtrl.text.trim(),
                          precoMin: _parseDouble(_minCtrl.text),
                          precoMax: _parseDouble(_maxCtrl.text),
                          mobiliado: _mobiliado,
                          aceitaPets: _aceitaPets,
                          internet: _internet,
                          estacionamento: _estacionamento,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Aplicar filtro', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}