import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase.options.dart'; // Pastikan file ini ada

import 'monitoring_page.dart'; // Sesuaikan dengan halaman utama kamu

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MonitoringPage(),
    );
  }
}
