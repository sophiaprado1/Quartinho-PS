import 'package:flutter/material.dart';

class PageIndicator extends StatefulWidget {
  final int currentPage;
  final int pageCount;
  
  const PageIndicator({
    super.key,
    required this.currentPage,
    this.pageCount =3
    });

  @override
  State<PageIndicator> createState() => _PageIndicatorState();
}

class _PageIndicatorState extends State<PageIndicator> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.pageCount, (index){
        bool isActive = index == widget.currentPage;
        return Container(
          margin: EdgeInsetsGeometry.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? Color(0xFF9B51E0) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        );
      })
      
    );
  }
}