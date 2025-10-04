import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile/core/constants.dart';
import 'package:mobile/pages/imoveis/widgets/header_imo.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/pages/imoveis/widgets/search_imoveis.dart';
import 'package:mobile/pages/imoveis/widgets/imovel_card.dart';
import 'package:mobile/pages/imoveis/widgets/filtros_imoveis.dart';
import 'package:mobile/pages/imoveis/imovel_detalhe_page.dart';

class ImoveisPage extends StatefulWidget {
  final String token;
  const ImoveisPage({Key? key, required this.token}) : super(key: key);

  @override
  State<ImoveisPage> createState() => _ImoveisPageState();
}

class _ImoveisPageState extends State<ImoveisPage> {
  final List<String> filtros = ['Tudo', 'Casa', 'Apartamento', 'Kitnet'];
  int filtroSelecionado = 0;
  List<dynamic> imoveis = [];
  List<dynamic> get imoveisFiltrados {
    if (filtroSelecionado == 0) return imoveis;
    final tipo = filtros[filtroSelecionado].toLowerCase();
    return imoveis.where((imo) => (imo['tipo'] ?? '').toLowerCase() == tipo).toList();
  }
  bool loading = true;
  String? firstName;

  @override
  void initState() {
    super.initState();
    print('TOKEN: ${widget.token}');
    fetchUserFirstName();
    fetchImoveis();
  }

  Future<void> fetchUserFirstName() async {
    try {
      final response = await http.get(
        Uri.parse('$backendHost/api/locadores/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final List users = json.decode(utf8.decode(response.bodyBytes));
        // Busca o usuário logado pelo token (normalmente só retorna 1)
        if (users.isNotEmpty) {
          setState(() {
            firstName = users[0]['first_name'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Erro ao buscar first_name: $e');
    }
  }

  Future<void> fetchImoveis() async {
    final response = await http.get(
      Uri.parse('$backendHost/api/imoveis/'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      setState(() {
        imoveis = json.decode(utf8.decode(response.bodyBytes));
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao buscar imóveis')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            //Ciculo Decorativo
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  // Objeto de fundo (círculo decorativo)
                  Positioned(
                    top: -115,
                    left: -110,
                    child: Container(
                      width: 360,
                      height: 360,
                      decoration: BoxDecoration(
                        color: Color(0XFFFebdbfc),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  //Nome do Usuario
                  Positioned(
                    top: 100,
                    left: 32,
                    child: Text(
                      firstName != null && firstName!.isNotEmpty
                          ? "Oi, $firstName!"
                          : "Oi",
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Header por cima
                  HeaderImo(),
                  // Campo de busca
                  Positioned(
                    top: 200,
                    left: 16,
                    right: 16,
                    child: Container(
                      child: SearchImoveis(),
                    ),
                  ),
                ],
              ),
            ),
            // Filtros
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
              child: FiltrosImoveis(
                filtros: filtros,
                filtroSelecionado: filtroSelecionado,
                onFiltroSelecionado: (index) {
                  setState(() => filtroSelecionado = index);
                },
              ),
            ),
            //Listagem de Imoveis
            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: imoveisFiltrados.length,
                      itemBuilder: (context, index) {
                        final imovel = imoveisFiltrados[index];
                        final fotos = imovel['fotos'] as List<dynamic>?;
                        final fotoUrl =
                            (fotos != null &&
                                fotos.isNotEmpty &&
                                fotos[0]['imagem'] != null &&
                                fotos[0]['imagem'] != "")
                                ? (fotos[0]['imagem'].toString().startsWith('http')
                                    ? fotos[0]['imagem']
                                    : '$backendHost${fotos[0]['imagem']}')
                                : null;
                        final preco = imovel['preco_total'] != null ? 'R\$ ${imovel['preco_total']}' : '-';
                        final titulo = imovel['titulo'] ?? '';
                        // Exemplo: rating e distancia fake (adicione campos reais se existirem)
                        final rating = 4.8 + (index % 3) * 0.1;
                        final distancia = index % 2 == 0 ? '200 m' : '1.5 km';
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImovelDetalhePage(imovel: imovel),
                              ),
                            );
                          },
                          child: ImovelCard(
                            imageUrl: fotoUrl,
                            title: titulo,
                            preco: preco,
                            rating: rating,
                            distancia: distancia,
                            favorito: false,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
