import 'package:flutter/material.dart';

class LoginImageHome extends StatelessWidget {
  final String img;
  const LoginImageHome({super.key, required this.img});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(img,
      width: double.infinity,
      ),
    );
  }
}