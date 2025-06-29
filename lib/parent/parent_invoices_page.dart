import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:AFAQ/parent/parent_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:AFAQ/config.dart';

class ParentInvoicesPage extends StatefulWidget {
  final String token;
  const ParentInvoicesPage({super.key, required this.token});

  @override
  State<ParentInvoicesPage> createState() => _ParentInvoicesPageState();
}

class _ParentInvoicesPageState extends State<ParentInvoicesPage> {
  List<Map<String, dynamic>> invoices = [];
  List<dynamic> students = [];
  bool isLoading = true;

  String name = '';
  String email = '';

  int? selectedStudentId;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      // جلب بيانات الأب
      final profileResponse = await http.get(
        Uri.parse('$baseUrl/parent/profile'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (profileResponse.statusCode == 200) {
        final profileData = json.decode(profileResponse.body)['data'];
        setState(() {
          name = profileData['Name_Father']?['ar'] ?? 'غير معروف';
          email = profileData['email'] ?? 'غير معروف';
        });
      }

      // جلب الأبناء
      final studentsResponse = await http.get(
        Uri.parse('$baseUrl/parent/students'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (studentsResponse.statusCode == 200) {
        final studentsData = json.decode(studentsResponse.body)['data'];
        setState(() {
          students = studentsData;
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  Future<void> fetchReceiptsByStudent(int studentId) async {
    setState(() {
      isLoading = true;
      invoices = [];
    });

    final url = Uri.parse('$baseUrl/parent/student/$studentId/receipts');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          invoices = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'لا توجد مدفوعات')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في تحميل المدفوعات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💳 تم السداد '),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      drawer: ParentDrawer(
        token: widget.token,
        name: name,
        email: email,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // const SizedBox(height: 10),
                // Expanded(
                //   child: ParentInvoicesPage0(
                //     token: widget.token, // لو الصفحة تحتاج توكن
                //     // أو تمرر أي بيانات أخرى
                //   ),
                // ),
                if (students.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'اختر ابنك',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStudentId,
                      items: students.map<DropdownMenuItem<int>>((student) {
                        return DropdownMenuItem<int>(
                          value: student['id'],
                          child: Text(student['name']['ar']),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        if (value != null) {
                          setState(() => selectedStudentId = value);
                          fetchReceiptsByStudent(value);
                        }
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                Expanded(
                  child: selectedStudentId == null
                      ? const Center(
                          child:
                              Text('يرجى اختيار ابن من القائمة لعرض المدفوعات'))
                      : invoices.isEmpty
                          ? const Center(
                              child: Text('لا توجد مدفوعات لهذا الابن'))
                          : ListView.builder(
                              itemCount: invoices.length,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                final invoice = invoices[index];
                                return Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: ListTile(
                                    leading: const Icon(Icons.payment,
                                        color: Colors.green),
                                    title: Text(
                                      '💵 المدفوع: \$${invoice['Debit']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('📅 التاريخ: ${invoice['date']}'),
                                        Text(
                                            '📄 الوصف: ${invoice['description']}'),
                                      ],
                                    ),
                                    trailing: Text('#${invoice['id']}'),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}
