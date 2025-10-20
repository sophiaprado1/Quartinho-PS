import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderImo extends StatelessWidget {
  const HeaderImo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.transparent
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Localização
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFFFFC6F5)),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF2B3A4A), size: 20),
                SizedBox(width: 6),
                Text(
                  'Palmas, Tocantins',
                  style: GoogleFonts.roboto(
                    color: Color(0xFF2B3A4A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2B3A4A), size: 20),
              ],
            ),
          ),
          // Notificação
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFFFFC6F5)),
                ),
                child: Icon(Icons.notifications_none, color: Color(0xFF2B3A4A), size: 26),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          // Avatar
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/44.jpg'),
          ),
        ],
      ),
    );
  }
}