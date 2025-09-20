import 'package:flutter/material.dart';

class ButtonLoginEmail extends StatelessWidget {
  final VoidCallback? onPressed;
  const ButtonLoginEmail({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      width: 270,
      child: ElevatedButton(
        onPressed: onPressed, 
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF8533),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        child: Center(
          child: Row(
            children: [
              Icon(Icons.email,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text('Continuar com Email',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),),
            ],
          ),
        ),
        ),
    );
  }
}