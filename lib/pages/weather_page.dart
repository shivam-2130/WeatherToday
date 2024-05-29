import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_api/service/weather_service.dart';
import '../models/weather_model.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService =
      WeatherService(apiKey: '879e2b6ed0fa409413ec6b0f114067eb');
  Weather? _weather;
  String? _cityName;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _fetchWeather([String? cityName]) async {
    try {
      if (cityName == null || cityName.isEmpty) {
        cityName = await _weatherService.getCurrentCity();
      }
      setState(() {
        _cityName = cityName;
      });

      final weather = await _weatherService.getWeather(_cityName!);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
      print("ERROR");
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/rainy.json'; // default

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny2.json';
      default:
        return 'assets/sunny2.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 80),
          child: const Center(child: Text("Weather Today")),
        ),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(
            icon: Icon(Icons.search_outlined),
            onPressed: () {
              showSearchDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.location_searching_sharp),
            onPressed: () {
              _fetchWeather();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_cityName ?? "Loading city..."),
            if (_weather != null) ...[
              Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
              Text('${_weather?.temperature.round()}°C'),
              Text(_weather?.mainCondition ?? ""),
            ] else ...[
              Lottie.asset('assets/sunny2.json'),
              Text("Loading weather data..."),
            ],
          ],
        ),
      ),
    );
  }

  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Search City"),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(hintText: "Enter city name"),
          ),
          actions: [
            TextButton(
              child: Text("Search"),
              onPressed: () {
                Navigator.of(context).pop();
                _fetchWeather(_searchController.text);
              },
            ),
          ],
        );
      },
    );
  }
}
