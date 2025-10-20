// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'criar_imovel_fotos_page.dart';

class CriarImovelLocalizacaoPage extends StatefulWidget {
  final Map<String, dynamic> dadosIniciais;
  const CriarImovelLocalizacaoPage({super.key, required this.dadosIniciais});

  @override
  State<CriarImovelLocalizacaoPage> createState() =>
      _CriarImovelLocalizacaoPageState();
}

class _CriarImovelLocalizacaoPageState
    extends State<CriarImovelLocalizacaoPage> {
  final _enderecoCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();

  static const Color _bgPage = Color(0xFFF3F4F7);
  static const Color _accent = Color(0xFFFF8A34);
  static const Color _textDark = Color(0xFF1B1D28);
  static const Color _pill = Color(0xFFF5F4FA);

  GoogleMapController? _mapController;
  LatLng _posicao = const LatLng(-10.184, -48.333); // Palmas-TO inicial

  @override
  void dispose() {
    _enderecoCtrl.dispose();
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    _cepCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscarEnderecoPelaPosicao() async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(_posicao.latitude, _posicao.longitude);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _enderecoCtrl.text =
              '${p.street ?? ''}, ${p.subThoroughfare ?? ''}'.trim();
          _cidadeCtrl.text = p.locality ?? '';
          _estadoCtrl.text = p.administrativeArea ?? '';
          _cepCtrl.text = p.postalCode ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço preenchido automaticamente!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar endereço: $e')),
      );
    }
  }

  Future<void> _irParaFotos() async {
    if (_enderecoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o endereço do imóvel.')),
      );
      return;
    }
    if (_cidadeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a cidade.')),
      );
      return;
    }
    if (_estadoCtrl.text.trim().isEmpty ||
        _estadoCtrl.text.trim().length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a UF com 2 letras (ex: GO).')),
      );
      return;
    }
    if (_cepCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o CEP.')),
      );
      return;
    }

    final parcial = {
      ...widget.dadosIniciais,
      'endereco': _enderecoCtrl.text.trim(),
      'cidade': _cidadeCtrl.text.trim(),
      'estado': _estadoCtrl.text.trim().toUpperCase(),
      'cep': _cepCtrl.text.trim(),
      'latitude': _posicao.latitude,
      'longitude': _posicao.longitude,
    };

    final resultado = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => CriarImovelFotosPage(dadosParciais: parcial),
      ),
    );

    if (resultado != null) {
      Navigator.pop(context, resultado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        backgroundColor: _bgPage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Adicionar listagem',
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Qual é o endereço?',
                style: GoogleFonts.poppins(
                  color: _textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Campo endereço
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _pill,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.location_on_outlined, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _enderecoCtrl,
                        maxLines: 2,
                        style:
                            GoogleFonts.poppins(fontSize: 13.5, height: 1.3),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText:
                              'Condomínio dos Jacarés, avenida das Rosas,\nNúmero 66. 77025-666',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(.45),
                            fontSize: 13.5,
                            height: 1.3,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Cidade / Estado / CEP
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _cidadeCtrl,
                      style:
                          GoogleFonts.poppins(fontSize: 13.5, height: 1.3),
                      decoration: InputDecoration(
                        hintText: 'Cidade',
                        isDense: true,
                        filled: true,
                        fillColor: _pill,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _estadoCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style:
                          GoogleFonts.poppins(fontSize: 13.5, height: 1.3),
                      decoration: InputDecoration(
                        hintText: 'UF',
                        isDense: true,
                        filled: true,
                        fillColor: _pill,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _cepCtrl,
                      keyboardType: TextInputType.number,
                      style:
                          GoogleFonts.poppins(fontSize: 13.5, height: 1.3),
                      decoration: InputDecoration(
                        hintText: 'CEP',
                        isDense: true,
                        filled: true,
                        fillColor: _pill,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🗺️ Mapa do Google
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 220,
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _posicao,
                          zoom: 14,
                        ),
                        onMapCreated: (controller) => _mapController = controller,
                        onCameraMove: (pos) => setState(() {
                          _posicao = pos.target;
                        }),
                        markers: {
                          Marker(
                            markerId: const MarkerId('local'),
                            position: _posicao,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueOrange),
                          ),
                        },
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _buscarEnderecoPelaPosicao,
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.92),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Selecionar no mapa',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _irParaFotos,
                  child: Text(
                    'Próximo',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}