import 'package:flutter/material.dart';
import 'package:mobile/pages/login/widgets/button_login_email.dart';
import 'package:mobile/pages/login/widgets/buttom_gmail.dart';
import 'package:mobile/pages/login/widgets/login_image.dart';
import 'package:mobile/pages/login/widgets/buttom_facebook.dart';

class LoginHomePage extends StatelessWidget {
  const LoginHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 150, bottom: 26),
                child: LoginImage(),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 30),
                child: Text(
                  'Procurando\num Quartinho?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              //Botão email
              SizedBox(height: 24),
              Container(child: ButtonLoginEmail(onPressed: () {})),

              //Divisão Rodapé
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFFE5E5E5))),
                  Text(' ou ', style: TextStyle(color: Color(0xFFA1A5C1))),
                  Expanded(child: Divider(color: Color(0xFFE5E5E5))),
                ],
              ),

              //Gmail e Facwbook
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(child: ButtomGmail(onPressed: () {})),
                  SizedBox(width: 20),
                  Container(child: ButtomFacebook(onPressed: () {})),
                ],
              ),

              //Cadastre-se
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Não têm uma conta?', 
                  style: TextStyle(color: Color(0xFF404040)),),
                  TextButton(
                    onPressed: () {
                      
                    },
                    child: Text('Cadastre-se',
                    style: TextStyle(
                      color:Color(0xFF404040) ),),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
