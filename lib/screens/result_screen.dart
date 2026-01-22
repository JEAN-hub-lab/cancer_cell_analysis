import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'dart:io';
import 'dart:math';
import '../services/database_service.dart';

class ResultScreen extends StatefulWidget {
  final String projectId;
  final File imageFile;
  final String cellLine;
  final String drugName;
  final String concentration;

  const ResultScreen({
    super.key, 
    required this.projectId,
    required this.imageFile,
    required this.cellLine,
    required this.drugName,
    required this.concentration,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // เปลี่ยนเป็น State เพื่อให้แก้ไขค่าได้ (Human-in-the-loop)
  late int colonyCount;
  late double avgSize;

  @override
  void initState() {
    super.initState();
    // จำลองผลลัพธ์จาก AI (สุ่มค่าครั้งเดียวตอนเปิดหน้า)
    colonyCount = 40 + Random().nextInt(60); 
    avgSize = 100.0 + Random().nextInt(200);
  }

  // ฟังก์ชันแก้ไขค่าผลลัพธ์ (เผื่อ AI นับผิด)
  void _editResult() {
    TextEditingController countCtrl = TextEditingController(text: colonyCount.toString());
    TextEditingController sizeCtrl = TextEditingController(text: avgSize.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("Edit Results", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: countCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Colony Count", labelStyle: TextStyle(color: Colors.cyanAccent), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30))),
            ),
            TextField(
              controller: sizeCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Avg Size", labelStyle: TextStyle(color: Colors.cyanAccent), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            onPressed: () {
              setState(() {
                colonyCount = int.tryParse(countCtrl.text) ?? colonyCount;
                avgSize = double.tryParse(sizeCtrl.text) ?? avgSize;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("${widget.cellLine} Analysis", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.cyanAccent),
            tooltip: "Edit Result",
            onPressed: _editResult,
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoItem("Drug", widget.drugName, Icons.medication),
                    _infoItem("Conc.", "${widget.concentration} µM", Icons.science),
                    _infoItem("Count", "$colonyCount", Icons.bug_report), // ใช้ตัวแปร state
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // 2. Image Result
              const Text("Segmentation Result", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(image: FileImage(widget.imageFile), fit: BoxFit.cover),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  border: Border.all(color: Colors.white10),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.green.withOpacity(0.2), // จำลอง Mask สีเขียว
                  ),
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(10),
                  child: const Chip(
                    label: Text("AI Processed", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.cyanAccent,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 3. Bar Chart Comparison
              const Text("Comparison vs Control", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              Container(
                height: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black26, 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 120,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (v, m) => Text("${v.toInt()}", style: const TextStyle(color: Colors.white54, fontSize: 10)))),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                        if (value == 0) return const Padding(padding: EdgeInsets.only(top: 8), child: Text("Control\n(0 µM)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 10)));
                        if (value == 1) return Padding(padding: const EdgeInsets.only(top: 8), child: Text("${widget.drugName}\n${widget.concentration} µM", textAlign: TextAlign.center, style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)));
                        return const Text("");
                      })),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.white10)),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      // Control (100%)
                      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 100, color: Colors.white24, width: 30, borderRadius: BorderRadius.circular(4))]),
                      // Experiment Result
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: (colonyCount/100)*100, color: Colors.cyanAccent, width: 30, borderRadius: BorderRadius.circular(4))]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 4. Save Button
              ElevatedButton.icon(
                onPressed: () async {
                  await DatabaseService().saveExperimentData(
                    projectId: widget.projectId,
                    drugName: widget.drugName,
                    concentration: double.tryParse(widget.concentration) ?? 0.0,
                    colonyCount: colonyCount, // ใช้ค่าล่าสุดที่อาจจะแก้แล้ว
                    avgSize: avgSize,         // ใช้ค่าล่าสุดที่อาจจะแก้แล้ว
                  );

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Saved Successfully!"), backgroundColor: Colors.green));
                  Navigator.pop(context); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  shadowColor: Colors.cyanAccent.withOpacity(0.4),
                ),
                icon: const Icon(Icons.save_alt),
                label: const Text("SAVE TO PROJECT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.cyanAccent, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}