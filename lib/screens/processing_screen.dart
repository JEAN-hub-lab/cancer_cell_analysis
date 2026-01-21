import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:percent_indicator/percent_indicator.dart';
import 'result_screen.dart'; 

class ProcessingScreen extends StatefulWidget {
  final File imageFile;
  // เพิ่มตัวแปรรับค่า
  final String cellLine;
  final String drugName;
  final String concentration;

  const ProcessingScreen({
    super.key, 
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
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) { // ทำให้เร็วขึ้นหน่อย
      setState(() {
        if (percent < 1.0) {
          percent += 0.2;
        } else {
          _timer?.cancel();
          // ส่งข้อมูลทั้งหมดไปหน้า Result
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                imageFile: widget.imageFile,
                cellLine: widget.cellLine,
                drugName: widget.drugName,
                concentration: widget.concentration,
              ),
            ),
          );
        }
      });
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
      backgroundColor: const Color(0xFF0F2027),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 80.0, lineWidth: 10.0, percent: percent > 1.0 ? 1.0 : percent,
              center: const Icon(Icons.analytics, size: 50, color: Colors.cyanAccent),
              progressColor: Colors.cyanAccent, backgroundColor: Colors.white12,
              circularStrokeCap: CircularStrokeCap.round, animation: true, animateFromLastPercent: true,
            ),
            const SizedBox(height: 30),
            Text("Analyzing ${widget.cellLine}...", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Drug: ${widget.drugName} (${widget.concentration} µM)", style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}