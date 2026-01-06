import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ผลการวิเคราะห์ AI")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ภาพผลลัพธ์การวิเคราะห์ (Segmentation)", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // จำลองภาพที่ AI ขีดเส้นวัดขนาดแล้ว 
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Icon(Icons.image, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Text("ข้อมูลเชิงปริมาณ (Quantitative Results)", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            // แสดงจำนวนกลุ่มเซลล์ [cite: 52]
            ListTile(
              leading: const Icon(Icons.countertops, color: Colors.indigo),
              title: const Text("จำนวนกลุ่มเซลล์ที่นับได้ (Colony Count)"),
              trailing: const Text("42 กลุ่ม", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            // แสดงระยะความยาวสูงสุด [cite: 51]
            ListTile(
              leading: const Icon(Icons.straighten, color: Colors.orange),
              title: const Text("ระยะความยาวสูงสุด (Maximum Length)"),
              trailing: const Text("150.5 µm", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("เริ่มวิเคราะห์ใหม่"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // การตรวจสอบข้อมูล (Validation) จุดที่ 3: บันทึกข้อมูลสำเร็จหรือไม่
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("บันทึกผลลงตาราง Analysis_Results สำเร็จ!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                    child: const Text("บันทึกผล (UC 3)"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}