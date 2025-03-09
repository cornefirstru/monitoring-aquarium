import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'detail_page.dart'; // Import DetailPage
import 'monitoring_card.dart'; // Import MonitoringCard
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  _MonitoringPageState createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String suhu = "-";
  String ph = "-";
  String kejernihan = "-";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _database.child("sensor/suhu").onValue.listen((event) {
      setState(() {
        suhu = event.snapshot.value.toString();
      });
    });

    _database.child("sensor/ph").onValue.listen((event) {
      setState(() {
        ph = event.snapshot.value.toString();
      });
    });

    _database.child("sensor/kejernihan").onValue.listen((event) {
      setState(() {
        kejernihan = event.snapshot.value.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Kualitas Air Aquarium'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.2,
          children: [
            MonitoringCard(
              title: 'Suhu Air',
              value: '$suhu°C',
              icon: Icons.thermostat,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const DetailPage(title: 'Suhu Air')),
                );
              },
            ),
            MonitoringCard(
              title: 'Kandungan pH',
              value: ph,
              icon: Icons.water_drop,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const DetailPage(title: 'Kandungan pH')),
                );
              },
            ),
            MonitoringCard(
              title: 'Kekeruhan Air',
              value: kejernihan,
              icon: Icons.science,
              color: const Color.fromARGB(255, 156, 146, 0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const DetailPage(title: 'Kekeruhan Air')),
                );
              },
            ),
            MonitoringCard(
              title: 'Tegangan Listrik',
              value: 'Ada Atau',
              icon: Icons.flash_on,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const DetailPage(title: 'Tegangan Listrik')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
