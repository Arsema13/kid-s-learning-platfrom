import 'package:flutter/material.dart';

class ScreenTemplate extends StatelessWidget {
  final String title;
  const ScreenTemplate({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Text(
          '$title Content Coming Soon...',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
