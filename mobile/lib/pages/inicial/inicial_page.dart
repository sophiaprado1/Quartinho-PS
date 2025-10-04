import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InicialPage extends StatefulWidget {
  final String name; // nome completo do usuário
  final String city;
  final Uint8List? avatarBytes; // <-- avatar opcional vindo do signup

  const InicialPage({
    super.key,
    required this.name,
    required this.city,
    this.avatarBytes, // <-- ligado ao construtor corretamente
  });

  @override
  State<InicialPage> createState() => _InicialPageState();
}

class _InicialPageState extends State<InicialPage> {
  final List<String> _categories = const ['Tudo', 'Casa', 'Apartamento', 'Kitnet'];
  int _selectedCategory = 0;
  int _navIndex = 0;

  // Primeiro nome para o header ("Oi, ...!")
  String get _firstName {
    final n = widget.name.trim();
    if (n.isEmpty) return 'usuário';
    final parts = n.split(RegExp(r'\s+'));
    final first = parts.first;
    return first.isEmpty
        ? 'usuário'
        : first[0].toUpperCase() + first.substring(1);
  }

  TextStyle get _h2 => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1B1D28),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(name: _firstName, avatarBytes: widget.avatarBytes), // <-- passa avatar
              const SizedBox(height: 16),
              _LocationAndProfile(city: widget.city),
              const SizedBox(height: 20),
              const _SearchBar(),
              const SizedBox(height: 14),
              _CategoryChips(
                categories: _categories,
                selected: _selectedCategory,
                onChanged: (i) => setState(() => _selectedCategory = i),
              ),
              const SizedBox(height: 18),
              const _FeaturedCarousel(),
              const SizedBox(height: 18),
              const _SectionHeader(title: 'Imóveis recentes', action: 'Ver tudo'),
              const SizedBox(height: 12),
              const _RecentList(),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Locais mais procurados', action: 'Ver tudo'),
              const SizedBox(height: 10),
              const _PopularPlaces(),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Explore locais próximos', style: _h2),
              ),
              const SizedBox(height: 12),
              const _NearbyGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        backgroundColor: Colors.white,
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

/// ===================== HEADER ===================== ///
class _Header extends StatelessWidget {
  final String name; // primeiro nome
  final Uint8List? avatarBytes; // bytes do avatar (opcional)

  const _Header({required this.name, this.avatarBytes});

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
              // NÃO usar lista const aqui, porque o avatar é dinâmico
              children: [
                const Icon(Icons.notifications_none_rounded),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 18,
                  backgroundImage: avatarBytes != null ? MemoryImage(avatarBytes!) : null,
                  backgroundColor: const Color(0xFFE7E7EF),
                  child: avatarBytes == null
                      ? Text(
                          _initials(name),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B1D28),
                          ),
                        )
                      : null,
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

/// ================= LOCATION + PROFILE ================= ///
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
                    color: Colors.black.withValues(alpha: 0.05),
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

/// ===================== SEARCH ===================== ///
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
              color: Colors.black.withValues(alpha: 0.05),
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
                decoration: InputDecoration(
                  hintText: 'Procure por kitnet, casa…',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.withValues(alpha: 0.60),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.mic_none_rounded),
            )
          ],
        ),
      ),
    );
  }
}

/// ===================== CATEGORIES ===================== ///
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  final List<String> categories;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final isSelected = index == selected;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6E56CF) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6E8EC)),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6E56CF).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        )
                      ]
                    : null,
              ),
              child: Text(
                categories[index],
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF1B1D28),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: categories.length,
      ),
    );
  }
}

/// ===================== FEATURED CARDS ===================== ///
class _FeaturedCarousel extends StatelessWidget {
  const _FeaturedCarousel();

  final List<_Feature> items = const [
    _Feature(
      title: 'Kitnets perto da Universidade',
      image: 'https://images.unsplash.com/photo-1501183638710-841dd1904471?w=1200',
    ),
    _Feature(
      title: 'Casas próximas ao centro',
      image: 'https://images.unsplash.com/photo-1494526585095-c41746248156?w=1200',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => _FeaturedCard(item: items[index]),
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: items.length,
      ),
    );
  }
}

class _Feature {
  final String title;
  final String image;
  const _Feature({required this.title, required this.image});
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.item});
  final _Feature item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Image.network(
            item.image,
            width: 300,
            height: 190,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF000000).withValues(alpha: 0.60),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 18,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, size: 18),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// ===================== SECTION HEADER ===================== ///
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
            )
        ],
      ),
    );
  }
}

/// ===================== RECENT HORIZONTAL ===================== ///
class _RecentList extends StatelessWidget {
  const _RecentList();

  final List<_Property> items = const [
    _Property(
      title: 'Apartamento na rua 13',
      tag: 'Apartamento',
      image: 'https://images.unsplash.com/photo-1528909514045-2fa4ac7a08ba?w=1200',
      price: 'R\$ 1290/mês',
      rating: 4.9,
      distance: '2.1km',
    ),
    _Property(
      title: 'Kitnet aconchegante',
      tag: 'Kitnet',
      image: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=1200',
      price: 'R\$ 790/mês',
      rating: 4.7,
      distance: '900m',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => _RecentCard(item: items[index]),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.item});
  final _Property item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Image.network(
              item.image,
              width: 90,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.tag != null) _Tag(text: item.tag!),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    item.price,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
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

/// ===================== POPULAR PLACES ===================== ///
class _PopularPlaces extends StatelessWidget {
  const _PopularPlaces();

  final places = const [
    ('Edifício Sasha',
        'https://images.unsplash.com/photo-1460317442991-0ec209397118?w=800'),
    ('Parque Azaleia',
        'https://images.unsplash.com/photo-1531846802986-4942a5c3dd08?w=800'),
    ('Condomínio Vista',
        'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?w=800'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final (name, img) = places[index];
          return Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(img),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 90,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              )
            ],
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: places.length,
      ),
    );
  }
}

/// ===================== NEARBY GRID ===================== ///
class _NearbyGrid extends StatelessWidget {
  const _NearbyGrid();

  final List<_Property> items = const [
    _Property(
      title: 'Condomínio das Rosas',
      image: 'https://images.unsplash.com/photo-1505691723518-36a5ac3b2d94?w=1200',
      price: 'R\$ 1500/mês',
      rating: 4.9,
      distance: '300m',
    ),
    _Property(
      title: 'Casa na rua 04',
      image: 'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?w=1200',
      price: 'R\$ 800/mês',
      rating: 4.6,
      distance: '1.5km',
    ),
    _Property(
      title: 'Casa de 2 quartos',
      image: 'https://images.unsplash.com/photo-1565182999561-18d7f0ae79f0?w=1200',
      price: 'R\$ 1235/mês',
      rating: 4.7,
      distance: '1.9km',
    ),
    _Property(
      title: 'Apto perto da Av. Araguaia',
      image: 'https://images.unsplash.com/photo-1494526585095-c41746248156?w=1200',
      price: 'R\$ 790/mês',
      rating: 4.8,
      distance: '950m',
    ),
  ];

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
          mainAxisExtent: 230,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) => _PropertyCard(item: items[index]),
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
            color: const Color(0xFF000000).withValues(alpha: 0.05),
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
                child: Image.network(
                  item.image,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
              )
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