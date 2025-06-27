import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:AFAQ/main.dart';
import 'package:AFAQ/parent/parent_drawer.dart';
import 'package:AFAQ/config.dart';

class ParentWelcomePage extends StatelessWidget {
  final String token;
  final String name;
  final String email;

  const ParentWelcomePage({
    super.key,
    required this.token,
    required this.name,
    required this.email,
  });

  Future<void> _logout(BuildContext context) async {
    final response = await http.post(
      Uri.parse('$baseUrl/parent/logout'),
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
          MaterialPageRoute(builder: (_) => const MyApp()),
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

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/partner/events'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final now = DateTime.now();

      return data
          .where((event) {
            final start = DateTime.parse(event['start']);
            return start.month == now.month && start.year == now.year;
          })
          .map((event) => {
                'title': event['title'],
                'start': DateTime.parse(event['start']),
              })
          .toList();
    } else {
      throw Exception('فشل في تحميل أحداث ولي الأمر');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('👨‍👩‍👧‍👦 أهلاً $name'),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        drawer: ParentDrawer(token: token, name: name, email: email),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              '👋 مرحبًا بك، $name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              '📅 أحداث هذا الشهر',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'حدث خطأ أثناء جلب الأحداث: ${snapshot.error}'));
                  } else if (snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('لا توجد أحداث لهذا الشهر'));
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final event = snapshot.data![index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading:
                                const Icon(Icons.event, color: Colors.green),
                            title: Text(
                              event['title'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '📆 التاريخ: ${event['start'].toString().substring(0, 10)}',
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
