import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:flutter_vision/flutter_vision.dart'; // พระเอก YOLOv8
import '../services/database_service.dart'; // Firebase
import '../services/local_database_service.dart'; // SQLite

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
  late FlutterVision vision;
  bool isLoaded = false;
  
  // ตัวแปรเก็บผลลัพธ์
  int colonyCount = 0;
  double avgSize = 0.0;
  List<Map<String, dynamic>> yoloResults = []; 

  // กำหนดขนาด Input ของโมเดล (ตามที่คุณ Export มา)
  final int modelInputSize = 896; 

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    _loadModelAndRunInference();
  }

  // 1. โหลดโมเดลและรันผล
  Future<void> _loadModelAndRunInference() async {
    // โหลดโมเดล
    await vision.loadYoloModel(
      labels: 'assets/labels/labels.txt', 
      modelPath: 'assets/models/yolov8_segmentation.tflite', // ชื่อไฟล์ต้องตรงเป๊ะ
      modelVersion: "yolov8",
      numThreads: 2,
      useGpu: true,
    );

    // อ่านไฟล์รูป
    final imageBytes = await widget.imageFile.readAsBytes();
    
    // สั่ง AI ทำงาน (Inference)
    // Library จะทำการย่อรูป 2560x1920 -> 896x896 ให้เองก่อนส่งเข้า AI
    final results = await vision.yoloOnImage(
      bytesList: imageBytes,
      imageHeight: modelInputSize, // 896
      imageWidth: modelInputSize,  // 896
      iouThreshold: 0.4, 
      confThreshold: 0.4, 
      classThreshold: 0.5,
    );

    // คำนวณผลลัพธ์
    if (results.isNotEmpty) {
      double totalSize = 0;
      for (var result in results) {
        // result['box'] = [x1, y1, x2, y2, class_id]
        final box = result['box'];
        final width = box[2] - box[0];
        final height = box[3] - box[1];
        final area = width * height;
        totalSize += area;
      }

      if (mounted) {
        setState(() {
          yoloResults = results;
          colonyCount = results.length;
          avgSize = totalSize / colonyCount;
          isLoaded = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          colonyCount = 0;
          avgSize = 0.0;
          isLoaded = true;
        });
      }
    }
  }

  @override
  void dispose() {
    vision.closeYoloModel();
    super.dispose();
  }

  // ฟังก์ชันแก้ไขค่า (Human-in-the-loop)
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
        child: !isLoaded 
            ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)) 
            : SingleChildScrollView(
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
                          _infoItem("Count", "$colonyCount", Icons.bug_report),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 2. Image Result & Overlay
                    const Text("AI Detection Result", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // กำหนดขนาดพื้นที่แสดงผลให้เป็นสี่เหลี่ยมจัตุรัส เพื่อให้ตรงกับ Input โมเดล (896x896)
                        // เพื่อให้ Box Overlay วาดได้ตรงตำแหน่งที่สุด
                        double displaySize = constraints.maxWidth;
                        
                        return Container(
                          height: displaySize, 
                          width: displaySize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white10),
                            color: Colors.black,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // แสดงรูปแบบ BoxFit.fill (ยืดให้เป็นสี่เหลี่ยมจัตุรัสเพื่อให้ตรงกับ AI)
                                Image.file(widget.imageFile, fit: BoxFit.fill),
                                
                                // วาดกรอบสี่เหลี่ยม (Bounding Boxes)
                                ...yoloResults.map((result) {
                                  // AI ส่งค่ากลับมาในช่วง 0 - 896
                                  // เราต้องแปลงให้เป็นสเกลของหน้าจอ (displaySize)
                                  final box = result['box'];
                                  final double scaleFactor = displaySize / modelInputSize;

                                  double x1 = box[0] * scaleFactor;
                                  double y1 = box[1] * scaleFactor;
                                  double x2 = box[2] * scaleFactor;
                                  double y2 = box[3] * scaleFactor;

                                  return Positioned(
                                    left: x1,
                                    top: y1,
                                    width: x2 - x1,
                                    height: y2 - y1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.greenAccent, width: 2),
                                        color: Colors.greenAccent.withOpacity(0.2),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                
                                Positioned(
                                  bottom: 10, right: 10,
                                  child: const Chip(
                                    label: Text("YOLOv8 Inference", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                    backgroundColor: Colors.cyanAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
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
                          maxY: colonyCount > 100 ? colonyCount * 1.2 : 120,
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
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 100, color: Colors.white24, width: 30, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: colonyCount.toDouble(), color: Colors.cyanAccent, width: 30, borderRadius: BorderRadius.circular(4))]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 4. Save Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        // 1. Firebase Save
                        await DatabaseService().saveExperimentData(
                          projectId: widget.projectId,
                          drugName: widget.drugName,
                          concentration: double.tryParse(widget.concentration) ?? 0.0,
                          colonyCount: colonyCount,
                          avgSize: avgSize,
                        );

                        // 2. SQLite Save (Local)
                        await LocalDatabaseService.instance.insertExperiment({
                          'project_id': widget.projectId,
                          'drug_name': widget.drugName,
                          'concentration': double.tryParse(widget.concentration) ?? 0.0,
                          'colony_count': colonyCount,
                          'avg_size': avgSize,
                          'image_path': widget.imageFile.path, 
                          'timestamp': DateTime.now().toIso8601String(),
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved to Cloud & Device!"), backgroundColor: Colors.green));
                          Navigator.pop(context);
                        }
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