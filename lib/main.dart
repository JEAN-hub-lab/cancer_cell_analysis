import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/profile_screen.dart';
// import 'screens/processing_screen.dart'; // ไม่ต้อง import ก็ได้ถ้าไม่ได้ใช้ใน routes (แต่ทิ้งไว้ก็ไม่เป็นไร)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CancerCellApp());
}

class CancerCellApp extends StatelessWidget {
  const CancerCellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cancer Cell AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.promptTextTheme(Theme.of(context).textTheme),
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const LoginScreen(),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/upload': (context) => const UploadScreen(),
        '/profile': (context) => const ProfileScreen(),
        // ลบ '/processing' ออกแล้ว เพราะเราเรียกใช้แบบส่งค่า (Parameter) ใน UploadScreen แทน
      },
    );
  }
}