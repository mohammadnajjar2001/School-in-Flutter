import 'package:flutter/material.dart';
import 'package:AFAQ/main.dart';
import 'package:AFAQ/config.dart';
import 'package:AFAQ/parent/parent_welcome_page.dart';
import 'package:AFAQ/parent/follow_children_page.dart';
import 'package:AFAQ/parent/parent_profile_page.dart';
import 'package:AFAQ/parent/performance_reports_page.dart';
import 'package:AFAQ/parent/settings_page.dart';
import 'package:AFAQ/parent/parent_invoices_page0.dart';
import 'package:AFAQ/parent/parent_invoices_page.dart';
import 'package:http/http.dart' as http;

class ParentDrawer extends StatelessWidget {
  final String token;
  final String name;
  final String email;
  const ParentDrawer({
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF388E3C), Color(0xFF66BB6A)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '👋 مرحبا بك',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الصفحة الرئيسية'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ParentWelcomePage(
                    token: token,
                    name: name,
                    email: email,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('الملف الشخصي'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ParentProfilePage(
                    token: token,
                    name: name,
                    email: email,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('متابعة الأبناء'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FollowChildrenPage(
                    token: token,
                    name: name,
                    email: email,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('تقارير الأداء'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PerformanceReportsPage(
                    token: token,
                    name: name,
                    email: email,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text(' فواتير الواجب دفعها'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ParentInvoicesPage0(token: token),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('مدغوعات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ParentInvoicesPage(token: token),
                ),
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.settings),
          //   title: const Text('الإعدادات'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) =>
          //             SettingsPage(token: token, name: name, email: email),
          //       ),
          //     );
          //   },
          // ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('تسجيل الخروج'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
