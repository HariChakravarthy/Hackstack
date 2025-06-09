import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_model.dart';


class WeatherService {
  final String apiKey = "0f145d547ee9ad7727ce769f74235054";

  Future<Weather?> getWeatherByCity(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<Weather?> getWeatherByLocation(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }
}





