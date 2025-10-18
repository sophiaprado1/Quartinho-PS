import 'package:flutter/material.dart';
import 'package:mobile/pages/home/widgets/page_indicator.dart';
import 'home_next_button.dart';

class HomeImage extends StatelessWidget {
  final String image;
  final int pageIndicator;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;
  const HomeImage({
    super.key,
    required this.image,
    required this.pageIndicator,
    this.onNext,
    this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: 400,
        minWidth: double.infinity,
        maxWidth: double.infinity,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // cartão com imagem
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(), // espaço para o botão flutuante
                ],
              ),
            ),

            Positioned(
              bottom: 20, 
              left: 80, 
              right: 80, 
              child: PageIndicator(currentPage: pageIndicator,),
              ),

            // sombra arredondada e margem externa
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(),
            ),

            // botões flutuantes na parte inferior central
            Positioned(
              bottom: 40,
              left: 60,
              right: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botão voltar (só aparece se onPrev não for null)
                  if (onPrev != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: onPrev,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                            elevation: 2,
                          ),
                          child: const Icon(Icons.arrow_back, color: Color(0xFF9B51E0), size: 28),
                        ),
                      ),
                    ),
                  // Botão próximo
                  HomeNextButton(
                    onPressed: onNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
