import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'interactive_map_page.dart';
import '../../core/constants.dart';

/// Widget simples que mostra uma imagem do Google Static Maps para a
/// latitude/longitude fornecida. Ao tocar, abre o Google Maps (app ou web).
class MapPreview extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? address;
  final double height;
  final int zoom;

  const MapPreview({
    super.key,
    this.latitude,
    this.longitude,
    this.address,
    this.height = 160,
    this.zoom = 15,
  });

  String _staticMapUrl() {
    final apiKey = googleMapsApiKey != 'PUT_YOUR_GOOGLE_MAPS_API_KEY_HERE' ? googleMapsApiKey : null;
    // Build marker and center depending on available data
    final size = '600x300';
    final base = 'https://maps.googleapis.com/maps/api/staticmap';
    final keyPart = apiKey != null ? '&key=$apiKey' : '';

    String centerPart;
    String markerPart = '';
    if (latitude != null && longitude != null) {
      centerPart = 'center=$latitude,$longitude';
      markerPart = '&markers=color:0xff8a34|label:A|$latitude,$longitude';
    } else if (address != null && address!.isNotEmpty) {
      final enc = Uri.encodeComponent(address!);
      centerPart = 'center=$enc';
      markerPart = '&markers=color:0xff8a34|label:A|$enc';
    } else {
      // fallback to (0,0)
      centerPart = 'center=0,0';
    }

    return '$base?$centerPart&zoom=$zoom&size=$size$markerPart$keyPart&scale=2';
  }

  // NOTE: We read the API key from `constants.dart` instead of manifest.

  Future<void> _openMaps(BuildContext context) async {
    if (latitude != null && longitude != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InteractiveMapPage(latitude: latitude!, longitude: longitude!),
        ),
      );
      return;
    }
    // If we don't have coords, do nothing (static preview used as passive display)
  }

  @override
  Widget build(BuildContext context) {
    final url = _staticMapUrl();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Localização', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () => _openMaps(context),
            child: Image.network(
              url,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: height,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.map, size: 48, color: Colors.grey)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
