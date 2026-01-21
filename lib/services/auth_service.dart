import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ฟังก์ชันสมัครสมาชิก (Register)
  Future<User?> register({
    required String email,
    required String password,
    required String name,
    required String studentId,
  }) async {
    try {
      // 1. สร้าง User ในระบบ Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;

      // 2. เก็บข้อมูลเพิ่ม (ชื่อ, รหัสนศ.) ลงใน Firestore Database
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'studentId': studentId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // จับ Error ของ Firebase โดยเฉพาะ (เช่น รหัสผ่านสั้น, อีเมลซ้ำ)
      throw e.message ?? "Registration failed";
    } catch (e) {
      // จับ Error อื่นๆ ทั้งหมด (เช่น เรื่อง Permission Database)
      // สำคัญ: ส่ง e.toString() ออกไป เพื่อให้เรารู้ว่ามันพังเพราะอะไร
      throw e.toString();
    }
  }

  // ฟังก์ชันเข้าสู่ระบบ (Login)
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Login failed";
    } catch (e) {
      throw e.toString();
    }
  }

  // ฟังก์ชันออกจากระบบ
  Future<void> logout() async {
    await _auth.signOut();
  }
}