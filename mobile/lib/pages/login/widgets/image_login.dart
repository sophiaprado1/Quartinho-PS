import 'package:flutter/material.dart';

class ImageLogin extends StatelessWidget {
  final String img;
  const ImageLogin({super.key, required this.img});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(img,
      fit: BoxFit.contain,
      ),
    );
  }
}