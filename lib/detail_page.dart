import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String title;

  const DetailPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Detail informasi untuk $title',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
