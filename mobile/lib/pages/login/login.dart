import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/pages/login/widgets/button_login.dart';
import 'package:mobile/pages/login/widgets/image_login.dart';
import 'package:mobile/pages/login/widgets/inputs_login.dart';
import 'package:mobile/pages/signup/signup_page.dart';
import 'package:mobile/pages/signup/widgets/buttom_back.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final _emailCtrl = TextEditingController();
    final _senhaCtrl = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(right: 20, top: 20, left: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ButtomBack(),
                ImageLogin(img: 'assets/images/login.png'),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Bem-Vindo!',
                    style: GoogleFonts.roboto(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                InputsLogin(
                  emailController: _emailCtrl,
                  senhaController: _senhaCtrl,
                ),
                SizedBox(height: 20,),
                ButtonLogin(
                  emailController: _emailCtrl,
                  senhaController: _senhaCtrl,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não têm uma conta?',
                      style: GoogleFonts.roboto(
                        color: Color(0xFF404040),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Cadastre-se',
                        style: GoogleFonts.roboto(
                          color: Color(0xFF404040),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }
}
