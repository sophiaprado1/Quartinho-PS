import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImovelCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String preco;
  final String? distancia;
  final double? rating;
  final bool favorito;

  const ImovelCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.preco,
    this.distancia,
    this.rating,
    this.favorito = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 60),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      favorito ? Icons.favorite : Icons.favorite_border,
                      color: favorito ? Colors.pink : Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFA24B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          preco,
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/mês',
                          style: GoogleFonts.lato(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                title,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF23235B),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFFFC700), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    rating != null ? rating!.toStringAsFixed(1) : '-',
                    style: GoogleFonts.lato(fontSize: 15, color: Color(0xFF23235B)),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.location_on, color: Color(0xFF23235B), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    distancia ?? '-',
                    style: GoogleFonts.lato(fontSize: 15, color: Color(0xFF23235B)),
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
