import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ข้อมูลผู้ใช้งาน")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            const Text("นักวิจัย: ปรินทร คงผล", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("รหัสนักศึกษา: 66133950", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("ตั้งค่าแอปพลิเคชัน"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("ออกจากระบบ", style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
            ),
          ],
        ),
      ),
    );
  }
}