import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiCall {
  Map<String, dynamic>? data;

  static const String _apiKey = '7610d5fa59f2474cb88203021250306';
  static const String _baseUrl = 'https://api.weatherapi.com/v1/forecast.json';

  Future<Map<String, dynamic>?> fetchData() async {
    final url = Uri.parse('$_baseUrl?key=$_apiKey&q=Egypt&days=1&aqi=no');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        data = json.decode(response.body);
        return data;
      } else {
        print('Error ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }
}
