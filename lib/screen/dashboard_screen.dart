import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F4EE),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'SARI',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: const Center(
        child: Text(
          'Dashboard will be connected next.',
          style: TextStyle(
            color: Color(0xFF756D63),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
