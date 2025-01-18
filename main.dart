import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        useMaterial3: true,  // Ensure Material 3 is enabled for Flutter 2.0+
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Using bodyLarge for Material 3
        ),
      ),
      home: WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final String apiKey = '6f071e48abe2e4afa820796faf747490'; // API Key
  String city = 'London';
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  String errorMessage = '';

  // Function to fetch weather data
  Future<void> fetchWeather(String cityName) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric');

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          weatherData = null;
          errorMessage = 'City not found! Please try again.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        weatherData = null;
        errorMessage = 'Failed to fetch data. Please check your internet connection.';
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // Add your background image here
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input TextField to enter city name
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter city name',
                labelStyle: TextStyle(color: const Color.fromRGBO(11, 9, 136, 1)),
                hintText: 'e.g. London',
                hintStyle: TextStyle(color: const Color.fromARGB(137, 142, 44, 44)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: const Color.fromARGB(255, 214, 222, 143).withOpacity(0.7),
              ),
              onSubmitted: (value) {
                setState(() {
                  city = value;
                  fetchWeather(city);
                });
              },
            ),
            SizedBox(height: 20),

            // Show Loading Indicator while fetching data
            isLoading
                ? Center(child: CircularProgressIndicator())
                : weatherData == null
                    ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.white, fontSize: 18)))
                    : Column(
                        children: [
                          // Weather City Name
                          Center(
                            child: Text(
                              weatherData!['name'],
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          // Weather Temperature
                          Center(
                            child: Text(
                              '${weatherData!['main']['temp']}°C',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          // Weather Description
                          Center(
                            child: Text(
                              weatherData!['weather'][0]['description'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Weather Icon
                          Center(
                            child: Image.network(
                              'http://openweathermap.org/img/wn/${weatherData!['weather'][0]['icon']}@2x.png',
                              height: 100,
                              width: 100,
                            ),
                          ),
                          SizedBox(height: 30),

                          // Humidity and Wind Speed Information
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Icon(Icons.water_drop, color: Colors.white),
                                  Text(
                                    '${weatherData!['main']['humidity']}%',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text('Humidity', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(Icons.air, color: Colors.white),
                                  Text(
                                    '${weatherData!['wind']['speed']} m/s',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text('Wind Speed', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
          ],
        ),
      ),
    );
  }
}
