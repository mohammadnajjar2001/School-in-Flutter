import 'dart:convert';
import 'package:flutter/material.dart';
import 'student_drawer.dart';
import 'package:AFAQ/config.dart';
import 'package:http/http.dart' as http;

class StudentProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String token;

  const StudentProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.token,
  });

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newPasswordConfirmationController = TextEditingController();
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/student/profile'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        profileData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في تحميل البيانات')),
      );
    }
  }

  Future<void> changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final newPasswordConfirmation = _newPasswordConfirmationController.text;

    if (newPassword != newPasswordConfirmation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمات المرور الجديدة غير متطابقة')),
      );
      return;
    }

    setState(() => _isChangingPassword = true);

    final response = await http.put(
      Uri.parse('$baseUrl/student/password'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      }),
    );

    setState(() => _isChangingPassword = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في تغيير كلمة المرور')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
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
          : profileData == null
              ? const Center(child: Text('لا توجد بيانات متاحة'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.person,
                                      size: 40, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 20),
                              buildProfileRow(
                                  Icons.person, "الاسم", profileData!["name"]),
                              buildProfileRow(Icons.email, "البريد الإلكتروني",
                                  profileData!["email"]),
                              buildProfileRow(Icons.male, "الجنس",
                                  profileData!["gender"]["Name"]["ar"]),
                              buildProfileRow(Icons.cake, "تاريخ الميلاد",
                                  profileData!["date_of_birth"]),
                              buildProfileRow(Icons.family_restroom, "اسم الأب",
                                  profileData!["parent"]["Name_Father"]["ar"]),
                              buildProfileRow(Icons.school, "المرحلة الدراسية",
                                  profileData!["grade"]["Name"]["ar"]),
                              buildProfileRow(
                                  Icons.class_,
                                  "الصف",
                                  profileData!["classroom"]["Name_Class"]
                                      ["ar"]),
                              buildProfileRow(
                                  Icons.group,
                                  "الشعبة",
                                  profileData!["section"]["Name_Section"]
                                      ["ar"]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _showChangePasswordDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          elevation: 5,
                        ),
                        child: const Text('تغيير كلمة المرور'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget buildProfileRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    // متغيرات محليّة للتحكم في حالة الإخفاء داخل مربع الحوار
    bool isCurrObscured = true;
    bool isNewObscured = true;
    bool isConfirmObscured = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('تغيير كلمة المرور'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // كلمة المرور الحالية
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: isCurrObscured,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الحالية',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isCurrObscured
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            isCurrObscured = !isCurrObscured;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // كلمة المرور الجديدة
                  TextField(
                    controller: _newPasswordController,
                    obscureText: isNewObscured,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الجديدة',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isNewObscured
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            isNewObscured = !isNewObscured;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // تأكيد كلمة المرور الجديدة
                  TextField(
                    controller: _newPasswordConfirmationController,
                    obscureText: isConfirmObscured,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور الجديدة',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmObscured
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmObscured = !isConfirmObscured;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () {
                    changePassword();
                    Navigator.of(context).pop();
                  },
                  child: _isChangingPassword
                      ? const CircularProgressIndicator()
                      : const Text('تغيير'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
