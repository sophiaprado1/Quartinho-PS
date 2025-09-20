import 'package:flutter/material.dart';
import 'package:mobile/core/app_routes.dart';


class HomeHeader extends StatelessWidget {
  
  const HomeHeader({ Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
          
              ),
              padding: EdgeInsets.all(15),
              child: Image.asset(
                'assets/images/logo.png',
                height: 60,
                width: 60,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 8),
            SizedBox(),
          ],
        ),
        SizedBox(
          width: 110,
          height: 45,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF5F4F8),
            ),
            onPressed: (){
              Navigator.pushNamed(context, AppRoutes.loginHome);
            }, 
            child: Text(
              'Pular',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w300,
              ),
            ),
            ),
        ),
      ],
    );
  }
}