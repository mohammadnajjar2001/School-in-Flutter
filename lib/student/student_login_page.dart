import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'student_welcome_page.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> _login() async {
    final emailInput = _emailController.text.trim();
    final password = _passwordController.text;

    if (emailInput.isEmpty || password.isEmpty) {
      _showAlertDialog('الرجاء إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/login/student'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': emailInput,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final user = responseData['user'];
      final name = user['name']['ar'];     // الاسم بالعربية
      final email = user['email'];         // الإيميل
      final token = responseData['token']; // التوكن

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentWelcomePage(
            token: token,
            name: name,
            email: email,
          ),
        ),
      );
    } else {
      _showAlertDialog('البريد الإلكتروني أو كلمة المرور غير صحيحة');
    }
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('خطأ'),
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // خلفية مع الشعار
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        child: Image.asset(
                          'images/image3.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          height: 180,
                        ),
                      ),
                      Image.asset('images/logo.png', height: 200),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'اهلاً بك في AFAQ!',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'تسجيل الدخول عبر البريد الإلكتروني أو الرقم التسلسلي للطالب',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  // حقل البريد الإلكتروني
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'البريد الإلكتروني أو الرقم التسلسلي',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 16),
                  // حقل كلمة المرور
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: 'كلمة المرور',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 30),
                  // زر الدخول
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF6DC24B),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('تسجيل الدخول',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
