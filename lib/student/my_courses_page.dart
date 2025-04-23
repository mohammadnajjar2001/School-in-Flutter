import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'student_drawer.dart';

class MyCoursesPage extends StatefulWidget {
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
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  Future<List<Map<String, dynamic>>> fetchSubjects() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/student/subjects'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> subjects = json.decode(response.body)['subjects'];
      return subjects.map((subject) {
        return {
          'ar': subject['name']['ar'],
          'en': subject['name']['en'],
        };
      }).toList();
    } else {
      throw Exception('فشل في تحميل المواد');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 المواد الدراسية'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      drawer: StudentDrawer(
        name: widget.name,
        email: widget.email,
        token: widget.token,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchSubjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('حدث خطأ أثناء تحميل المواد: ${snapshot.error}'));
            } else if (snapshot.data!.isEmpty) {
              return const Center(child: Text('لا توجد مواد متاحة'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final subject = snapshot.data![index];
                  return _buildCourseCard(subject['ar'], subject['en']);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCourseCard(String arName, String enName) {
    IconData? icon;
    String? imagePath;
    Color color;

    switch (arName) {
      case 'رياضيات':
        icon = Icons.calculate;
        color = Colors.orange;
        break;
      case 'عربي':
        icon = Icons.menu_book;
        color = Colors.redAccent;
        break;
      case 'انجليزي':
        icon = Icons.language;
        color = Colors.teal;
        break;
      case 'علوم':
        icon = Icons.science;
        color = Colors.blueAccent;
        break;
      case 'فيزياء':
        icon = Icons.flash_on;
        color = Colors.indigo;
        break;
      case 'كيمياء':
        icon = Icons.bubble_chart;
        color = Colors.deepPurple;
        break;
      case 'ديانة':
        imagePath = 'icons/mosque.png';
        color = Colors.green;
        break;
      case 'تاريخ':
        icon = Icons.history_edu;
        color = Colors.brown;
        break;
      case 'جغرافية':
        icon = Icons.public;
        color = Colors.blueGrey;
        break;
      default:
        icon = Icons.book;
        color = Colors.purple;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        leading: imagePath != null
            ? Image.asset(imagePath, width: 40, height: 40)
            : CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 28),
              ),
        title: Text(
          arName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          enName,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}
