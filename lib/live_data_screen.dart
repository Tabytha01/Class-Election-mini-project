import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LiveDataScreen extends StatefulWidget {
  const LiveDataScreen({super.key});

  @override
  State<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends State<LiveDataScreen> {
  bool loading = true;
  String? error;
  double? temperature;
  double? windspeed;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await http
          .get(Uri.parse(
              'https://api.open-meteo.com/v1/forecast?latitude=-1.94&longitude=30.06&current_weather=true'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception('Bad status');
      }
      final data = jsonDecode(response.body);
      final current = data['current_weather'];
      if (!mounted) return;
      setState(() {
        temperature = (current['temperature'] as num).toDouble();
        windspeed = (current['windspeed'] as num).toDouble();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load the weather. Check your internet connection.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Data')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : error != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 48),
                      const SizedBox(height: 12),
                      Text(error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: fetchWeather,
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Kigali right now',
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('$temperature °C',
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Wind: $windspeed km/h'),
                    ],
                  ),
      ),
    );
  }
}
