class Validator {
  // 1. เช็คค่าว่างทั่วไป (สำหรับ ชื่อโปรเจค, ชื่อยา, ฯลฯ)
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  // 2. เช็คอีเมล (สำหรับหน้า Login/Register)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter Email';
    }
    // สูตร Regex มาตรฐานโลกสำหรับเช็คอีเมล
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid Email Format';
    }
    return null;
  }

  // 3. เช็ครหัสผ่าน (ต้องมากกว่า 6 ตัว)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // 4. เช็คตัวเลข (สำหรับ Concentration, Colony Count)
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a number';
    }
    if (number < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  // 5. เช็ค URL (สำหรับรูปโปรไฟล์)
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL ว่างได้ (ถ้า User ไม่ใส่)
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAbsolutePath) {
      return 'Invalid URL format';
    }
    return null;
  }
}