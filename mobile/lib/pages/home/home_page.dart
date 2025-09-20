import 'package:flutter/material.dart';
import 'widgets/home_header.dart';
import 'widgets/home_image.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                'Aqui tem um Quartinho\npra você!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Procure pelo imóvel e colega de quarto ideais, e deixa que a gente cuida do resto!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 24),
              //Imagem Home
              Expanded(child: HomeImage(image: 'assets/images/living_room.png', pageIndicator: 0,)),

            ],
          ),
        ),
      ),
    );
  }
}
