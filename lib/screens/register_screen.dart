import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // เปลี่ยนตัวแปรให้ตรงกับโจทย์ใหม่
  final _usernameController = TextEditingController(); // ใช้ Username แทน StudentID
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  
  // Name อาจจะไม่จำเป็นถ้าใช้ Username แต่ถ้าอยากเก็บไว้ก็ได้ (ผมตัดออกเพื่อให้กระชับตามที่ขอ)
  // final _nameController = TextEditingController(); 

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.register(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
          username: _usernameController.text.trim(), // ส่ง Username ไปแทน
        );
        
        // สมัครเสร็จ ไปหน้า Dashboard ทันที
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
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
                const Icon(Icons.person_add_alt_1, size: 70, color: Colors.cyanAccent),
                const SizedBox(height: 15),
                const Text("Create Account", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),
                
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
                            // 1. ช่อง Username
                            _buildTextField(_usernameController, 'Username', Icons.account_circle),
                            const SizedBox(height: 15),
                            
                            // 2. ช่อง Email
                            _buildTextField(_emailController, 'Email', Icons.email),
                            const SizedBox(height: 15),
                            
                            // 3. ช่อง Password
                            _buildTextField(_passController, 'Password', Icons.lock, isObscure: true),
                            const SizedBox(height: 30),
                            
                            _isLoading 
                              ? const CircularProgressIndicator(color: Colors.cyanAccent)
                              : ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black87, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  child: const Text("REGISTER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already have an account? Login", style: TextStyle(color: Colors.cyanAccent)),
                )
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
      validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
    );
  }
}