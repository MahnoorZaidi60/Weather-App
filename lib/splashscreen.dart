import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              "https://lottie.host/edcc61fc-a325-4b8d-9ca2-05657fde4a45/uZ0jxfHzlI.json",
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              "Weather App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
