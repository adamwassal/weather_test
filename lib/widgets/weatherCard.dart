import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String time;
  final String img;
  final String temperature;
  final bool isLast;
  final bool now;

  const WeatherCard({
    required this.time,
    required this.temperature,
    required this.img,
    this.isLast = false,
    this.now = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: now ? 86 :80,


      padding: EdgeInsets.all(4),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: now ? Colors.blueAccent: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$temperature',
            style: TextStyle(
              fontSize: now? 20 :20,
              fontWeight: FontWeight.bold,
              color: now ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Image.network("https:$img", width: 70,),
          const SizedBox(height: 8),
          Text(
            isLast ? 'Next day' : time,
            style: TextStyle(
              fontSize: now? 18 :16,
              color: now ? Colors.white : Colors.black
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherData {
  final String time;
  final int temperature;

  WeatherData({
    required this.time,
    required this.temperature,
  });
}