import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String? img;
  final String? value;
  final String? text;
  const CustomCard({super.key, this.img, this.text, this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // shadow color
            spreadRadius: 2, // how far the shadow spreads
            blurRadius: 8, // how soft the shadow is
            offset: Offset(0, 4), // x and y direction
          ),
          
        ],
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: [
          (img != null)
              ? Image.asset(img!, width: 50, height: 50)
              : Icon(Icons.error),
          Text(
            value!,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            text!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFFADB8C5),
            ),
          ),
        ],
      ),
    );
  }
}
