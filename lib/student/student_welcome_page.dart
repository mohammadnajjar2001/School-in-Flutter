import 'package:flutter/material.dart';
import 'student_drawer.dart';

class StudentWelcomePage extends StatelessWidget {
  final String token;
  final String name;
  final String email;

  const StudentWelcomePage({
    super.key,
    required this.token,
    required this.name,
    required this.email,
  });

  Future<bool> _onWillPop(BuildContext context) async {
    // عندما يحاول المستخدم الضغط على زر الرجوع، سنعرض تنبيهًا
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد'),
            content: const Text('هل أنت متأكد أنك تريد مغادرة التطبيق؟'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // إغلاق التنبيه
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // إغلاق التطبيق
                child: const Text('مغادرة'),
              ),
            ],
          ),
        )) ??
        false; // إذا تم الضغط على إلغاء أو إذا تم إغلاق التنبيه بدون اختيار
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context), // التعامل مع زر الرجوع
      child: Scaffold(
        appBar: AppBar(
          title: Text('🎓 مرحبًا $name'),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        drawer: StudentDrawer(name: name, email: email, token: token),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text('!مرحبًا بك $name',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('🎉 تم تسجيل دخولك بنجاح ',
                  style: TextStyle(fontSize: 18, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}
