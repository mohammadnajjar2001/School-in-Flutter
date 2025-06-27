import 'dart:io';
import 'dart:convert';
import 'package:AFAQ/main.dart';
import 'package:AFAQ/parent/parent_drawer.dart';
import 'package:AFAQ/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FollowChildrenPage extends StatefulWidget {
  final String token;
  final String name;
  final String email;

  const FollowChildrenPage({
    super.key,
    required this.token,
    required this.name,
    required this.email,
  });

  @override
  State<FollowChildrenPage> createState() => _FollowChildrenPageState();
}

class _FollowChildrenPageState extends State<FollowChildrenPage> {
  List<dynamic> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final url = Uri.parse('$baseUrl/parent/students');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        students = data['data'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في تحميل بيانات الأبناء')),
      );
    }
  }

  Future<void> _fetchStudentResults(int studentId) async {
    // عرض دائرة التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final url = Uri.parse('$baseUrl/parent/student/$studentId/results');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    // إغلاق دائرة التحميل
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == true) {
        final results = data['data'] as List<dynamic>;
        String resultsSummary = 'عدد النتائج: ${results.length}\n\nالتواريخ:\n';
        for (var result in results) {
          resultsSummary += '- ${result['date']} (درجة: ${result['score']})\n';
        }
        _showAlertDialog('نتائج الطالب', resultsSummary);
      } else {
        _showAlertDialog(
            'نتائج الطالب', data['message'] ?? 'لا توجد نتائج لهذا الطالب.');
      }
    } else {
      _showAlertDialog('خطأ', 'لا توجد نتائج لهذا الطالب.');
    }
  }

  // Future<void> _fetchStudentResults(int studentId) async {
  //   final url = Uri.parse('$baseUrl/parent/student/$studentId/results');
  //   final response = await http.get(
  //     url,
  //     headers: {
  //       'Authorization': 'Bearer ${widget.token}',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);

  //     if (data['status'] == true) {
  //       final results = data['data'] as List<dynamic>;
  //       String resultsSummary = 'عدد النتائج: ${results.length}\n\nالتواريخ:\n';
  //       for (var result in results) {
  //         resultsSummary += '- ${result['date']} (درجة: ${result['score']})\n';
  //       }
  //       _showAlertDialog('نتائج الطالب', resultsSummary);
  //     } else {
  //       _showAlertDialog(
  //           'نتائج الطالب', data['message'] ?? 'لا توجد نتائج لهذا الطالب.');
  //     }
  //   } else {
  //     _showAlertDialog('خطأ', 'لا توجد نتائج لهذا الطالب.');
  //   }
  // }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(title, textAlign: TextAlign.right),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(message, textAlign: TextAlign.right),
        ),
        actions: [
          TextButton(
            child: const Text('حسنًا'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد'),
            content: const Text('هل تريد إغلاق التطبيق؟',
                textAlign: TextAlign.right),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: const Text('موافق'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        drawer: ParentDrawer(
          token: widget.token,
          name: widget.name,
          email: widget.email,
        ),
        appBar: AppBar(
          title: const Text('متابعة الأبناء 📚'),
          backgroundColor: Colors.green,
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            width: double.infinity,
            height: screenHeight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : students.isEmpty
                    ? const Center(
                        child: Text('لا يوجد أبناء مسجلين حاليًا',
                            textAlign: TextAlign.right),
                      )
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${student['name']['ar']} / ${student['name']['en']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'المرحلة الدراسية: ${student['grade']['Name']['ar']}',
                                    textAlign: TextAlign.right,
                                  ),
                                  Text(
                                    'الصف الدراسي: ${student['classroom']['Name_Class']['ar']}',
                                    textAlign: TextAlign.right,
                                  ),
                                  Text(
                                    'الشعبة: ${student['section']['Name_Section']['ar']}',
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _fetchStudentResults(student['id']),
                                    icon: const Icon(Icons.assignment),
                                    label: const Text('عرض النتائج'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
