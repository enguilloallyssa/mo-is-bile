import 'package:flutter/material.dart';

class LogisticsShell extends StatelessWidget {
  const LogisticsShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'SARI Logistics',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warehouse_outlined,
                size: 60,
                color: Color(0xFFD48F08),
              ),
              SizedBox(height: 12),
              Text(
                'Logistics Home',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Temporary preview page. We will replace this when we build the Logistics module.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF81786C),
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
