import 'package:flutter/material.dart';
import 'package:weather/splashscreen.dart';
import 'package:weather/weatherscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;
  bool _showSplash = true;

  void toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showSplash = false;  // 👈 Splash hat jayega
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,

      home: _showSplash
          ? const SplashScreen()
          : WeatherScreen(
        key: ValueKey(_isDarkTheme),   // 👈 TRIGGER rebuild
        isDarkTheme: _isDarkTheme,
        toggleTheme: toggleTheme,
      ),
    );
  }
}
