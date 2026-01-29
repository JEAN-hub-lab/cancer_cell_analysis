import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path; // 👈 1. ต้อง import ตัวนี้เพิ่มเพื่อเช็คสกุลไฟล์
import 'processing_screen.dart';

class UploadScreen extends StatefulWidget {
  final String projectId;
  final String cellLine;
  final String drugName;

  const UploadScreen({
    super.key,
    required this.projectId,
    required this.cellLine,
    required this.drugName,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  final _picker = ImagePicker();
  final _concentrationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _image != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessingScreen(
            projectId: widget.projectId,
            imageFile: _image!, // ส่งไฟล์ .tiff ดิบๆ ไปเลย (หน้า Processing จะแปลงให้เอง)
            cellLine: widget.cellLine,
            drugName: widget.drugName,
            concentration: _concentrationController.text,
          ),
        ),
      );
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload an image first"))
      );
    }
  }

  // ฟังก์ชันเช็คว่าเป็นไฟล์ TIFF หรือไม่
  bool get _isTiff {
    if (_image == null) return false;
    String ext = path.extension(_image!.path).toLowerCase();
    return ext == '.tiff' || ext == '.tif';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text("Add Data Point", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: Stack(
        children: [
          // Layer 1: พื้นหลัง
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
          ),
          
          // Layer 2: เนื้อหา
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _infoRow(Icons.biotech, "Cell Line", widget.cellLine),
                        const Divider(color: Colors.white24),
                        _infoRow(Icons.medication, "Drug Name", widget.drugName),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  TextFormField(
                    controller: _concentrationController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Concentration (µM)",
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.science, color: Colors.cyanAccent),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required field' : null,
                  ),
                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), style: BorderStyle.solid),
                        // 👈 2. แก้ตรงนี้: ถ้าเป็น TIFF จะไม่โชว์รูป (เพราะ Flutter เรนเดอร์ไม่ได้)
                        image: (_image != null && !_isTiff) 
                            ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) 
                            : null,
                      ),
                      child: _buildImagePlaceholder(), // 👈 3. ใช้ฟังก์ชันสร้าง Child แทน
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("ANALYZE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับแสดงผลในกล่องรูปภาพ
  Widget _buildImagePlaceholder() {
    if (_image == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 50, color: Colors.white30),
          SizedBox(height: 10),
          Text("Tap to upload image", style: TextStyle(color: Colors.white30)),
        ],
      );
    } else if (_isTiff) {
      // 👈 4. ถ้าเป็น TIFF ให้โชว์ไอคอนไฟล์แทนรูป
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, size: 50, color: Colors.yellowAccent),
          const SizedBox(height: 10),
          const Text("TIFF File Selected", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(path.basename(_image!.path), style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 5),
          const Text("(Preview not available)", style: TextStyle(color: Colors.white30, fontSize: 10)),
        ],
      );
    }
    return const SizedBox(); // กรณีเป็น JPG/PNG มันจะโชว์ที่ DecorationImage แล้ว
  }

  Widget _infoRow(IconData icon, String l, String v) => Row(
    children: [
      Icon(icon, color: Colors.cyanAccent, size: 20),
      const SizedBox(width: 10),
      Text("$l: ", style: const TextStyle(color: Colors.white70)),
      Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
    ]
  );
}