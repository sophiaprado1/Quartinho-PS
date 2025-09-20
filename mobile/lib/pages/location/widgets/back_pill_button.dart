import 'package:flutter/material.dart';

/// Botão de voltar em formato pill (padrão do app)
class BackPillButton extends StatelessWidget {
  final VoidCallback? onTap;
  const BackPillButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.06),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap ?? () => Navigator.pop(context),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded, // seta fina e elegante
              size: 18,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}