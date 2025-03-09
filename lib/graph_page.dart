import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_service.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _firebaseService.startListening(); // Ambil data dari Firebase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grafik Kejernihan Air"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<List<FlSpot>>(
          valueListenable: _firebaseService.dataNotifier,
          builder: (context, dataKejernihan, child) {
            return dataKejernihan.isEmpty
                ? const Center(child: Text("Belum ada data"))
                : LineChart(
                    LineChartData(
                      minY: 1, // Nilai minimum di sumbu Y
                      maxY: 100, // Nilai maksimum di sumbu Y
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40, // Atur ukuran label sumbu Y
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        _buildLineChartBarData(
                            dataKejernihan, Colors.orange, "Kejernihan"),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(
      List<FlSpot> data, Color color, String label) {
    return LineChartBarData(
      spots: data.isNotEmpty ? data : [FlSpot(0, 0)],
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      belowBarData: BarAreaData(show: false),
      dotData: FlDotData(show: true),
    );
  }
}
