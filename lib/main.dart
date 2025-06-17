import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:weather/networking/api.dart';
import 'package:weather/settings.dart';
import 'package:weather/widgets/card.dart';
import 'package:weather/widgets/weatherCard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic>? data;
  String? img;
  String? state;
  int tempC = 0;
  int tempF = 0;
  int windPerHour = 0;
  int humidity = 0;
  int chanceRain = 0;
  bool isLoading = true;
  String? errorMessage;
  List? hours;
  List<Widget>? hourlyCards;
  final ScrollController _scrollController = ScrollController();
  int _currentHourIndex = 0;
  bool _isCelsius = true;
  late FlutterSecureStorage _storage;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _storage = const FlutterSecureStorage();
    _loadTemperaturePreference().then((_) => fetchData());
  }

  Future<void> _loadTemperaturePreference() async {
    try {
      final savedUnit = await _storage.read(key: 'temperature_unit');
      if (savedUnit != null) {
        setState(() {
          _isCelsius = savedUnit == 'celsius';
        });
      }
    } catch (e) {
      debugPrint('Error loading temperature preference: $e');
    }
  }

  String convertToAmPm(String time24) {
    try {
      List<String> parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      String period = hour < 12 ? 'am' : 'pm';
      hour = hour % 12;
      hour = hour == 0 ? 12 : hour;

      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      ApiCall apiCall = ApiCall();
      data = await apiCall.fetchData();

      if (data == null) {
        throw Exception("No data received from API");
      }

      setState(() {
        img = data!["current"]?["condition"]?["icon"] ?? "";
        state = data!["current"]?["condition"]?["text"] ?? "Unknown";
        tempC = data!["current"]?["temp_c"]?.toInt() ?? 0;
        tempF = (tempC * 9 / 5 + 32).toInt(); // Convert to Fahrenheit
        windPerHour = data!["current"]?["wind_kph"]?.toInt() ?? 0;
        humidity = data!["current"]?["humidity"]?.toInt() ?? 0;
        chanceRain =
            data!["forecast"]?["forecastday"]?[0]?["day"]?["daily_chance_of_rain"]
                ?.toInt() ??
            0;
        hours = data!["forecast"]?["forecastday"]?[0]?["hour"] ?? [];

        final now = DateTime.now();
        final currentHour = now.hour;
        _currentHourIndex = 0;

        hourlyCards = hours?.map<Widget>((hourData) {
          String time24 = hourData["time"].split(" ")[1].substring(0, 5);
          int hour = int.parse(time24.split(':')[0]);
          int temp = _isCelsius
              ? hourData["temp_c"]?.toInt() ?? 0
              : ((hourData["temp_c"] * 9 / 5 + 32).toInt());
          String img = hourData["condition"]?["icon"] ?? "";

          bool isNow = hour == currentHour;
          if (isNow) {
            _currentHourIndex = hours!.indexOf(hourData);
          }

          return WeatherCard(
            temperature: _isCelsius ? "$temp °C" : "$temp °F",
            time: convertToAmPm(time24),
            img: img,
            now: isNow,
          );
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load weather data: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          hourlyCards != null &&
          hourlyCards!.isNotEmpty) {
        final screenWidth = MediaQuery.of(context).size.width;
        const cardWidth = 110;
        final targetPosition =
            _currentHourIndex * cardWidth - (screenWidth / 2) + (cardWidth / 2);

        _scrollController.animateTo(
          targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: fetchData,
                        icon: const Icon(Icons.refresh),
                      ),
                      Builder(
                        builder: (BuildContext context) {
                          return IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context, // This context is now a descendant of the Navigator
                                MaterialPageRoute(
                                  builder: (_) => SettingsScreen(
                                    onUnitChanged: (newValue) {
                                      setState(() {
                                        _isCelsius = newValue;
                                      });
                                      fetchData();
                                    },
                                    initialIsCelsius: _isCelsius,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.black54,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (errorMessage != null)
                    Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 50,
                          color: Colors.red,
                        ),
                        Text(errorMessage!),
                        ElevatedButton(
                          onPressed: fetchData,
                          child: const Text("Retry"),
                        ),
                      ],
                    )
                  else ...[
                    if (img != null && img!.isNotEmpty)
                      Image.network(
                        "https:$img",
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.cloud_off, size: 60),
                      ),

                    Text(
                      _isCelsius ? '$tempC°C' : '$tempF°F',
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      state ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFADB8C5),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            CustomCard(
                              img: "images/wind.png",
                              text: "Wind",
                              value: "$windPerHour km/h",
                            ),
                            const SizedBox(width: 12),
                            CustomCard(
                              img: "images/humidity.png",
                              text: "Humidity",
                              value: "$humidity%",
                            ),
                            const SizedBox(width: 12),
                            CustomCard(
                              img: "images/rain.png",
                              text: "Rain",
                              value: "$chanceRain%",
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Today",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: hourlyCards?.length ?? 0,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) => hourlyCards![index],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
