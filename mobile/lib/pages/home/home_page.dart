import 'package:flutter/material.dart';
import 'widgets/home_header.dart';
import 'widgets/home_image.dart';
import 'package:mobile/pages/login/login_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Aqui tem um Quartinho\npra você!',
      'subtitle': 'Procure pelo imóvel e colega de quarto ideais, e deixa que a gente cuida do resto!',
      'image': 'assets/images/living_room.png',
    },
    {
      'title': 'Encontre o colega de quarto\ndos seus sonhos',
      'subtitle': 'Sem estresse ou burocracia - encontre alguém para dividir seu aluguel de maneira rápida, fácil e segura.',
      'image': 'assets/images/home_2.png',
    },
    {
      'title': 'Novo na cidade?\nSem problemas!',
      'subtitle': 'Filtre pelas suas preferências e encontramos o imóvel ideal pra você.',
      'image': 'assets/images/home_3.png',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      // Última página: navegar para LoginHomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginHomePage()),
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(),
              SizedBox(height: 24),
              Text(
                page['title'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                page['subtitle'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: HomeImage(
                  image: page['image'],
                  pageIndicator: _currentPage,
                  onNext: _nextPage,
                  onPrev: _currentPage > 0 ? _prevPage : null,
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
