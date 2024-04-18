import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_application/app_id.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  
  String cityName = 'noida';
  TextEditingController weatherInput = TextEditingController();


  Future<Map<String, dynamic>> getData(cityName) async {
    try {
      final result = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apiKey'));

      final data = jsonDecode(result.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error ocurred';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  Widget customSearchBar = const Text('Weather App');
  Icon customIcon = const Icon(Icons.search);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: () {
            const CircularProgressIndicator();
            setState(() {
              if (customIcon.icon == Icons.search) {
                customIcon = const Icon(Icons.cancel);
                customSearchBar = TextField(
                  controller: weatherInput,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                );
              } else {
                customSearchBar = const Text('Weather App');
                customIcon = const Icon(Icons.search);
              }
              cityName = (weatherInput.text).toString();
            });
          },
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () {
            getData(cityName);
          },
          icon: const Icon(Icons.refresh),
        ),
      ], title: customSearchBar),
      body: FutureBuilder(
        future: getData(cityName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final data = snapshot.data!;

          final currentData = data['list'][0];

          final mainTemp = currentData['main']['temp'];
          final mainWeather = currentData['weather'][0]['main'];
          final mainHumidity = currentData['main']['humidity'];
          final mainWindSpeed = currentData['wind']['speed'];
          final mainPressure = currentData['main']['pressure'];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      cityName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  //mainCard
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  (mainTemp - 273).toStringAsFixed(2) + ' °C',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Icon(
                                    mainWeather == 'Clouds'
                                        ? Icons.cloud
                                        : (mainWeather == 'Rain'
                                            ? Icons.beach_access_rounded
                                            :(mainWeather == 'Snow')? Icons.snowing :  Icons.sunny),
                                    size: 64),
                                const SizedBox(height: 5),
                                Text(
                                  mainWeather,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //weatherForecastCards
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Weather Forecast',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        final hourlyUpdate = data['list'][index + 1];
                        final hourlyWeatherUpdate = hourlyUpdate['weather'];
                        final time = DateTime.parse(hourlyUpdate['dt_txt']);
                        return ForecastCard(
                          time: DateFormat.Hm().format(time),
                          icon: hourlyWeatherUpdate[0]['main'].toString() ==
                                  'Clouds'
                                        ? Icons.cloud
                                        : (mainWeather == 'Rain'
                                            ? Icons.beach_access_rounded
                                            :(mainWeather == 'Snow')? Icons.snowing :  Icons.sunny),
                          temp: (hourlyUpdate['main']['temp'] - 273)
                                  .toStringAsFixed(0) +
                              ' °C',
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  //restStuff
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      AdditionalInfoCard(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: '$mainHumidity%',
                      ),
                      AdditionalInfoCard(
                        icon: Icons.wind_power_rounded,
                        label: 'Wind Speed',
                        value: '$mainWindSpeed m/s',
                      ),
                      AdditionalInfoCard(
                        icon: Icons.keyboard_double_arrow_down_rounded,
                        label: 'Pressure',
                        value: '$mainPressure hPa',
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ForecastCard extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;
  const ForecastCard({
    super.key,
    required this.time,
    required this.icon,
    required this.temp,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    time,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Icon(
                    icon,
                    size: 32,
                  ),
                  const SizedBox(height: 5),
                  Text(temp),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdditionalInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdditionalInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}
