import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Tambahkan ini

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("sensor");

  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final List<FlSpot> _dataKejernihan = [];
  final ValueNotifier<List<FlSpot>> dataNotifier = ValueNotifier([]);
  int _index = 0;

  void startListening() async {
    await _loadLocalData(); // Muat data dari SharedPreferences

    _database.child("kejernihan").onValue.listen((event) async {
      if (event.snapshot.value != null) {
        double? newValue = double.tryParse(event.snapshot.value.toString());
        if (newValue != null) {
          _dataKejernihan.add(FlSpot(_index.toDouble(), newValue));

          if (_dataKejernihan.length > 20) {
            _dataKejernihan.removeAt(0); // Hapus data lama agar tidak overload
          }

          _index++;
          dataNotifier.value = List.from(_dataKejernihan); // Update UI
          await _saveLocalData(); // Simpan ke SharedPreferences
        }
      }
    });
  }

  Future<void> _saveLocalData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, double>> mappedData =
        _dataKejernihan.map((spot) => {"x": spot.x, "y": spot.y}).toList();
    await prefs.setString("kejernihan_data", jsonEncode(mappedData));
  }

  Future<void> _loadLocalData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString("kejernihan_data");

    if (jsonData != null) {
      final List<dynamic> decodedData = jsonDecode(jsonData);
      _dataKejernihan.clear();
      _dataKejernihan.addAll(decodedData.map((item) => FlSpot(
          (item['x'] as num).toDouble(), (item['y'] as num).toDouble())));

      _index =
          _dataKejernihan.isNotEmpty ? _dataKejernihan.last.x.toInt() + 1 : 0;
      dataNotifier.value =
          List.from(_dataKejernihan); // Update UI setelah memuat data
    }
  }
}
