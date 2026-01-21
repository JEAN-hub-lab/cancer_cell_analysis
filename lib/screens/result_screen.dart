import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // ใช้พระเอกคนเดิม
import 'dart:io';
import '../mock_data.dart';
import 'package:intl/intl.dart';

class ResultScreen extends StatelessWidget {
  final File imageFile;
  final String cellLine;
  final String drugName;
  final String concentration;
  
  // ค่า Mockup ผลลัพธ์ (สมมติว่า AI คำนวณออกมาได้เท่านี้)
  final int colonyCount = 42; 
  final double avgSize = 150.5;

  const ResultScreen({
    super.key, 
    required this.imageFile,
    required this.cellLine,
    required this.drugName,
    required this.concentration,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // กลับมาใช้สีสว่างเพื่อให้กราฟดูชัดเหมือนเปเปอร์
      appBar: AppBar(
        title: Text("$cellLine Analysis", style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ส่วนสรุปข้อมูลการทดลอง (Experiment Info)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoItem("Drug", drugName, Icons.medication),
                    _infoItem("Conc.", "$concentration µM", Icons.science),
                    _infoItem("Result", "$colonyCount Colonies", Icons.bug_report),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. รูปภาพผลลัพธ์ (Original vs Segmented)
            const Text("Segmentation Result", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.green.withOpacity(0.2), // Overlay สีเขียวจำลอง
                ),
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(10),
                child: const Chip(label: Text("AI Processed"), backgroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 30),

            // 3. กราฟ Bar Chart แบบ Scientific (Control vs Experiment)
            const Text("Quantitative Analysis (Colony Number)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("Comparison with Control Group (0 µM)", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            
            Container(
              height: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100, // ปรับตามความเหมาะสม (Mockup 100%)
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text("${value.toInt()}%", style: const TextStyle(fontSize: 10)))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                      if (value == 0) return const Padding(padding: EdgeInsets.only(top: 8), child: Text("Control\n(0 µM)", textAlign: TextAlign.center));
                      if (value == 1) return Padding(padding: const EdgeInsets.only(top: 8), child: Text("$drugName\n($concentration µM)", textAlign: TextAlign.center));
                      return const Text("");
                    })),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: true, border: const Border(bottom: BorderSide(color: Colors.black12), left: BorderSide(color: Colors.black12))),
                  barGroups: [
                    // Bar 1: Control (สมมติว่าเป็น 100%) - สีแดงเหมือนในรูป Reference
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 100, color: Colors.redAccent, width: 40, borderRadius: BorderRadius.circular(4))]),
                    
                    // Bar 2: Experiment Result (ค่าที่ได้จริง) - สีน้ำเงิน
                    // สมมติ: ถ้า 42 colonies เทียบกับ control (สมมติ 60) -> (42/60)*100 = 70%
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 70, color: Colors.indigo, width: 40, borderRadius: BorderRadius.circular(4))]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 4. ปุ่ม Save
            ElevatedButton.icon(
              onPressed: () {
                MockDatabase.results.add(AnalysisResult(
                  date: DateFormat('dd MMM, HH:mm').format(DateTime.now()),
                  colonyCount: colonyCount,
                  maxLength: avgSize,
                ));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Saved to Research Log!")));
                Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              icon: const Icon(Icons.save),
              label: const Text("SAVE TO DATABASE"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo, size: 28),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}