import 'package:flutter/material.dart';

class ButtomGmail extends StatelessWidget {
  final VoidCallback? onPressed;
  const ButtomGmail({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 158,
      height: 70,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFF5F4F8),
        ),
        onPressed: onPressed, 
        child: Image.asset('assets/images/logo_gmail.png',
        height: 30,
        width: 30,
        fit: BoxFit.contain,
        ),
        ),
    );
  }
}