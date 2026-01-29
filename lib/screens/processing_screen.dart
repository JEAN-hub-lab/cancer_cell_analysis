import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String projectId;
  final File imageFile; 
  final String cellLine;
  final String drugName;
  final String concentration;

  const ProcessingScreen({
    super.key,
    required this.projectId,
    required this.imageFile,
    required this.cellLine,
    required this.drugName,
    required this.concentration,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  late FlutterVision vision;
  
  // ✅ คงไว้ที่ 1024 (ถูกแล้ว)
  final int modelInputSize = 1024; 

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    _processAI();
  }

  Future<void> _processAI() async {
    try {
      File fileToProcess = widget.imageFile;
      String extension = path.extension(widget.imageFile.path).toLowerCase();

      // 1. แปลงไฟล์
      if (extension == '.tiff' || extension == '.tif') {
        final bytes = await widget.imageFile.readAsBytes();
        final img.Image? decodedImage = img.decodeImage(bytes);
        if (decodedImage != null) {
          final tempDir = await getTemporaryDirectory();
          final tempPath = path.join(tempDir.path, 'converted_image.jpg');
          fileToProcess = await File(tempPath).writeAsBytes(img.encodeJpg(decodedImage));
        } else {
          throw Exception("File format not supported");
        }
      }

      // 2. โหลดโมเดล
      await vision.loadYoloModel(
        labels: 'assets/labels/labels.txt',
        modelPath: 'assets/models/yolo_v8_final_best_float32.tflite', 
        modelVersion: "yolov8",
        numThreads: 2,
        useGpu: true,
      );

      // 3. รันโมเดล (เปิดประตูเขื่อน!)
      final imageBytes = await fileToProcess.readAsBytes();
      final rawResults = await vision.yoloOnImage(
        bytesList: imageBytes,
        imageHeight: modelInputSize,
        imageWidth: modelInputSize,
        
        // 🔧 ปรับลงต่ำสุดๆ!
        iouThreshold: 0.5,   // ค่ากลางๆ (เดิม 0.7 อาจจะรวมเซลล์ติดกันมากไป)
        confThreshold: 0.05, // 👇 เอาต่ำติดดินเลย (5%) เพื่อดูว่ามันเห็นอะไรบ้าง
        classThreshold: 0.05, 
      );

      // 4. กรองผลลัพธ์ (แทบไม่กรองเลย)
      int colonyCount = 0;
      double totalSize = 0.0;
      double avgSize = 0.0;

      List<Map<String, dynamic>> cleanResults = [];

      if (rawResults.isNotEmpty) {
        for (var result in rawResults) {
          final box = result['box'];
          final width = box[2] - box[0];
          final height = box[3] - box[1];
          final area = width * height;
          
          // ❌ เอา Filter area < 30 ออก! (เผื่อเซลล์มันเล็กจัด)
          // ใส่ไว้แค่กัน Error (area = 0) พอ
          if (area <= 1) continue; 

          // ❌ เอา Filter Ratio ออก! (เผื่อเซลล์มันเบี้ยว)
          // ให้มันโชว์ดิบๆ มาเลย

          cleanResults.add(result);
          colonyCount++;
          totalSize += area;
        }

        if (colonyCount > 0) {
          avgSize = totalSize / colonyCount;
        }
      }

      await vision.closeYoloModel();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              projectId: widget.projectId,
              imageFile: fileToProcess,
              cellLine: widget.cellLine,
              drugName: widget.drugName,
              concentration: widget.concentration,
              initialColonyCount: colonyCount,
              initialAvgSize: avgSize,
              yoloResults: cleanResults,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.cyanAccent),
              SizedBox(height: 30),
              Text("AI Analyzing...", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Mode: Low Confidence (Floodgates Open)", style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }
}