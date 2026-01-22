import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:percent_indicator/percent_indicator.dart';
import 'result_screen.dart'; 

class ProcessingScreen extends StatefulWidget {
  final String projectId; // รับ ID มา
  final File imageFile;
  final String cellLine;
  final String drugName;
  final String concentration;

  const ProcessingScreen({
    super.key, 
    required this.projectId, // รับค่าโปรเจกต์
    required this.imageFile,
    required this.cellLine,
    required this.drugName,
    required this.concentration,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  double percent = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _simulateAIProcess();
  }

  void _simulateAIProcess() {
    // จำลองการวิเคราะห์ 3 วินาที (Mockup AI)
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          if (percent < 1.0) {
            percent += 0.1;
          } else {
            _timer?.cancel();
            // ส่งต่อไปหน้า Result พร้อมข้อมูลทั้งหมด
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(
                  projectId: widget.projectId,
                  imageFile: widget.imageFile,
                  cellLine: widget.cellLine,
                  drugName: widget.drugName,
                  concentration: widget.concentration,
                ),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // เอา backgroundColor ออก แล้วใช้ Container ไล่สีแทน
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            // ธีมสีเดียวกับหน้า Dashboard และ Result
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // วงกลมโหลด
              CircularPercentIndicator(
                radius: 80.0, 
                lineWidth: 10.0, 
                percent: percent > 1.0 ? 1.0 : percent,
                center: const Icon(Icons.auto_awesome, size: 50, color: Colors.cyanAccent), // เปลี่ยนไอคอนให้ดู AI ขึ้น
                progressColor: Colors.cyanAccent, 
                backgroundColor: Colors.white12,
                circularStrokeCap: CircularStrokeCap.round, 
                animation: true, 
                animateFromLastPercent: true,
              ),
              const SizedBox(height: 40),
              
              // ข้อความสถานะ
              const Text(
                "AI Analyzing...", 
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)
              ),
              const SizedBox(height: 10),
              Text(
                "${widget.cellLine} | ${widget.drugName}", 
                style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.w500)
              ),
              Text(
                "Concentration: ${widget.concentration} µM", 
                style: const TextStyle(color: Colors.white54, fontSize: 14)
              ),
            ],
          ),
        ),
      ),
    );
  }
}