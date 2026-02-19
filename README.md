# Cancer Cell Analysis Application

Cancer Cell Analysis Application เป็นแอปพลิเคชันสำหรับวิเคราะห์ นับจำนวน และวัดขนาดเซลล์มะเร็งจากภาพกล้องจุลทรรศน์โดยใช้เทคโนโลยีปัญญาประดิษฐ์ (Artificial Intelligence)

ระบบถูกออกแบบภายใต้แนวคิด Hybrid Database และ Offline-First Architecture เพื่อให้สามารถทำงานได้แม้ไม่มีการเชื่อมต่ออินเทอร์เน็ต และสามารถซิงโครไนซ์ข้อมูลขึ้นระบบ Cloud ได้โดยอัตโนมัติเมื่อกลับมาออนไลน์

---

## Features

- ตรวจจับและนับเซลล์มะเร็งด้วยโมเดล AI (YOLOv8)
- ถ่ายภาพผ่านกล้องสมาร์ตโฟน
- วิเคราะห์และแสดงผลข้อมูลเชิงสถิติ
- รองรับการทำงานแบบ Offline (Offline-First)
- ซิงโครไนซ์ข้อมูลกับ Firebase อัตโนมัติ
- ส่งออกข้อมูลเป็นไฟล์ CSV
- แสดงกราฟวิเคราะห์ผลการทดลอง

---

## Tech Stack

### Frontend
- Flutter Framework (Dart)

### Backend / Cloud
- Firebase Authentication
- Firebase Firestore

### Local Storage
- SQLite ผ่านไลบรารี `sqflite`

### Artificial Intelligence
- YOLOv8 (TensorFlow Lite Deployment)
- `flutter_vision`

### Data Visualization
- `fl_chart`

### File Management
- `path_provider`

---

## Database Architecture

ระบบใช้สถาปัตยกรรม **Hybrid Database Architecture** ร่วมกับ **Queue-based Synchronization** เพื่อรักษาความสมบูรณ์ของข้อมูลในสภาวะ Offline และ Online

---

### Cloud Database (Firebase Firestore)

โครงสร้างแบบ NoSQL Document-based (Nested Collection)

users (uid)
└── projects (projectId)
└── experiments (experimentId)


Fields:

- username
- photoUrl
- name
- drugName
- cellLine
- concentration
- colonyCount
- avgSize
- timestamp

---

### Local Database (SQLite Schema)

กำหนดในไฟล์:

`lib/services/local_database_service.dart`

```sql
CREATE TABLE projects (
  id TEXT PRIMARY KEY,
  name TEXT,
  drug_name TEXT,
  cell_line TEXT,
  is_synced INTEGER DEFAULT 0
);

CREATE TABLE experiments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_id TEXT,
  concentration REAL,
  colony_count INTEGER,
  avg_size REAL,
  image_path TEXT,
  timestamp TEXT
);

CREATE TABLE user_images (
  uid TEXT PRIMARY KEY,
  image_path TEXT
);
```
Installation Guide
Prerequisites
Flutter SDK version 3.0.0 or higher

Android Studio พร้อม Android SDK

Android Smartphone (สำหรับกล้องและ AI inference)

Firebase Console account

Setup Steps
1. Clone Repository
```sql
git clone https://github.com/[username]/cancer_cell_analysis.git
```
2. Install Dependencies
```sql
cd cancer_cell_analysis
flutter pub get
```
3. Configure Firebase
นำไฟล์ google-services.json จาก Firebase Console ไปวางที่:

android/app/google-services.json
4. Run Application
flutter run
User Guide
1. Authentication
เมื่อเปิดแอป ระบบจะแสดง login_screen.dart

ผู้ใช้เข้าสู่ระบบผ่าน Firebase Authentication

ผู้ใช้ใหม่สามารถ Register ได้

แก้ไขชื่อและรูปโปรไฟล์ในเมนู Profile

รูปภาพถูกเก็บ Offline ผ่าน insertUserProfileImage()

2. Project Management (CRUD)
หน้า dashboard_screen.dart แสดงรายการโครงการแบบ realtime ผ่าน StreamBuilder

กดปุ่ม (+) เพื่อสร้างโครงการ

ระบุชื่อโปรเจกต์ ชื่อยา และชนิดเซลล์

ปัดซ้ายเพื่อลบโครงการ (deleteProject())

3. AI Cell Analysis Workflow
กด Add Data

ถ่ายภาพจากกล้องจุลทรรศน์

ส่งภาพไป processing_screen.dart

วิเคราะห์ผ่านโมเดล YOLOv8

FlutterVision().yoloOnImage()
แสดง Bounding Box และจำนวนเซลล์ใน result_screen.dart

4. Offline-First Capability
ไม่มีอินเทอร์เน็ต → บันทึกข้อมูลลง SQLite อัตโนมัติ

รูปภาพย้ายไป ApplicationDocumentsDirectory

เมื่อออนไลน์ → ระบบ Sync ข้อมูลขึ้น Firebase อัตโนมัติ

5. Analytics & Data Export
แสดงกราฟความสัมพันธ์ระหว่างความเข้มข้นยาและจำนวนเซลล์

ใช้ไลบรารี fl_chart

Export CSV ผ่าน _exportToCSV()

แชร์ผ่าน Email หรือแอปอื่นได้

System Architecture
Flutter Mobile Application
        │
        ├── Local SQLite Database (Offline)
        │
        └── Firebase Firestore (Cloud Sync)
