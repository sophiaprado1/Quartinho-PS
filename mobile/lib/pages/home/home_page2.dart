import 'package:flutter/material.dart';
import 'widgets/home_header.dart';
import 'widgets/home_image.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Cabeçalho
              HomeHeader(),
              //Corpo de texto
              SizedBox(height: 24),
              Text(
                'Encontre o colega de Quarto\ndos seus sonhos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sem estresse ou burocracia - encontre alguém para dividir'
                'seu aluguel de maneira rápida, fácil e segura.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 24),
              //Imagem Home
              Expanded(child: HomeImage(image: 'assets/images/living_room.png', pageIndicator: 1,)),

            ],
          ),
        ),
      ),
    );
  }
}
