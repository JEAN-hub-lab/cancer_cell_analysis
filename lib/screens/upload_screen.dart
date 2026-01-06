import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // จุดตรวจสอบข้อมูล (Validation) จุดที่ 2: เช็กว่าเป็นไฟล์ภาพหรือไม่
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("อัปโหลดภาพเซลล์มะเร็ง")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null 
              ? const Text("กรุณาเลือกรูปภาพจากคลังภาพ") 
              : Image.file(_image!, height: 300),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage, 
              child: const Text("เลือกรูปภาพ (Upload Image)")
            ),
            const SizedBox(height: 20),
            if (_image != null)
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/result'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text("ส่งไปวิเคราะห์ด้วย AI"),
              ),
          ],
        ),
      ),
    );
  }
}