// استيراد المكتبات المطلوبة
import 'dart:io';
import 'dart:convert';
import 'package:AFAQ/main.dart';
import 'package:AFAQ/parent/parent_drawer.dart';
import 'package:AFAQ/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PerformanceReportsPage extends StatefulWidget {
  final String token;
  final String name;
  final String email;
  const PerformanceReportsPage({
    super.key,
    required this.token,
    required this.name,
    required this.email,
  });

  @override
  State<PerformanceReportsPage> createState() => _PerformanceReportsPageState();
}

class _PerformanceReportsPageState extends State<PerformanceReportsPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  List<dynamic> _attendanceResults = [];
  List<dynamic> _students = [];
  String? _selectedStudentId;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
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
        _students = data['data'];
      });
    }
  }

  Future<void> _fetchAttendance(BuildContext context) async {
    final fromDate = _fromController.text.trim();
    final toDate = _toController.text.trim();

    if (fromDate.isEmpty || toDate.isEmpty) {
      _showAlertDialog(context, 'يرجى إدخال تاريخ البداية والنهاية.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final url = Uri.parse('$baseUrl/parent/attendance');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "from": fromDate,
        "to": toDate,
        if (_selectedStudentId != null && _selectedStudentId!.isNotEmpty)
          "student_id": _selectedStudentId
      }),
    );

    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          _attendanceResults = data['data'];
        });
      } else {
        _showAlertDialog(context, data['message'] ?? 'لا توجد نتائج.');
      }
    } else {
      _showAlertDialog(context, 'فشل في جلب البيانات.');
    }
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Directionality(
          textDirection: TextDirection.rtl,
          child: Text('تنبيه', textAlign: TextAlign.right),
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
            content: const Text('هل تريد إغلاق التطبيق؟'),
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
        drawer: Drawer(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ParentDrawer(
              token: widget.token,
              name: widget.name,
              email: widget.email,
            ),
          ),
        ),
        appBar: AppBar(
          title: const Text('تقارير الأداء 📈'),
          backgroundColor: Colors.green,
          centerTitle: true,
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'من تاريخ:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextField(
                    controller: _fromController,
                    textAlign: TextAlign.right,
                    decoration:
                        const InputDecoration(hintText: 'مثال: 2025-05-01'),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        _fromController.text =
                            picked.toIso8601String().split('T').first;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'إلى تاريخ:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextField(
                    controller: _toController,
                    textAlign: TextAlign.right,
                    decoration:
                        const InputDecoration(hintText: 'مثال: 2025-06-25'),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        _toController.text =
                            picked.toIso8601String().split('T').first;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'اسم الطالب (اختياري):',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedStudentId,
                    decoration: const InputDecoration(
                        hintText: 'اختر طالبًا أو اتركه فارغًا'),
                    items: _students.map<DropdownMenuItem<String>>((student) {
                      final name = student['name']['ar'];
                      final id = student['id'].toString();
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(name, textDirection: TextDirection.rtl),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStudentId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _fetchAttendance(context),
                      child: const Text('جلب التقارير'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ..._attendanceResults.map((record) {
                    final studentName = record['students']['name']['ar'];
                    final date = record['attendence_date'];
                    final status =
                        record['attendence_status'] == 1 ? '✔️ حاضر' : '❌ غائب';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '- $studentName: $date ← $status',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.right,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
