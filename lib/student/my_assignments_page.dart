import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'student_drawer.dart';
import 'quiz_questions_page.dart';

class MyAssignmentsPage extends StatefulWidget {
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
  State<MyAssignmentsPage> createState() => _MyAssignmentsPageState();
}

class _MyAssignmentsPageState extends State<MyAssignmentsPage> {
  List quizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/student/quizzes'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        quizzes = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في تحميل الاختبارات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📝 الاختبارات'),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        drawer: StudentDrawer(
          name: widget.name,
          email: widget.email,
          token: widget.token,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : quizzes.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد اختبارات متاحة',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizzes[index];
                      final quizName = quiz['name']['ar'] ?? 'بدون اسم';
                      final subjectName =
                          quiz['subject']['name']['ar'] ?? 'بدون مادة';
                      final teacherName =
                          quiz['teacher']['Name']['ar'] ?? 'بدون معلم';
                      final quizId = quiz['id'];

                      return _buildQuizCard(
                        quizName: quizName,
                        subjectName: subjectName,
                        teacherName: teacherName,
                        quizId: quizId,
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildQuizCard({
    required String quizName,
    required String subjectName,
    required String teacherName,
    required int quizId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.teal.shade200, Colors.green.shade400],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.quiz, size: 40, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        quizName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'المادة: $subjectName',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المعلم: $teacherName',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizQuestionsPage(
                        quizId: quizId,
                        token: widget.token,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text("دخول للاختبار"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
