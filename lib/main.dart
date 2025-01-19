import 'package:flutter/material.dart';
import 'monitoring_page.dart'; // Import MonitoringPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoring Air',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MonitoringPage(), // Arahkan ke halaman MonitoringPage
    );
  }
}
