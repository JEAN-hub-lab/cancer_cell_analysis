import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'dart:ui'; // สำหรับ Glassmorphism

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      // พื้นหลัง Gradient แบบ Premium
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Center(
          child: user == null 
            ? const Text("No User Logged In", style: TextStyle(color: Colors.white))
            : FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator(color: Colors.cyanAccent);
                  
                  var userData = snapshot.data!.data() as Map<String, dynamic>;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.cyanAccent,
                        child: Icon(Icons.person, size: 60, color: Colors.black54),
                      ),
                      const SizedBox(height: 30),
                      
                      // การ์ดข้อมูลผู้ใช้แบบกระจก
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 320,
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Column(
                              children: [
                                _infoRow(Icons.badge, "Username", userData['username'] ?? '-'),
                                const Divider(color: Colors.white24),
                                _infoRow(Icons.email, "Email", userData['email'] ?? '-'),
                                const Divider(color: Colors.white24),
                                _infoRow(Icons.verified_user, "UID", user.uid.substring(0, 5) + "..."),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      ElevatedButton.icon(
                        onPressed: () {
                          AuthService().logout();
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text("LOGOUT"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                      )
                    ],
                  );
                },
              ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}