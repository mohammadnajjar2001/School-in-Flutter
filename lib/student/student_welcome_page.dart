import 'package:AFAQ/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:schools/main.dart';
// import 'main.dart';  // تأكد من استيراد ملف main.dart

class StudentWelcomePage extends StatelessWidget {
  final String token; // توكن المستخدم

  // تمرير التوكن من صفحة تسجيل الدخول
  const StudentWelcomePage({super.key, required this.token});

  // دالة لتسجيل الخروج
  Future<void> _logout(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/student/logout'),
      headers: {
        'Authorization': 'Bearer $token', // إرسال التوكن في ترويسة الطلب
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // إذا كانت عملية تسجيل الخروج ناجحة، العودة إلى صفحة تسجيل الدخول (main.dart)
      _showAlertDialog(context, 'تم تسجيل الخروج بنجاح');
      // بعد إغلاق الرسالة، العودة إلى main.dart
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  const MyApp()), // استبدال بـ MyHomePage من main.dart
        );
      });
    } else {
      // في حالة حدوث خطأ أثناء عملية تسجيل الخروج
      _showAlertDialog(context, 'حدث خطأ أثناء تسجيل الخروج');
    }
  }

  // دالة لعرض رسالة منبثقة (Alert Dialog)
  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تنبيه'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('حسنًا'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أهلاً بالطالب')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'تم تسجيل الدخول بنجاح كطالب 🎉',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _logout(context); // استدعاء دالة تسجيل الخروج
              },
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}
