import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // 1. Create Project
  Future<void> createProject({
    required String name,
    required String description,
    required String cellLine,
    required String drugName,
  }) async {
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).collection('projects').add({
      'name': name,
      'description': description,
      'cellLine': cellLine,
      'drugName': drugName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. Read Projects
  Stream<QuerySnapshot> getProjects() {
    if (uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 3. Update Project
  Future<void> updateProjectDetails(
    String projectId,
    String name,
    String description,
    String cellLine,
    String drugName,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(projectId)
        .update({
          'name': name,
          'description': description,
          'cellLine': cellLine,
          'drugName': drugName,
        });
  }

  // 4. Delete Project
  Future<void> deleteProject(String projectId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(projectId)
        .delete();
  }

  // 5. Save Experiment Data
  Future<void> saveExperimentData({
    required String projectId,
    required String drugName,
    required double concentration,
    required int colonyCount,
    required double avgSize,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(projectId)
        .collection('experiments')
        .add({
          'drugName': drugName,
          'concentration': concentration,
          'colonyCount': colonyCount,
          'avgSize': avgSize,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  // 6. Get Experiment Data
  Stream<QuerySnapshot> getProjectData(String projectId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(projectId)
        .collection('experiments')
        .orderBy('concentration')
        .snapshots();
  }

  // 7. Delete Experiment Data
  Future<void> deleteExperimentData(String projectId, String documentId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(projectId)
        .collection('experiments')
        .doc(documentId)
        .delete();
  }

  // 8. ✅ Update User Profile (แก้ไขให้รองรับ Named Parameters และ photoUrl)
  Future<void> updateUserProfile({String? username, String? photoUrl}) async {
    if (uid.isEmpty) return;

    Map<String, dynamic> dataToUpdate = {};
    
    // อัปเดตเฉพาะค่าที่ส่งมา (ไม่ส่งมาก็ไม่ทับของเดิม)
    if (username != null) dataToUpdate['username'] = username;
    if (photoUrl != null) dataToUpdate['photoUrl'] = photoUrl;

    if (dataToUpdate.isNotEmpty) {
      await _db.collection('users').doc(uid).update(dataToUpdate);
    }
  }
}