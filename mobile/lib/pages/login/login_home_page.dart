import 'package:flutter/material.dart';
import 'package:mobile/pages/login/widgets/login_image.dart';

class LoginHomePage extends StatelessWidget {
  const LoginHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 150, bottom: 26),
                child: LoginImage()
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 30),
                  child: Text('Procurando\num Quartinho?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),),
                )
            ],
          ),
          ),
          
      ),
    );
  }
}