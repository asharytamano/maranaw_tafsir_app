import 'package:flutter/material.dart';
import 'pages/landing_page.dart';

void main() {
  runApp(const MaranawTafsirApp());
}

class MaranawTafsirApp extends StatelessWidget {
  const MaranawTafsirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maranaw Tafsir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const LandingPage(),
    );
  }
}
