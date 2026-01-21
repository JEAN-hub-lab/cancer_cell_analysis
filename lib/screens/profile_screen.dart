import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027), // Dark Theme
      appBar: AppBar(
        title: const Text("Researcher Profile"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // รูปโปรไฟล์แบบเรืองแสง
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.cyanAccent, width: 2),
                boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 20)],
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white10,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Printhorn K.", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("ID: 66133950", style: TextStyle(color: Colors.cyanAccent, fontSize: 16)),
            const SizedBox(height: 40),
            
            // เมนูตั้งค่า
            _buildProfileItem(Icons.settings, "Application Settings"),
            _buildProfileItem(Icons.history, "Export History (CSV)"),
            _buildProfileItem(Icons.help_outline, "Help & Support"),
            
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                 // กลับไปหน้า Login และล้าง Stack ทั้งหมด
                 Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text("LOGOUT", style: TextStyle(color: Colors.redAccent)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
      onTap: () {},
    );
  }
}