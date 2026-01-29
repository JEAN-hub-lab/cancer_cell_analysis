import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();

  // ฟังก์ชันโชว์ Dialog แก้ไขชื่อ
  void _showEditProfileDialog(BuildContext context, String currentName) {
    final nameCtrl = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Username",
                labelStyle: TextStyle(color: Colors.cyanAccent),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                // ✅ บันทึกลง Database จริงๆ
                await _db.updateUserProfile(nameCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile Updated!"), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับปุ่มที่ยังไม่ทำ (กดแล้วให้ขึ้นเตือนว่า Coming Soon)
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$feature is coming soon!"), 
        backgroundColor: Colors.white24,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () => _showComingSoon(context, "Settings"),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: user == null
            ? const Center(child: Text("No User Logged In", style: TextStyle(color: Colors.white)))
            : SingleChildScrollView(
                padding: const EdgeInsets.only(top: 100, bottom: 40),
                // ✅ ใช้ StreamBuilder แทน FutureBuilder เพื่อให้แก้ปุ๊บเปลี่ยนปั๊บ
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));

                    var userData = snapshot.data!.data() as Map<String, dynamic>;
                    String username = userData['username'] ?? 'Researcher';
                    String email = userData['email'] ?? '-';
                    String joinedDate = "Member since 2024"; 

                    return Column(
                      children: [
                        // 1. Profile Header
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow Effect
                            Container(
                              width: 130, height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 5),
                                ],
                              ),
                            ),
                            // Profile Image
                            GestureDetector(
                              onTap: () => _showComingSoon(context, "Change Avatar"),
                              child: const CircleAvatar(
                                radius: 60,
                                backgroundColor: Color(0xFF203A43),
                                child: Icon(Icons.person, size: 70, color: Colors.cyanAccent),
                              ),
                            ),
                            // Edit Icon (กดได้จริงแล้ว!)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _showEditProfileDialog(context, username), // ✅ เชื่อมฟังก์ชัน
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.cyanAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, size: 20, color: Colors.black),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // ชื่อและอีเมล
                        Text(username, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(email, style: const TextStyle(fontSize: 14, color: Colors.white54)),
                        const SizedBox(height: 5),
                        Text(joinedDate, style: const TextStyle(fontSize: 12, color: Colors.cyanAccent)),

                        const SizedBox(height: 30),

                        // 2. Stats Dashboard (ดึงข้อมูลจริง)
                        StreamBuilder<QuerySnapshot>(
                          stream: _db.getProjects(), 
                          builder: (context, projectSnap) {
                            int projectCount = projectSnap.hasData ? projectSnap.data!.docs.length : 0;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatCard("Projects", "$projectCount", Icons.folder_open),
                                _buildStatCard("Analyses", "0", Icons.analytics), 
                                _buildStatCard("Status", "Active", Icons.verified_user),
                              ],
                            );
                          }
                        ),

                        const SizedBox(height: 30),

                        // 3. Menu Options (กดได้จริง)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            children: [
                              _buildMenuItem(Icons.person_outline, "Edit Profile", 
                                () => _showEditProfileDialog(context, username)), // ✅ แก้ชื่อได้
                              _buildDivider(),
                              _buildMenuItem(Icons.lock_outline, "Privacy & Security", 
                                () => _showComingSoon(context, "Privacy")),
                              _buildDivider(),
                              _buildMenuItem(Icons.notifications_outlined, "Notifications", 
                                () => _showComingSoon(context, "Notifications")),
                              _buildDivider(),
                              _buildMenuItem(Icons.help_outline, "Help & Support", 
                                () => _showComingSoon(context, "Help Center")),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 4. Logout Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              _auth.logout();
                              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(0.1),
                              foregroundColor: Colors.redAccent,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                              elevation: 0,
                            ),
                            child: const Text("Log Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Colors.white10, indent: 70, endIndent: 20);
  }
}