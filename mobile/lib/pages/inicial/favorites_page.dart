import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/favorites_service.dart';
import '../../core/constants.dart';
import '../../core/utils/property_utils.dart';
// auth_service not needed here
import '../imoveis/imovel_detalhe_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, required this.token});
  final String token;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    final res = await FavoritesService.listFavorites(token: widget.token);
    if (res == null) {
      if (mounted) setState(() {
        _items = [];
        _loading = false;
      });
      return;
    }
    final List<Map<String, dynamic>> parsed = [];
    for (final r in res) {
      parsed.add(normalizeProperty(r));
    }
    if (mounted) setState(() {
      _items = parsed;
      _loading = false;
    });
  }

  // photo URL construction is handled inline where needed

  Future<void> _toggleFavorite(int id, int index) async {
    final res = await FavoritesService.toggleFavorite(id, token: widget.token);
    if (res == null) return;
    if (!mounted) return;
    if (res == false) {
      // removed from favorites -> remove from list
      setState(() => _items.removeAt(index));
    } else {
      // keep it favorited (it was already) - update field if present
      setState(() {
        _items[index]['favorito'] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(child: Text('Nenhum favorito ainda', style: GoogleFonts.poppins()))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: GridView.builder(
                    itemCount: _items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final m = _items[index];
                      final fotos = m['fotos'] as List<dynamic>?;
                      String foto = '';
                      if (fotos != null && fotos.isNotEmpty) {
                        final first = fotos[0];
                        if (first is Map && first['imagem'] != null) {
                          final s = first['imagem'].toString();
                          foto = s.startsWith('http') ? s : '$backendHost${s.startsWith('/') ? s : '/$s'}';
                        } else if (first is String) {
                          final s = first;
                          foto = s.startsWith('http') ? s : '$backendHost${s.startsWith('/') ? s : '/$s'}';
                        }
                      }
                      final title = (m['titulo'] ?? '').toString();
                      final preco = (m['preco'] ?? m['preco_total'] ?? '')?.toString() ?? '';
                      return GestureDetector(
                        onTap: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ImovelDetalhePage(imovel: m)));
                        },
                        child: Container(
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
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(22),
                                      topRight: Radius.circular(22),
                                    ),
                                    child: foto.isEmpty
                                        ? Container(height: 130, color: const Color(0xFFEFEFF5))
                                        : Image.network(
                                            foto,
                                            height: 130,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(height: 130, color: const Color(0xFFEFEFF5)),
                                          ),
                                  ),
                                  Positioned(
                                    left: 10,
                                    bottom: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF8A34),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        preco.isEmpty ? '-' : 'R\$ $preco',
                                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () async {
                                        final id = m['id'];
                                        if (id is int) await _toggleFavorite(id, index);
                                      },
                                      icon: const Icon(Icons.favorite, size: 18, color: Colors.redAccent),
                                    ),
                                  ),
                                ],
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
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                                    const SizedBox(width: 4),
                                    Text(
                                      (m['rating'] is num) ? (m['rating'] as num).toDouble().toStringAsFixed(1) : (m['rating']?.toString() ?? '-'),
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.location_on_outlined, size: 16),
                                    const SizedBox(width: 2),
                                    Text('—', style: GoogleFonts.poppins(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
