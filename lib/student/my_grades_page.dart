import 'package:flutter/material.dart';
import 'student_drawer.dart';

class MyGradesPage extends StatelessWidget {
  final String name;
  final String email;
  final String token;

  const MyGradesPage({
    super.key,
    required this.name,
    required this.email,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 درجاتي'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      drawer: StudentDrawer(name: name, email: email, token: token),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildGradeCard(
              subject: 'الرياضيات',
              grade: 95,
              color: Colors.orange,
            ),
            _buildGradeCard(
              subject: 'اللغة العربية',
              grade: 88,
              color: Colors.teal,
            ),
            _buildGradeCard(
              subject: 'العلوم',
              grade: 76,
              color: Colors.indigo,
            ),
            _buildGradeCard(
              subject: 'اللغة الإنجليزية',
              grade: 82,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeCard({
    required String subject,
    required int grade,
    required Color color,
  }) {
    String level;
    if (grade >= 90) {
      level = 'ممتاز';
    } else if (grade >= 80) {
      level = 'جيد جدًا';
    } else if (grade >= 70) {
      level = 'جيد';
    } else {
      level = 'بحاجة لتحسين';
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.grade, color: color),
        ),
        title: Text(
          subject,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'الدرجة: $grade / 100\nالتقدير: $level',
          style: const TextStyle(height: 1.4),
        ),
      ),
    );
  }
}
