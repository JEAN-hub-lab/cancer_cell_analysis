# Cancer Cell Analysis Application

แอปพลิเคชันสำหรับวิเคราะห์ นับจำนวน และวัดขนาดเซลล์มะเร็งผ่านกล้องจุลทรรศน์ด้วยเทคโนโลยีปัญญาประดิษฐ์ (AI) โครงงานนี้พัฒนาระบบสถาปัตยกรรมฐานข้อมูลแบบผสมผสาน (Hybrid Database) เพื่อรองรับการทำงานในสภาวะที่ไม่มีสัญญาณอินเทอร์เน็ต (Offline-First) และสามารถซิงโครไนซ์ข้อมูลขึ้นระบบคลาวด์ได้โดยอัตโนมัติ

## 1. ข้อมูลทางเทคนิค (Tech Stack)
- Frontend: Flutter Framework (Dart)
- Backend / Cloud Database: Firebase (Authentication, Firestore)
- Local Database (Offline Storage): SQLite (ผ่านไลบรารี sqflite)
- Artificial Intelligence: YOLOv8 Deployment (TensorFlow Lite) ผ่านไลบรารี flutter_vision
- Data Visualization & Analytics: fl_chart
- File System: path_provider สำหรับการจัดการ Permanent Storage

---

## 2. โครงสร้างฐานข้อมูลระดับซอร์สโค้ด (Data Model & Source Code Structure)

ระบบใช้สถาปัตยกรรม Hybrid Database ควบคู่กับ Queue-based Synchronization เพื่อความสมบูรณ์ของข้อมูล

### 2.1 Cloud Database (Firebase Firestore)
จัดเก็บในรูปแบบ NoSQL Document-based (Nested Collection)
- Collection: users (Document ID: uid)
  - Fields: username (String), photoUrl (String)
  - Sub-collection: projects (Document ID: projectId)
    - Fields: name, drugName, cellLine (String), createdAt (Timestamp)
    - Sub-collection: experiments (Document ID: experimentId)
      - Fields: concentration (Number), colonyCount (Number), avgSize (Number), timestamp (Timestamp)

### 2.2 Local Database (SQLite Schema)
การกำหนดสคีมาตารางในไฟล์ lib/services/local_database_service.dart:
- Table projects: id (PK), name, drug_name, cell_line, is_synced
- Table experiments: id (PK), project_id, concentration, colony_count, avg_size, image_path, timestamp
- Table user_images: uid (PK), image_path

---

## 3. คู่มือการติดตั้งระบบ (Installation Guide)

### 3.1 สิ่งที่ต้องเตรียม (Prerequisites)
- Flutter SDK (เวอร์ชัน 3.0.0 ขึ้นไป)
- Android Studio พร้อม Android SDK
- อุปกรณ์สมาร์ตโฟนระบบปฏิบัติการ Android (สำหรับการประมวลผลโมเดล AI และการใช้กล้อง)
- บัญชี Firebase Console สำหรับฐานข้อมูลออนไลน์

### 3.2 ขั้นตอนการติดตั้ง (Setup Steps)
1. ทำการโคลนซอร์สโค้ดจากแพลตฟอร์ม GitHub:
   ```bash
   git clone [https://github.com/](https://github.com/)[ชื่อผู้ใช้]/cancer_cell_analysis.git
