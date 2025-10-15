import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Set a nice default dark theme for a modern look
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1E213A), // Dark background
        fontFamily: 'Montserrat', // You can choose a custom font later
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
