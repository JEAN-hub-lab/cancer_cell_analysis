import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. สมัครสมาชิก (แบบเดิม: พิมพ์ยังไงเก็บอย่างนั้น)
  Future<User?> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // แค่ตัดช่องว่างพอ ไม่ต้องแปลงตัวเล็ก/ใหญ่
      String cleanUsername = username.trim();
      String cleanEmail = email.trim();

      // เช็ก Username ซ้ำ
      final checkUser = await _firestore.collection('users')
          .where('username', isEqualTo: cleanUsername).get();
          
      if (checkUser.docs.isNotEmpty) throw "Username '$username' is already taken.";

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail, password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': cleanEmail,
          'username': cleanUsername, // เก็บค่าเดิมเป๊ะๆ
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  // 2. ล็อกอิน (แบบเดิม: ค้นหาตามที่พิมพ์เป๊ะๆ)
  Future<User?> login(String input, String password) async {
    try {
      String cleanInput = input.trim();
      String email = cleanInput;
      
      // ถ้าไม่มี @ แสดงว่าเป็น Username
      if (!cleanInput.contains('@')) {
        // ค้นหาเลย ไม่ต้องแปลงเป็นตัวเล็ก
        final query = await _firestore.collection('users')
            .where('username', isEqualTo: cleanInput).limit(1).get();
        
        if (query.docs.isEmpty) throw "Username not found";
        
        // ถ้าเจอ ให้เอาอีเมลออกมา
        email = query.docs.first.data()['email'];
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Login failed";
    } catch (e) {
      throw e.toString();
    }
  }

  // 3. ออกจากระบบ
  Future<void> logout() async => await _auth.signOut();
  
  // 4. ดึงข้อมูล User ปัจจุบัน
  User? get currentUser => _auth.currentUser;

  // 5. ✅ เพิ่มฟังก์ชันลบบัญชี (Delete Account)
  Future<void> deleteUserAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // 1. ลบข้อมูล User ใน Firestore ก่อน (Optional: เพื่อความสะอาดของ DB)
        await _firestore.collection('users').doc(user.uid).delete();

        // 2. ลบบัญชี Login ถาวร
        await user.delete();
      } on FirebaseAuthException catch (e) {
        // กรณี Login ไว้นานเกินไป Firebase จะไม่ยอมให้ลบ (เพื่อความปลอดภัย)
        if (e.code == 'requires-recent-login') {
          throw "Please log out and log in again before deleting your account.";
        }
        throw e.message ?? "Failed to delete account";
      } catch (e) {
        throw e.toString();
      }
    }
  }
}