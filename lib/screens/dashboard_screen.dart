import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), // ใน AppBar ของ DashboardScreen
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/profile'), icon: const Icon(Icons.person))
        ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text("ประวัติการวิเคราะห์ล่าสุด"),
              subtitle: Text("ยังไม่มีข้อมูลที่บันทึกไว้ในตาราง Analysis_Results"),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/upload'),
            icon: const Icon(Icons.add_a_photo),
            label: const Text("เริ่มการวิเคราะห์ใหม่ (UC 1)"),
          ),
        ],
      ),
    );
  }
}