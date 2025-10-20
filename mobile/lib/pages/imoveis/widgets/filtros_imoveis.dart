import 'package:flutter/material.dart';

class FiltrosImoveis extends StatelessWidget {
  final List<String> filtros;
  final int filtroSelecionado;
  final ValueChanged<int> onFiltroSelecionado;

  const FiltrosImoveis({
    super.key,
    required this.filtros,
    required this.filtroSelecionado,
    required this.onFiltroSelecionado,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filtros.length,
        itemBuilder: (context, index) {
          final selecionado = filtroSelecionado == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => onFiltroSelecionado(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: selecionado ? Color(0xFFCBACFF) : Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  filtros[index],
                  style: TextStyle(
                    color: selecionado ? Colors.white : Color(0xFF23235B),
                    fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
