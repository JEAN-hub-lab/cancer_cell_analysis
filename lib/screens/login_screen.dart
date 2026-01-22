import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // เปลี่ยนชื่อตัวแปรให้สื่อความหมาย (รับได้ทั้ง Username และ Email)
  final _usernameController = TextEditingController(); 
  final _passController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // เรียกใช้ฟังก์ชัน login ตัวใหม่ที่รองรับ Username
        await _authService.login(
          _usernameController.text.trim(),
          _passController.text.trim(),
        );
        // ไม่ต้องสั่ง Navigator แล้ว เพราะ StreamBuilder ใน main.dart จะจัดการพาไป Dashboard เอง
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed: $e"), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.bubble_chart, size: 100, color: Colors.cyanAccent.withOpacity(0.5)),
                    const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("BioAI Analytics", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                const Text("Automated Cell Colony Counting", style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 40),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.2))),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // แก้ Label ตรงนี้
                            _buildTextField(_usernameController, 'Username or Email', Icons.person), 
                            const SizedBox(height: 20),
                            _buildTextField(_passController, 'Password', Icons.lock, isObscure: true),
                            const SizedBox(height: 30),
                            _isLoading
                                ? const CircularProgressIndicator(color: Colors.cyanAccent)
                                : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black87, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                    child: const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("Don't have an account? Register", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isObscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        filled: true, fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => (value == null || value.length < 3) ? 'Invalid input' : null,
    );
  }
}