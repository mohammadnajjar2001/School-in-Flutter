import 'dart:io'; // لإغلاق التطبيق

import 'package:AFAQ/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ParentWelcomePage extends StatelessWidget {
  final String token;

  const ParentWelcomePage({super.key, required this.token});

  Future<void> _logout(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/parent/logout'),
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Text(
                  'القائمة الرئيسية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('الصفحة الرئيسية'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('متابعة الأبناء'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('تقارير الأداء'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('الإعدادات'),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('تسجيل الخروج'),
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text('أهلاً بولي الأمر 👨‍👩‍👧‍👦'),
          backgroundColor: Colors.green,
          elevation: 0,
          automaticallyImplyLeading: true,
        ),
        body: Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.family_restroom, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'مرحبًا بك يا ولي الأمر!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'تم تسجيل دخولك بنجاح 👨‍👩‍👧‍👦',
                style: TextStyle(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
