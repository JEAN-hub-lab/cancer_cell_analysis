import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'processing_screen.dart'; // import เพื่อส่งค่า

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  final _picker = ImagePicker();
  
  // ตัวแปรสำหรับเก็บค่า Input
  final _cellLineController = TextEditingController();
  final _drugNameController = TextEditingController();
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
      // ส่งข้อมูลทั้งหมดไปหน้า Processing
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessingScreen(
            imageFile: _image!,
            cellLine: _cellLineController.text,
            drugName: _drugNameController.text,
            concentration: _concentrationController.text,
          ),
        ),
      );
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload an image first")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Experiment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Experimental Parameters", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              const SizedBox(height: 15),
              
              // Input 1: Cell Line
              _buildInput("Cell Line (e.g., A549, H23)", _cellLineController, Icons.biotech),
              const SizedBox(height: 15),
              // Input 2: Drug Name
              _buildInput("Drug Name (e.g., Isalpinin)", _drugNameController, Icons.medication_liquid),
              const SizedBox(height: 15),
              // Input 3: Concentration
              _buildInput("Concentration (µM)", _concentrationController, Icons.science, isNumber: true),

              const SizedBox(height: 30),
              const Text("Image Sample", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              // Image Preview Area
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                    image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null,
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.indigo.withOpacity(0.3)),
                            const Text("Tap to upload image", style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("ANALYZE DATA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => value!.isEmpty ? 'Required field' : null,
    );
  }
}