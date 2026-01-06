import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/result_screen.dart';
import 'screens/profile_screen.dart';

void main() => runApp(const CancerCellApp());

class CancerCellApp extends StatelessWidget {
  const CancerCellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cancer Cell Analysis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const LoginScreen(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/upload': (context) => const UploadScreen(),
        '/result': (context) => const ResultScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}