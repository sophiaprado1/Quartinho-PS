import 'package:flutter/material.dart';

class ButtomBack extends StatelessWidget {
  const ButtomBack({super.key});

  static const colorIcon = Color(0xFF404040);
  static const btColor = Color(0xFFF5F4F8);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: btColor,
          shape: CircleBorder(),
        ),
        child: Icon(Icons.arrow_back_ios, size: 18, color: colorIcon,),
      ),
    );
  }
}
