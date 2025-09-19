import 'package:flutter/material.dart';
import 'package:mobile/pages/login/login_home_page.dart';

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
              backgroundColor: Colors.grey[350],
            ),
            onPressed: (){
              Navigator.push(context,
               MaterialPageRoute(builder: (context) => LoginHomePage()));
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