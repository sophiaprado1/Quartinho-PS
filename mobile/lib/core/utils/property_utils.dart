// Utility to normalize property data coming from different endpoints
Map<String, dynamic> normalizeProperty(dynamic raw) {
  if (raw == null) return <String, dynamic>{};
  final m = Map<String, dynamic>.from(raw is Map ? raw : {});

  // Title and price normalization
  final titulo = (m['titulo'] ?? m['title'] ?? '').toString();
  final preco = (m['preco'] ?? m['preco_total'] ?? m['price'] ?? '').toString();

  // fotos: normalize to list of maps with 'imagem' absolute url
  final fotosOut = <Map<String, String>>[];
  final rawFotos = m['fotos'] ?? m['fotos_paths'] ?? m['photos'];
  if (rawFotos is List) {
    for (final f in rawFotos) {
      if (f is Map && f['imagem'] != null) {
        fotosOut.add({'imagem': f['imagem'].toString()});
      } else if (f is String) {
        fotosOut.add({'imagem': f});
      }
    }
  }

  // preserve or compute endereco/cidade
  final endereco = m['endereco'] ?? m['address'] ?? '';
  final cidade = m['cidade'] ?? m['city'] ?? '';

  // favorito flag may be present
  final favorito = m['favorito'] == true || m['is_favorite'] == true;

  // compute average rating from comentarios if available
  double rating = 0.0;
  final comentarios = raw is Map ? raw['comentarios'] : null;
  if (comentarios is List && comentarios.isNotEmpty) {
    var sum = 0.0;
    var count = 0;
    for (final c in comentarios) {
      if (c is Map && c['nota'] != null) {
        final n = double.tryParse(c['nota'].toString());
        if (n != null) {
          sum += n;
          count += 1;
        }
      }
    }
    if (count > 0) rating = sum / count;
  } else if (m['rating'] != null) {
    final n = double.tryParse(m['rating'].toString());
    if (n != null) rating = n;
  }

  return {
    ...m,
    'titulo': titulo,
    'preco': preco,
    'fotos': fotosOut,
    'endereco': endereco,
    'cidade': cidade,
    'favorito': favorito,
    'rating': rating,
  };
}
