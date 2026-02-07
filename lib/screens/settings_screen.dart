import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _aiConfidence = 0.4;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _aiConfidence = prefs.getDouble('ai_confidence') ?? 0.4;
      _isLoading = false;
    });
  }

  Future<void> _saveAiConfidence(double value) async {
    setState(() => _aiConfidence = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ai_confidence', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F2027),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text("AI CONFIGURATION", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 15),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Detection Confidence", style: TextStyle(color: Colors.white, fontSize: 16)),
                          Text("${(_aiConfidence * 100).toInt()}%", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Slider(
                        value: _aiConfidence,
                        min: 0.1, max: 0.9,
                        divisions: 8,
                        activeColor: Colors.cyanAccent,
                        onChanged: _saveAiConfidence,
                      ),
                      const Text("Note: Higher value improves precision but may miss small cells.", style: TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Text("APP INFORMATION", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 15),
                
                Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
                  child: Column(
                    children: [
                      _buildInfoTile(Icons.info_outline, "Version", "1.0.0 (Stable)"),
                      const Divider(height: 1, color: Colors.white10, indent: 60),
                      _buildInfoTile(Icons.code, "Developer", "JEAN-hub-lab"),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(value, style: const TextStyle(color: Colors.white54)),
    );
  }
}