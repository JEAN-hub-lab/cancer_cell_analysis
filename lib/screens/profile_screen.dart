import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/local_database_service.dart';
import 'settings_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  File? _localImageFile;

  @override
  void initState() {
    super.initState();
    _loadLocalImage();
  }

  Future<void> _loadLocalImage() async {
    final user = _auth.currentUser;
    if (user != null) {
      String? savedPath = await LocalDatabaseService.instance.getProfileImage(user.uid);
      if (savedPath != null) {
        File imgFile = File(savedPath);
        if (await imgFile.exists()) {
          setState(() {
            _localImageFile = imgFile;
          });
        }
      }
    }
  }

  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${user.uid}.jpg';
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      await LocalDatabaseService.instance.saveProfileImage(user.uid, savedImage.path);

      setState(() {
        _localImageFile = savedImage;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated locally!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save image"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showEditUsernameDialog(BuildContext context, String currentName) {
    final nameCtrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("Edit Username", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Username",
            labelStyle: TextStyle(color: Colors.cyanAccent),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await _db.updateUserProfile(username: nameCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username updated!"), backgroundColor: Colors.green));
              }
            },
            child: const Text("Save"),
          ),
        ],
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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
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
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));

                    var userData = snapshot.data!.data() as Map<String, dynamic>;
                    String username = userData['username'] ?? 'Researcher';
                    String email = userData['email'] ?? '-';

                    return Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)])),
                            GestureDetector(
                              onTap: _pickAndSaveImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: const Color(0xFF203A43),
                                backgroundImage: _localImageFile != null ? FileImage(_localImageFile!) : null,
                                child: _localImageFile == null ? const Icon(Icons.person, size: 70, color: Colors.cyanAccent) : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(username, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(email, style: const TextStyle(fontSize: 14, color: Colors.white54)),
                        const SizedBox(height: 30),
                        
                        // Stats Section
                        StreamBuilder<QuerySnapshot>(
                          stream: _db.getProjects(), 
                          builder: (context, projectSnap) {
                            int projectCount = projectSnap.hasData ? projectSnap.data!.docs.length : 0;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                              children: [
                                _buildStatCard("Projects", "$projectCount", Icons.folder_open),
                                _buildStatCard("Status", "Active", Icons.verified_user)
                              ]
                            );
                          }
                        ),
                        const SizedBox(height: 30),

                        // Menu Options
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
                          child: Column(children: [
                            _buildMenuItem(Icons.person_outline, "Edit Username", () => _showEditUsernameDialog(context, username)), 
                            const Divider(height: 1, color: Colors.white10, indent: 70),
                            _buildMenuItem(Icons.image_outlined, "Change Picture", _pickAndSaveImage), 
                            const Divider(height: 1, color: Colors.white10, indent: 70),
                            _buildMenuItem(Icons.settings_outlined, "App Settings", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()))),
                          ]),
                        ),
                        const SizedBox(height: 30),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: () { 
                              _auth.logout(); 
                              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); 
                            }, 
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1), foregroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), side: const BorderSide(color: Colors.redAccent)), 
                            child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold))
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
    return Container(width: 120, padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)), child: Column(children: [Icon(icon, color: Colors.cyanAccent, size: 24), const SizedBox(height: 8), Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12))]));
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: Colors.cyanAccent), title: Text(title, style: const TextStyle(color: Colors.white)), trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14), onTap: onTap);
  }
}