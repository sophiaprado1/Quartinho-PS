import 'package:flutter/material.dart';

class HomeNextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const HomeNextButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9B51E0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        child: const Text(
          'Próximo',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}