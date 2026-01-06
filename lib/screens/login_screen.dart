import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // สำหรับ Validation
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _login() {
    // จุดตรวจสอบข้อมูล (Validation) จุดที่ 1
    if (_formKey.currentState!.validate()) {
      // จำลองการตรวจสอบกับฐานข้อมูล Users
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.biotech, size: 100, color: Colors.indigo),
                const SizedBox(height: 20),
                const Text("ระบบ AI วิเคราะห์เซลล์มะเร็ง", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _userController,
                  decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้งาน', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.isEmpty) ? 'กรุณากรอกชื่อผู้ใช้' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'รหัสผ่าน', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.length < 6) ? 'รหัสผ่านต้องมี 6 ตัวขึ้นไป' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text("เข้าสู่ระบบ"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}