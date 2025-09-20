import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ButtomFacebook extends StatelessWidget {
  final VoidCallback? onPressed;
  const ButtomFacebook({super.key, this.onPressed});

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
        child: FaIcon(FontAwesomeIcons.facebook, 
        color: Color(0xFF1877F3), 
        size: 30,
        ),
        ),
    );
  }
}