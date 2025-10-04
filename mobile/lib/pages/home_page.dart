import 'package:flutter/material.dart';
import 'package:mobile/pages/imoveis/imoveis_page.dart';
// Importe suas outras páginas aqui
// import 'package:mobile/pages/search/search_page.dart';
// import 'package:mobile/pages/favorites/favorites_page.dart';
// import 'package:mobile/pages/profile/profile_page.dart';

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ImoveisPage(token: widget.token),
      // Substitua pelos seus widgets reais:
      Center(child: Text('Busca')), // SearchPage(),
      Center(child: Text('Favoritos')), // FavoritesPage(),
      Center(child: Text('Perfil')), // ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '',
          ),
        ],
      ),
    );
  }
}
