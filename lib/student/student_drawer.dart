import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:AFAQ/main.dart';
import 'student_welcome_page.dart';
import 'student_profile_page.dart'; // أضف هذا في بداية الملف
import 'my_courses_page.dart';
import 'package:AFAQ/config.dart';
import 'my_assignments_page.dart';
import 'my_grades_page.dart';

class StudentDrawer extends StatelessWidget {
  final String name;
  final String email;
  final String token;

  const StudentDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.token,
  });

  Future<void> _logout(BuildContext context) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      _showAlertDialog(context, 'تم تسجيل الخروج بنجاح');
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  const MyApp()), // إعادة التوجيه إلى الصفحة الرئيسية
          (route) => false,
        );
      });
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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF388E3C), Color(0xFF66BB6A)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('👋 مرحبًا بك',
                          style: TextStyle(color: Colors.white70)),
                      Text(email,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الرئيسية'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => StudentWelcomePage(
                        name: name,
                        email: email,
                        token: token,
                      )),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('المواد والكتب'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => MyCoursesPage(
                        name: name,
                        email: email,
                        token: token,
                      )),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('الاختبارات'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => MyAssignmentsPage(
                        name: name,
                        email: email,
                        token: token,
                      )),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.grade),
            title: const Text('درجاتي'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => MyGradesPage(
                        name: name,
                        email: email,
                        token: token,
                      )),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('الملف الشخصي'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => StudentProfilePage(
                  name: name,
                  email: email,
                  token: token,
                ),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('تسجيل الخروج'),
            onTap: () => _logout(context), // استدعاء دالة تسجيل الخروج
          ),
        ],
      ),
    );
  }
}
