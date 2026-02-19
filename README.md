# Cancer Cell Analysis Application

แอปพลิเคชันสำหรับวิเคราะห์ นับจำนวน และวัดขนาดเซลล์มะเร็งผ่านกล้องจุลทรรศน์ด้วยเทคโนโลยีปัญญาประดิษฐ์ (AI) โครงงานนี้พัฒนาระบบสถาปัตยกรรมฐานข้อมูลแบบผสมผสาน (Hybrid Database) เพื่อรองรับการทำงานในสภาวะที่ไม่มีสัญญาณอินเทอร์เน็ต (Offline-First) และสามารถซิงโครไนซ์ข้อมูลขึ้นระบบคลาวด์ได้โดยอัตโนมัติ

## 1. ข้อมูลทางเทคนิค (Tech Stack)
- **Frontend:** Flutter Framework (Dart)
- **Backend / Cloud Database:** Firebase (Authentication, Firestore)
- **Local Database (Offline Storage):** SQLite (ผ่านไลบรารี `sqflite`)
- **Artificial Intelligence:** YOLOv8 Deployment (TensorFlow Lite) ผ่านไลบรารี `flutter_vision`
- **Data Visualization & Analytics:** `fl_chart`
- **File System:** `path_provider` สำหรับการจัดการ Permanent Storage

---

## 2. โครงสร้างฐานข้อมูลระดับซอร์สโค้ด (Data Model & Source Code Structure)

ระบบใช้สถาปัตยกรรม Hybrid Database ควบคู่กับ Queue-based Synchronization เพื่อความสมบูรณ์ของข้อมูล

### 2.1 Cloud Database (Firebase Firestore)
จัดเก็บในรูปแบบ NoSQL Document-based (Nested Collection)
- **Collection:** `users` (Document ID: `uid`)
  - **Fields:** `username` (String), `photoUrl` (String)
  - **Sub-collection:** `projects` (Document ID: `projectId`)
    - **Fields:** `name`, `drugName`, `cellLine` (String), `createdAt` (Timestamp)
    - **Sub-collection:** `experiments` (Document ID: `experimentId`)
      - **Fields:** `concentration` (Number), `colonyCount` (Number), `avgSize` (Number), `timestamp` (Timestamp)

### 2.2 Local Database (SQLite Schema)
การกำหนดสคีมาตารางในไฟล์ `lib/services/local_database_service.dart`:

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
