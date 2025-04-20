import 'package:flutter/material.dart';
import 'student_drawer.dart';

class MyAssignmentsPage extends StatelessWidget {
  final String name;
  final String email;
  final String token;

  const MyAssignmentsPage({
    super.key,
    required this.name,
    required this.email,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 واجباتي'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      drawer: StudentDrawer(name: name, email: email, token: token),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildAssignmentCard(
              subject: 'الرياضيات',
              title: 'حل التمارين من صفحة 20 إلى 25',
              dueDate: 'تسليم: 22 أبريل',
              icon: Icons.calculate,
              color: Colors.orange,
            ),
            _buildAssignmentCard(
              subject: 'اللغة الإنجليزية',
              title: 'كتابة مقال عن "My Family"',
              dueDate: 'تسليم: 23 أبريل',
              icon: Icons.language,
              color: Colors.teal,
            ),
            _buildAssignmentCard(
              subject: 'العلوم',
              title: 'تقرير عن حالات المادة',
              dueDate: 'تسليم: 25 أبريل',
              icon: Icons.science,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard({
    required String subject,
    required String title,
    required String dueDate,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          subject,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(title),
            const SizedBox(height: 4),
            Text(dueDate, style: const TextStyle(color: Colors.red)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          // ممكن تضيف تفاصيل أو إجراءات لاحقًا
        },
      ),
    );
  }
}
