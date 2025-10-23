// lib/pages/inicial/inicial_page.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../imoveis/criar_imoveis_page.dart';
import '../imoveis/editar_imovel_page.dart';
import '../imoveis/imovel_detalhe_page.dart';

// >>> usa a tela real de resultados <<<
import 'package:mobile/pages/imoveis/search_results_page.dart';

import '../../core/services/auth_service.dart';
import '../../core/constants.dart';
import '../../core/utils/property_utils.dart';
import 'package:mobile/pages/profile/profile_page.dart';
import 'package:mobile/pages/login/login_home_page.dart';
import 'package:mobile/pages/inicial/favorites_page.dart';
import 'package:mobile/core/services/favorites_service.dart';

class InicialPage extends StatefulWidget {
  final String name; // nome completo do usuário
  final String city;
  final Uint8List? avatarBytes; // avatar opcional vindo do signup

  const InicialPage({
    super.key,
    required this.name,
    required this.city,
    this.avatarBytes,
  });

  @override
  State<InicialPage> createState() => _InicialPageState();
}

class _InicialPageState extends State<InicialPage> {
  /// categorias para filtrar sugestões
  final List<String> _categories = const ['Tudo', 'Casa', 'Apartamento', 'Kitnet'];
  int _selectedCategory = 0;

  int _navIndex = 0;
  String? _avatarUrl;
  int? _myUserId;

  /// lista dinâmica com os imóveis criados pelo usuário logado
  final List<Map<String, dynamic>> _meusAnuncios = [];

  /// sugestões (imóveis de outros usuários)
  final List<Map<String, dynamic>> _sugestoes = [];

  bool _loadingSugestoes = false;

  // Primeiro nome para o header ("Oi, ...!")
  String get _firstName {
    final n = widget.name.trim();
    if (n.isEmpty) return 'usuário';
    final parts = n.split(RegExp(r'\s+'));
    final first = parts.first;
    return first.isEmpty ? 'usuário' : first[0].toUpperCase() + first.substring(1);
  }

  // header text style (kept inline where used)

  Future<void> _abrirCriarImovel() async {
    final novo = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(builder: (_) => CriarImoveisPage(firstName: _firstName)),
    );

    if (novo != null) {
      final tipoImovel = (novo['tipo_imovel'] ?? '').toString(); // apartamento|casa|kitnet
      final tipo = {
        'apartamento': 'Apartamento',
        'casa': 'Casa',
        'kitnet': 'Kitnet',
      }[tipoImovel] ?? (novo['tipo']?.toString() ?? 'Anúncio');

      setState(() {
        _meusAnuncios.insert(0, {
          ...novo,
          'tipo': tipo,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imóvel adicionado à seção "Meus anúncios".')),
      );

      // após criar, recarrega sugestões para evitar mostrar o seu próprio como sugestão
      _loadSugestoes();
    }
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // carrega "me" e "minhas_propriedades" antes de sugerir
    await Future.wait(<Future<void>>[
      _loadMe(),
      _loadMinhasPropriedades(),
    ]);
    await _loadSugestoes();
  }

  Future<void> _doRefresh() async {
    await _bootstrap();
  }

  /// Tenta obter o ID do usuário em formatos diferentes (id/pk/aninhado)
  int? _tryParseUserId(Map<String, dynamic>? me) {
    if (me == null) return null;
    final candidates = <dynamic>[
      me['id'],
      me['pk'],
      (me['user'] is Map ? (me['user'] as Map)['id'] : null),
      (me['usuario'] is Map ? (me['usuario'] as Map)['id'] : null),
    ];
    for (final c in candidates) {
      if (c is int) return c;
      if (c is String) {
        final v = int.tryParse(c);
        if (v != null) return v;
      }
    }
    return null;
  }

  Future<void> _loadMe() async {
    try {
      final token = await AuthService.getSavedToken();
      if (token == null) return;
      final me = await AuthService.me(token: token);
      if (!mounted) return;

      // avatar
      final avatar = (me?['avatar'] ?? '')?.toString();
      if (avatar != null && avatar.isNotEmpty) {
        String url = avatar;
        if (!url.startsWith('http')) {
          if (!url.startsWith('/')) url = '/$url';
          url = '$backendHost$url';
        }
        _avatarUrl = url;
      }

      // id do usuário
  _myUserId = _tryParseUserId(me);

      setState(() {});
    } catch (_) {}
  }

  Future<void> _handleEdit(Map<String, dynamic> dados) async {
    final atualizado = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(builder: (_) => EditarImovelPage(dados: dados)),
    );

    if (atualizado != null && mounted) {
      setState(() {
        final idx = _meusAnuncios.indexWhere((e) => e['id'] == atualizado['id']);
        if (idx >= 0) {
          _meusAnuncios[idx] = {
            ..._meusAnuncios[idx],
            'titulo': atualizado['titulo'] ?? _meusAnuncios[idx]['titulo'],
            'endereco': atualizado['endereco'] ?? _meusAnuncios[idx]['endereco'],
            'preco': atualizado['preco']?.toString() ?? _meusAnuncios[idx]['preco'],
            'periodicidade': atualizado['periodicidade'] ?? _meusAnuncios[idx]['periodicidade'],
            'tipo_imovel': atualizado['tipo'] ?? atualizado['categoria'] ?? _meusAnuncios[idx]['tipo_imovel'],
          };
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imóvel atualizado.')));

      // Atualiza sugestões após editar (por via das dúvidas)
      _loadSugestoes();
    }
  }

  Future<void> _handleDelete(Map<String, dynamic> dados) async {
    final id = dados['id'];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir imóvel'),
        content: const Text('Tem certeza que deseja excluir este imóvel? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getSavedToken();
      if (token == null) return;

      final url = Uri.parse('$backendHost/propriedades/propriedades/$id/');
      final resp = await http.delete(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (resp.statusCode == 204 || resp.statusCode == 200) {
        if (mounted) {
          setState(() {
            _meusAnuncios.removeWhere((e) => e['id'] == id);
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imóvel excluído.')));
        // Atualiza sugestões para garantir que não aparece seu próprio imóvel
        _loadSugestoes();
      } else if (resp.statusCode == 401) {
        await AuthService.logout();
      } else {
        // ignore: avoid_print
        print('Erro ao excluir imóvel: ${resp.statusCode} ${resp.body}');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha ao excluir imóvel')));
      }
    } catch (e) {
      // ignore: avoid_print
      print('Exception ao excluir imóvel: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro na requisição')));
    }
  }

  /// Carrega propriedades do usuário logado
  Future<void> _loadMinhasPropriedades() async {
    try {
      final token = await AuthService.getSavedToken();
      if (token == null) return;

      final url = Uri.parse('$backendHost/propriedades/propriedades/minhas_propriedades/');
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
        final List<Map<String, dynamic>> anuncios = data.map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return {
            'id': m['id'],
            'titulo': m['titulo'] ?? '',
            'endereco': m['endereco'] ?? '',
            'preco': m['preco']?.toString() ?? '',
            'periodicidade': m['periodicidade'] ?? 'mensal',
            'tipo_imovel': m['tipo'] ?? m['categoria'] ?? '',
            // Para meus anúncios usamos fotos_paths (como já estava)
            'fotos_paths': (m['fotos'] as List<dynamic>?)
                    ?.map((f) => (f is Map && f['imagem'] != null) ? f['imagem'] as String : f.toString())
                    .toList() ??
                <String>[],
            // guardamos também possível dono/autor para referência
            'owner_id': m['owner_id'] ?? m['usuario_id'] ?? m['user_id'] ?? m['proprietario_id'],
          };
        }).toList();

        if (mounted) {
          setState(() {
            _meusAnuncios
              ..clear()
              ..addAll(anuncios);
          });
        }
      } else if (resp.statusCode == 401) {
        await AuthService.logout();
      } else {
        // ignore: avoid_print
        print('Erro ao buscar minhas propriedades: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Exception buscando minhas propriedades: $e');
    }
  }

  // property normalization now handled by core/utils/property_utils.normalizeProperty

  bool _isMine(Map m) {
    // Tenta detectar dono do imóvel
    final ownerCandidates = [
      m['owner_id'],
      m['usuario_id'],
      m['user_id'],
      m['proprietario_id'],
      (m['owner'] is Map ? (m['owner'] as Map)['id'] : null),
      (m['usuario'] is Map ? (m['usuario'] as Map)['id'] : null),
      (m['user'] is Map ? (m['user'] as Map)['id'] : null),
      (m['proprietario'] is Map ? (m['proprietario'] as Map)['id'] : null),
    ];
    int? ownerId;
    for (final c in ownerCandidates) {
      if (c is int) {
        ownerId = c;
        break;
      } else if (c is String) {
        final v = int.tryParse(c);
        if (v != null) {
          ownerId = v;
          break;
        }
      }
    }
    return _myUserId != null && ownerId != null && _myUserId == ownerId;
  }

  Future<void> _loadSugestoes() async {
    setState(() => _loadingSugestoes = true);
    try {
      final token = await AuthService.getSavedToken();

      // Endpoint geral de propriedades (ajuste se o seu for outro)
      final uri = Uri.parse('$backendHost/propriedades/propriedades/').replace(
        queryParameters: {
          if (_selectedCategory != 0)
            'tipo': _categories[_selectedCategory].toLowerCase(), // casa|apartamento|kitnet
        },
      );

      final resp = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;

        // IDs dos meus anúncios para evitar duplicatas
        final myIds = _meusAnuncios.map((e) => e['id']).toSet();

        final outros = <Map<String, dynamic>>[];
        for (final raw in data) {
          final norm = normalizeProperty(raw);
          // pula itens que são meus
          if (_isMine(norm)) continue;
          // pula se já está na seção "meus anúncios"
          if (myIds.contains(norm['id'])) continue;
          outros.add(norm);
        }

        if (mounted) {
          setState(() {
            _sugestoes
              ..clear()
              ..addAll(outros);
          });
        }
      } else if (resp.statusCode == 401) {
        await AuthService.logout();
      } else {
        // ignore: avoid_print
        print('Erro ao buscar sugestões: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Exception buscando sugestões: $e');
    } finally {
      if (mounted) setState(() => _loadingSugestoes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _doRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  name: _firstName,
                  avatarBytes: widget.avatarBytes,
                  avatarUrl: _avatarUrl,
                  onAdd: _abrirCriarImovel,
                ),
                const SizedBox(height: 16),
                _LocationAndProfile(city: widget.city),
                const SizedBox(height: 20),

                if (_meusAnuncios.isNotEmpty) ...[
                  const _SectionHeader(title: 'Meus anúncios'),
                  const SizedBox(height: 10),
                  _MeusAnunciosList(
                    items: _meusAnuncios,
                    onEdit: _handleEdit,
                    onDelete: _handleDelete,
                  ),
                  const SizedBox(height: 24),
                ],

                // Busca (mantida porque ajuda o usuário)
                const _SearchBar(),
                const SizedBox(height: 16),

                // Filtro de categoria (aplica nas sugestões)
                _CategoryChips(
                  categories: _categories,
                  selected: _selectedCategory,
                  onChanged: (i) async {
                    setState(() => _selectedCategory = i);
                    await _loadSugestoes();
                  },
                ),
                const SizedBox(height: 18),

                const _SectionHeader(title: 'Sugestões para você'),
                const SizedBox(height: 12),

                if (_loadingSugestoes)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_sugestoes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Sem sugestões no momento.', style: GoogleFonts.poppins(fontSize: 14)),
                  )
                else
                  _SugestoesGrid(items: _sugestoes),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) async {
          // Aba Perfil (última): abrir a tela de Perfil/Login
          if (i == 3) {
            final token = await AuthService.getSavedToken();
            if (token == null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginHomePage()));
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            return;
          }
          // Aba Buscar: abrir tela de resultados
          if (i == 1) {
            final token = await AuthService.getSavedToken();
            if (token == null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginHomePage()));
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => SearchResultsPage(token: token)));
            return;
          }
          // Aba Favoritos: abrir lista de favoritos
          if (i == 2) {
            final token = await AuthService.getSavedToken();
            if (token == null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginHomePage()));
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesPage(token: token)));
            return;
          }
          setState(() => _navIndex = i);
        },
        backgroundColor: Colors.white,
        // withOpacity -> withValues (lint fix)
        indicatorColor: const Color(0xFF6E56CF).withValues(alpha: 0.10),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

/// ===================== HEADER / LISTAS / WIDGETS =====================

class _Header extends StatelessWidget {
  final String name; // primeiro nome
  final Uint8List? avatarBytes; // bytes do avatar (opcional)
  final String? avatarUrl; // optional remote avatar url
  final VoidCallback? onAdd;

  const _Header({required this.name, this.avatarBytes, this.avatarUrl, this.onAdd});

  String _initials(String n) {
    final parts = n.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    final first = parts.first[0].toUpperCase();
    final second = parts.length > 1 ? parts[1][0].toUpperCase() : '';
    return (first + second).trim();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF6F1FF), Color(0xFFFFFFFF)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -40,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0xFFE8D9FF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 20,
            child: Row(
              children: [
                if (onAdd != null)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: onAdd,
                    tooltip: 'Adicionar imóvel',
                  ),
                const SizedBox(width: 6),
                const Icon(Icons.notifications_none_rounded),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'perfil') {
                      final token = await AuthService.getSavedToken();
                      if (token == null) {
                        try {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginHomePage()));
                        } catch (_) {}
                        return;
                      }
                      try {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                      } catch (_) {}
                    } else if (v == 'logout') {
                      await AuthService.logout();
                      try {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginHomePage()),
                          (route) => false,
                        );
                      } catch (_) {}
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'perfil', child: Text('Perfil')),
                    PopupMenuItem(value: 'logout', child: Text('Sair')),
                  ],
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: avatarBytes != null
                        ? MemoryImage(avatarBytes!)
                        : (avatarUrl != null && avatarUrl!.isNotEmpty)
                            ? NetworkImage(avatarUrl!) as ImageProvider
                            : null,
                    backgroundColor: const Color(0xFFE7E7EF),
                    child: (avatarBytes == null && (avatarUrl == null || avatarUrl!.isEmpty))
                        ? Text(
                            _initials(name),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B1D28),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            bottom: 18,
            child: Text(
              'Oi, $name!',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B1D28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationAndProfile extends StatelessWidget {
  final String city;
  const _LocationAndProfile({required this.city});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      city,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
              iconSize: 20,
              splashRadius: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeusAnunciosList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onDelete;
  const _MeusAnunciosList({required this.items, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) =>
            _MeuAnuncioCard(dados: items[index], onEdit: onEdit, onDelete: onDelete),
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: items.length,
      ),
    );
  }
}

class _MeuAnuncioCard extends StatelessWidget {
  final Map<String, dynamic> dados;
  final void Function(Map<String, dynamic>)? onEdit;
  final void Function(Map<String, dynamic>)? onDelete;
  const _MeuAnuncioCard({required this.dados, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final titulo = (dados['titulo'] ?? '').toString().trim();
    final endereco = (dados['endereco'] ?? 'Seu novo imóvel') as String;
    final preco = (dados['preco'] ?? '').toString();
    final periodicidade = (dados['periodicidade'] ?? 'mensal') as String;
    final tag = (dados['tipo'] ?? dados['categoria'] ?? 'Anúncio').toString();

    // thumbnail: URL absoluta/relativa ou caminho local
    final fotos = (dados['fotos_paths'] as List?)?.cast<String>() ?? const [];
    Widget thumbWidget;
    if (fotos.isNotEmpty) {
      final first = fotos.first.toString();
      if (first.startsWith('http')) {
        thumbWidget = Image.network(
          first,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackThumb(),
        );
      } else if (first.startsWith('/')) {
        final url = '$backendHost$first';
        thumbWidget = Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackThumb(),
        );
      } else if (first.startsWith('file://')) {
        try {
          final file = File(Uri.parse(first).toFilePath());
          thumbWidget = Image.file(file, fit: BoxFit.cover);
        } catch (_) {
          thumbWidget = _fallbackThumb();
        }
      } else {
        final file = File(first);
        thumbWidget = file.existsSync() ? Image.file(file, fit: BoxFit.cover) : _fallbackThumb();
      }
    } else {
      thumbWidget = _fallbackThumb();
    }

    return GestureDetector(
      onTap: () async {
        final id = dados['id'];
        try {
          final token = await AuthService.getSavedToken();
          final url = Uri.parse('$backendHost/propriedades/propriedades/$id/');
          final resp = await http.get(
            url,
            headers: token != null
                ? {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}
                : {'Content-Type': 'application/json'},
          );

          if (resp.statusCode == 200) {
            final Map<String, dynamic> full = jsonDecode(resp.body) as Map<String, dynamic>;
            Navigator.push(context, MaterialPageRoute(builder: (_) => ImovelDetalhePage(imovel: full)));
            return;
          } else if (resp.statusCode == 401) {
            await AuthService.logout();
          }
        } catch (_) {}

        // fallback: abrir com os dados que temos
        Navigator.push(context, MaterialPageRoute(builder: (_) => ImovelDetalhePage(imovel: dados)));
      },
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: .06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // imagem ocupa o espaço disponível (evita overflow)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(width: 1, height: 1, child: thumbWidget),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A34),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          periodicidade == 'mensal' ? 'R\$ $preco/mês' : 'R\$ $preco/ano',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: FutureBuilder<String?>(
                        future: AuthService.getSavedToken(),
                        builder: (ctx, snap) {
                          final token = snap.data;
                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: token == null
                                ? null
                                : () async {
                                    final id = dados['id'];
                                    if (id == null) return;
                                    final res = await FavoritesService.toggleFavorite(id as int, token: token);
                                    if (res != null) {
                                      dados['favorito'] = res;
                                      (ctx as Element).markNeedsBuild();
                                    }
                                  },
                            icon: Icon(
                              dados['favorito'] == true ? Icons.favorite : Icons.favorite_border,
                              color: dados['favorito'] == true ? Colors.redAccent : Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 6, 2),
              child: Row(
                children: [
                  _Tag(text: tag),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (v) {
                      if (v == 'edit') {
                        if (onEdit != null) onEdit!(dados);
                      } else if (v == 'delete') {
                        if (onDelete != null) onDelete!(dados);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Excluir')),
                    ],
                  ),
                ],
              ),
            ),

            if (titulo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
              ),

            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                endereco,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  height: 1.25,
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _fallbackThumb() => _placeholderBox(height: 150);
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                readOnly: true,
                onTap: () async {
                  final token = await AuthService.getSavedToken();
                  if (token == null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginHomePage()));
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SearchResultsPage(token: token)));
                },
                decoration: InputDecoration(
                  hintText: 'Procure por kitnet, casa…',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.withValues(alpha: .60),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                final token = await AuthService.getSavedToken();
                if (token == null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginHomePage()));
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SearchResultsPage(token: token)),
                );
              },
              icon: const Icon(Icons.mic_none_rounded),
            )
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});
  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B1D28),
            ),
          ),
          const Spacer(),
          if (action != null)
            TextButton(
              onPressed: () {},
              child: Text(action!, style: GoogleFonts.poppins()),
            ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: const Color(0xFF246BFD),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final int selected;
  final ValueChanged<int> onChanged;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final isSel = index == selected;
          return ChoiceChip(
            label: Text(categories[index]),
            selected: isSel,
            onSelected: (_) => onChanged(index),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: categories.length,
      ),
    );
  }
}

class _SugestoesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _SugestoesGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.68,
        ),
        itemBuilder: (context, index) {
          final m = items[index];
          final fotos = m['fotos'] as List<dynamic>?;
          final foto = (fotos != null && fotos.isNotEmpty && fotos[0] is Map && fotos[0]['imagem'] != null)
              ? fotos[0]['imagem'].toString()
              : '';
          final title = m['titulo']?.toString() ?? '';
          final preco = m['preco']?.toString() ?? m['preco_total']?.toString() ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImovelDetalhePage(imovel: m),
                ),
              );
            },
            child: _PropertyCard(
                item: _Property(
                  title: title,
                  image: foto,
                  price: preco.isEmpty ? '-' : 'R\$ $preco',
                  rating: (m['rating'] is num) ? (m['rating'] as num).toDouble() : double.tryParse((m['rating'] ?? '').toString()) ?? 0.0,
                  distance: '-',
                ),
              ),
          );
        },
      ),
    );
  }
}

class _Property {
  final String title;
  final String image;
  final String price;
  final double rating;
  final String distance;
  final String? tag;

  const _Property({
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
    required this.distance,
    this.tag,
  });
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({required this.item});
  final _Property item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: .05),
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
                child: item.image.isEmpty
                    ? _placeholderBox(height: 130)
                    : Image.network(
                        item.image,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderBox(height: 130),
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
                    item.price,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border, size: 18),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
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
                  item.rating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.location_on_outlined, size: 16),
                const SizedBox(width: 2),
                Text(item.distance, style: GoogleFonts.poppins(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===== Helpers de placeholder (sem rede) =====

Widget _placeholderBox({double height = 130, double? width}) => Container(
      height: height,
      width: width ?? double.infinity,
      color: const Color(0xFFEFEFF5),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, size: 28, color: Colors.grey),
    );