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
  bool _feederStatus = false;
  String? _currentTime;
  final TextEditingController _newDurationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  Map<dynamic, dynamic> _scheduledFeedings = {};
  int _feederDuration = 5;
  Timer? _clockTimer;
  bool _isFeedingActive = false; // Tambahkan ini
  String? _lastActivatedTime; // Menyimpan waktu terakhir yang telah diproses

  @override
  void initState() {
    super.initState();
    _fetchFeederStatus();
    _fetchScheduledFeedings();
    _fetchFeederDuration();
    _checkScheduledFeeding();
    _startRealTimeClock();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startRealTimeClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final now = DateTime.now().toUtc().add(const Duration(hours: 8));
        setState(() {
          _currentTime = DateFormat('HH:mm').format(now);
        });
        _checkScheduledFeeding();
      }
    });
  }

  void _fetchFeederStatus() {
    _databaseRef.child('feeder/active').onValue.listen((event) {
      final status = event.snapshot.value;
      setState(() {
        _feederStatus = status == true;
      });
    });
  }

  void _addScheduledFeeding() {
    final selectedTime = _timeController.text.trim();
    final durationText = _newDurationController.text.trim();

    if (selectedTime.isEmpty || durationText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Mohon isi waktu dan durasi dengan benar')),
      );
      return;
    }

    final duration = int.tryParse(durationText) ?? 5;

    _databaseRef.child('jadwal/$selectedTime').set({
      'active': true,
      'duration': duration,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal berhasil ditambahkan!')),
      );
      _timeController.clear();
      _newDurationController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan jadwal: $error')),
      );
    });
  }

  void _fetchFeederDuration() {
    _databaseRef.child('feeder/duration').onValue.listen((event) {
      final duration = event.snapshot.value as int?;
      if (duration != null) {
        setState(() {
          _feederDuration = duration;
        });
      }
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
    if (_currentTime != null &&
        _scheduledFeedings.containsKey(_currentTime) &&
        _scheduledFeedings[_currentTime]!['active'] == true) {
      final duration =
          _scheduledFeedings[_currentTime]!['duration'] ?? _feederDuration;
      _activateScheduledFeeding(duration, _currentTime!);
    }
  }

  void _activateFeeder() async {
    final durationSnapshot = await _databaseRef.child('feeder/duration').get();
    if (durationSnapshot.exists) {
      int duration =
          durationSnapshot.value as int; // Ambil nilai durasi dari Firebase

      // Mengaktifkan feeder dan menyimpan timestamp
      await _databaseRef.child('feeder/active').set(true);
      await _databaseRef
          .child('timestamp')
          .set(DateTime.now().millisecondsSinceEpoch);

      // Mengatur timer untuk menonaktifkan feeder setelah durasi selesai
      Timer(Duration(seconds: duration), () async {
        await _databaseRef.child('feeder/active').set(false);
      });
    } else {
      print('Durasi tidak ditemukan di Firebase.');
    }
  }

  void _activateScheduledFeeding(int duration, String currentTime) async {
    if (_isFeedingActive || _lastActivatedTime == currentTime)
      return; // Cegah eksekusi jika sudah aktif atau sudah diproses

    final activeSnapshot = await _databaseRef.child('feeder/active').get();
    if (activeSnapshot.value == true) {
      _isFeedingActive = true;
      _lastActivatedTime = currentTime; // Simpan waktu yang telah diproses
      return;
    }

    _isFeedingActive = true;
    _lastActivatedTime = currentTime;

    await _databaseRef.child('feeder/active').set(true);
    await _databaseRef
        .child('timestamp')
        .set(DateTime.now().millisecondsSinceEpoch);

    Timer(Duration(seconds: duration), () {
      _databaseRef.child('feeder/active').set(false);
      _isFeedingActive = false;
    });
  }

  void _updateFeederDuration() {
    final durationText = _durationController.text.trim();
    if (durationText.isNotEmpty) {
      final duration = int.tryParse(durationText) ?? 5;
      _databaseRef.child('feeder/duration').set(duration);
      _durationController.clear();
    }
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
              const Text('Pengaturan Feeder', style: TextStyle(fontSize: 18)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Set Durasi Pakan (detik)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _updateFeederDuration();
                        _activateFeeder();
                      },
                      child: const Text('Buka Feeder'),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Text('Status Feeder: ${_feederStatus ? 'Aktif' : 'Nonaktif'}'),
              const SizedBox(height: 20),
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
                      controller: _newDurationController,
                      decoration: const InputDecoration(
                        labelText: 'Durasi (detik)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: _addScheduledFeeding,
                child: const Text('Tambah Jadwal'),
              ),
              const SizedBox(height: 10),
              const Text('Jadwal Pemberian Pakan Otomatis',
                  style: TextStyle(fontSize: 18)),
              Text('Waktu Saat Ini (WITA): $_currentTime'),
              const SizedBox(height: 10),
              ..._scheduledFeedings.keys.map((key) {
                final feedingData = _scheduledFeedings[key];
                final isActive = feedingData['active'] ?? false;
                final int duration = feedingData['duration'] ?? 5;

                // Mengecek apakah waktu saat ini sama dengan waktu yang ada di jadwal
                final now =
                    DateTime.now().toUtc().add(const Duration(hours: 8));
                final currentTime = DateFormat('HH:mm').format(now);

                if (currentTime == key && isActive) {
                  _activateScheduledFeeding(duration, currentTime);
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Waktu: $key',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Durasi: $duration detik',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Switch(
                              value: isActive,
                              onChanged: (value) {
                                _databaseRef
                                    .child('jadwal/$key/active')
                                    .set(value);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _databaseRef.child('jadwal/$key').remove();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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
