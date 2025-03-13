import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class FeedingPage extends StatefulWidget {
  const FeedingPage({super.key});

  @override
  _FeedingPageState createState() => _FeedingPageState();
}

class _FeedingPageState extends State<FeedingPage> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child('pemberian_pakan');
  bool _manualFeeding = false;
  String? _currentTime;
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  Map<dynamic, dynamic> _scheduledFeedings = {};
  Timer? _manualFeedingTimer;

  @override
  void initState() {
    super.initState();
    _fetchManualFeedingStatus();
    _fetchScheduledFeedings();
    _checkScheduledFeeding();
  }

  void _fetchManualFeedingStatus() {
    _databaseRef.child('manual/status').onValue.listen((event) {
      final status = event.snapshot.value.toString();
      setState(() {
        _manualFeeding = (status == 'on');
      });
    });
  }

  void _fetchScheduledFeedings() {
    _databaseRef.child('jadwal').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      setState(() {
        _scheduledFeedings = data;
      });
    });
  }

  void _checkScheduledFeeding() {
    _databaseRef.child('jadwal').onValue.listen((event) {
      final now = DateTime.now().toUtc().add(const Duration(hours: 8));
      final currentTime = DateFormat('HH:mm').format(now);

      setState(() {
        _currentTime = currentTime;
      });

      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      if (data.containsKey(currentTime) &&
          data[currentTime]['active'] == true) {
        int duration = data[currentTime]['duration'] ?? 5;
        _activateServo(duration);
        print("Waktu terjadwal terdeteksi: $currentTime (WITA)");
      }
    });
  }

  void _activateServo(int duration) {
    _databaseRef.child('manual/status').set('on');
    _manualFeedingTimer = Timer(Duration(seconds: duration), () {
      _databaseRef.child('manual/status').set('off');
      setState(() {
        _manualFeeding = false;
      });
    });
  }

  void _addScheduledFeeding() {
    final selectedTime = _timeController.text.trim();
    final durationText = _durationController.text.trim();
    if (selectedTime.isNotEmpty && durationText.isNotEmpty) {
      final duration = int.tryParse(durationText) ?? 5;
      _databaseRef.child('jadwal/$selectedTime').set({
        'active': true,
        'duration': duration,
      });
      _timeController.clear();
      _durationController.clear();
    }
  }

  void _toggleScheduledFeeding(String time, bool isActive) {
    _databaseRef.child('jadwal/$time/active').set(isActive);
  }

  void _activateManualFeeding() {
    _databaseRef.child('manual/duration').once().then((event) {
      final durationValue = event.snapshot.value;
      final duration = int.tryParse(durationValue.toString()) ?? 5;
      _activateServo(duration);
    });
  }

  @override
  void dispose() {
    _manualFeedingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pemberian Pakan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pemberian Pakan Manual',
                  style: TextStyle(fontSize: 18)),
              ElevatedButton(
                onPressed: _activateManualFeeding,
                child: const Text('Aktifkan Pakan Manual'),
              ),
              const SizedBox(height: 20),
              const Text('Tambah Jadwal Pakan', style: TextStyle(fontSize: 18)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Masukkan Waktu (HH:MM)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Durasi (detik)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addScheduledFeeding,
                    child: const Text('Tambah'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Jadwal Pemberian Pakan Otomatis',
                  style: TextStyle(fontSize: 18)),
              Text('Waktu Saat Ini (WITA): $_currentTime'),
              const SizedBox(height: 10),
              ..._scheduledFeedings.keys.map((key) {
                bool isActive = _scheduledFeedings[key]['active'] == true;
                int duration = _scheduledFeedings[key]['duration'] ?? 5;
                return ListTile(
                  title: Text('$key - Durasi: $duration detik'),
                  trailing: Switch(
                    value: isActive,
                    onChanged: (value) {
                      _toggleScheduledFeeding(key, value);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
