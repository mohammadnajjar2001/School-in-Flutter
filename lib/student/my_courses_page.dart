import 'package:flutter/material.dart';
import 'student_drawer.dart';

class MyCoursesPage extends StatelessWidget {
  final String name;
  final String email;
  final String token;

  const MyCoursesPage({
    super.key,
    required this.name,
    required this.email,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 دروسي'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      drawer: StudentDrawer(name: name, email: email, token: token),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCourseCard('الرياضيات', Icons.calculate, Colors.orange),
            _buildCourseCard(
                'اللغة العربية', Icons.menu_book, Colors.redAccent),
            _buildCourseCard('العلوم', Icons.science, Colors.blueAccent),
            _buildCourseCard('اللغة الإنجليزية', Icons.language, Colors.teal),
            _buildCourseCard('التاريخ', Icons.history_edu, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(String title, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          // ممكن تفتح صفحة تفاصيل المادة هنا
        },
      ),
    );
  }
}
