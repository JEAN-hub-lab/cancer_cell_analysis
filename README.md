# Cancer Cell Analysis App
**แอปพลิเคชันวิเคราะห์และนับจำนวนเซลล์มะเร็งด้วยเทคโนโลยี AI**

[cite_start]โครงงานนี้พัฒนาแอปพลิเคชันบนมือถือเพื่อช่วยนักวิจัยในการนับจำนวน (Colony Count) และวัดขนาดเซลล์มะเร็งโดยอัตโนมัติ เพื่อลดความผิดพลาดจากสายตามนุษย์ (Human Error) และเพิ่มความรวดเร็วในการวิเคราะห์ผลการทดลอง [cite: 9]

## สมาชิกในทีม
1. [cite_start]**นายปรินทร คงผล** (Main Developer) - พัฒนาระบบหลัก, AI Integration และ Logic ทั้งหมด [cite: 143]
2. [cite_start]**นายขจร หมื่นบาล** (Co-Developer) - พัฒนาระบบฐานข้อมูล, จัดทำรายงาน และสื่อนำเสนอ [cite: 143]

## Tech Stack
* [cite_start]**Frontend:** [Flutter](https://flutter.dev/) (Cross-platform support) [cite: 27]
* [cite_start]**AI Model:** YOLOv8 (Converted to TFLite for On-device processing) [cite: 17, 29]
* [cite_start]**Database (Hybrid):** * **Local:** [SQLite](https://pub.dev/packages/sqflite) (Offline-first capability) [cite: 21, 28]
  * [cite_start]**Cloud:** [Firebase Firestore](https://firebase.google.com/docs/firestore) (Data Backup & Sync) [cite: 22, 28]
* [cite_start]**Authentication:** Firebase Auth [cite: 13, 102]

## Key Features
* [cite_start]**On-Device AI Inference:** ประมวลผลภาพในเครื่องทันที ไม่ต้องใช้อินเทอร์เน็ตเพื่อรักษาความเป็นส่วนตัว [cite: 10, 17]
* [cite_start]**AI Precision Tuning:** ผู้ใช้สามารถปรับค่าความไว (Confidence Slider) ได้แบบ Real-time [cite: 19]
* [cite_start]**Manual Correction:** รองรับการแก้ไขจำนวนเซลล์ด้วยมือกรณี AI ประมวลผลผิดพลาด [cite: 18, 49]
* [cite_start]**Data Visualization:** แสดงกราฟเส้น (Line Chart) แสดงแนวโน้มการตอบสนองของยาต่อจำนวนเซลล์ [cite: 25]
* [cite_start]**Data Export:** ส่งออกข้อมูลการทดลองเป็นไฟล์ CSV เพื่อใช้งานใน Excel ต่อไป [cite: 23]

## Project Structure
- [cite_start]`lib/screens/`: ส่วนติดต่อผู้ใช้ (UI) ทั้ง 5 หน้าหลัก [cite: 56]
- [cite_start]`lib/services/`: ส่วนจัดการ Logic, Authentication และ Database [cite: 103]
- [cite_start]`assets/models/`: ที่เก็บไฟล์โมเดล YOLOv8 (.tflite) [cite: 87, 88]
