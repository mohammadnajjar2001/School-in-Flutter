import 'package:AFAQ/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:schools/main.dart';
// import 'main.dart'; // تأكد أنك قمت بتعريف MyHomePage هناك

class ParentWelcomePage extends StatelessWidget {
  final String token;

  const ParentWelcomePage({super.key, required this.token});

  Future<void> _logout(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/parent/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyApp()),
        (route) => false,
      );
    } else {
      _showAlertDialog(context, 'حدث خطأ أثناء تسجيل الخروج');
    }
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تنبيه'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('حسنًا'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أهلاً بولي الأمر')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'تم تسجيل الدخول بنجاح كولي أمر 👨‍👩‍👧‍👦',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}
