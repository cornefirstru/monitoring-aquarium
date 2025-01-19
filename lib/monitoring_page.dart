import 'package:flutter/material.dart';
import 'detail_page.dart'; // Import DetailPage
import 'monitoring_card.dart'; // Import MonitoringCard

class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Kualitas Air Aquarium'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 16.0, // Horizontal spacing between cards
          mainAxisSpacing: 16.0, // Vertical spacing between cards
          childAspectRatio: 1.2, // Adjust the aspect ratio for better visual balance
          children: [
            MonitoringCard(
              title: 'Suhu Air',
              value: '27°C',
              icon: Icons.thermostat,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailPage(title: 'Suhu Air')),
                );
              },
            ),
            MonitoringCard(
              title: 'Kandungan pH',
              value: '7.2',
              icon: Icons.water_drop,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailPage(title: 'Kandungan pH')),
                );
              },
            ),
            MonitoringCard(
              title: 'Kekeruhan Air',
              value: '10',
              icon: Icons.science,
              color: const Color.fromARGB(255, 156, 146, 0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailPage(title: 'Kekeruhan Air')),
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
                  MaterialPageRoute(builder: (context) => const DetailPage(title: 'Tegangan Listrik')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
