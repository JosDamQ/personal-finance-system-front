import 'package:flutter/material.dart';
import '../../widgets/common/app_drawer.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Reports & Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
            SizedBox(height: 8),
            Text('This screen will show financial reports and analytics', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}