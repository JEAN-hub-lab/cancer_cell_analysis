import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart'; // ✅ เพิ่มเพื่อดึงค่า Setting
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
  final int modelInputSize = 1024;

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    _processAI();
  }

  Future<void> _processAI() async {
    try {
      // 📥 ดึงค่า AI Confidence ที่ตั้งไว้ในหน้า Settings
      final prefs = await SharedPreferences.getInstance();
      final double userConfidence = prefs.getDouble('ai_confidence') ?? 0.4;

      File fileToProcess = widget.imageFile;
      final appDocDir = await getApplicationDocumentsDirectory();
      String fileName = "cell_${DateTime.now().millisecondsSinceEpoch}.jpg";
      String permanentPath = path.join(appDocDir.path, fileName);

      String extension = path.extension(widget.imageFile.path).toLowerCase();

      if (extension == '.tiff' || extension == '.tif') {
        final bytes = await widget.imageFile.readAsBytes();
        final img.Image? decodedImage = img.decodeImage(bytes);
        if (decodedImage != null) {
          fileToProcess = await File(permanentPath).writeAsBytes(img.encodeJpg(decodedImage));
        } else {
          throw Exception("File format not supported");
        }
      } else {
        fileToProcess = await widget.imageFile.copy(permanentPath);
      }

      await vision.loadYoloModel(
        labels: 'assets/labels/labels.txt',
        modelPath: 'assets/models/yolo_v8_final_best_float32.tflite',
        modelVersion: "yolov8",
        numThreads: 2,
        useGpu: true,
      );

      final imageBytes = await fileToProcess.readAsBytes();
      final rawResults = await vision.yoloOnImage(
        bytesList: imageBytes,
        imageHeight: modelInputSize,
        imageWidth: modelInputSize,
        iouThreshold: 0.5,
        confThreshold: userConfidence,   // ✅ ใช้ค่าจริงจาก Settings
        classThreshold: userConfidence,  // ✅ ใช้ค่าจริงจาก Settings
      );

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
          if (area <= 1) continue;

          cleanResults.add(result);
          colonyCount++;
          totalSize += area;
        }
        if (colonyCount > 0) avgSize = totalSize / colonyCount;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
        Navigator.pop(context);
      }
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
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.cyanAccent),
              SizedBox(height: 30),
              Text("AI Analyzing...", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 10),
              Text("Saving image to permanent storage", style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }
}