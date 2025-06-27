import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:AFAQ/parent/parent_drawer.dart';
import 'package:AFAQ/config.dart';
import 'package:http/http.dart' as http;

class ParentProfilePage extends StatefulWidget {
  final String token;
  final String name;
  final String email;

  const ParentProfilePage({
    super.key,
    required this.token,
    required this.name,
    required this.email,
  });

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final url = Uri.parse('$baseUrl/parent/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      setState(() {
        profileData = body['data'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل في تحميل الملف الشخصي")),
      );
    }
  }

  Future<void> _editProfileDialog() async {
    final nameArController =
        TextEditingController(text: profileData?['Name_Father']['ar']);
    final nameEnController =
        TextEditingController(text: profileData?['Name_Father']['en']);
    final phoneController =
        TextEditingController(text: profileData?['Phone_Father']);
    final jobArController =
        TextEditingController(text: profileData?['Job_Father']['ar']);
    final jobEnController =
        TextEditingController(text: profileData?['Job_Father']['en']);
    final addressController =
        TextEditingController(text: profileData?['Address_Father']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل معلومات الأب'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameArController,
                decoration: const InputDecoration(labelText: 'الاسم بالعربية'),
                textDirection: TextDirection.rtl,
              ),
              TextField(
                controller: nameEnController,
                decoration:
                    const InputDecoration(labelText: 'الاسم بالإنجليزية'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الجوال'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: jobArController,
                decoration:
                    const InputDecoration(labelText: 'الوظيفة بالعربية'),
                textDirection: TextDirection.rtl,
              ),
              TextField(
                controller: jobEnController,
                decoration:
                    const InputDecoration(labelText: 'الوظيفة بالإنجليزية'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'العنوان'),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('حفظ'),
            onPressed: () async {
              if (nameArController.text.isEmpty ||
                  nameEnController.text.isEmpty ||
                  phoneController.text.isEmpty ||
                  jobArController.text.isEmpty ||
                  jobEnController.text.isEmpty ||
                  addressController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('الرجاء ملء جميع الحقول'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              await _submitProfileUpdate(
                nameArController.text,
                nameEnController.text,
                phoneController.text,
                jobArController.text,
                jobEnController.text,
                addressController.text,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitProfileUpdate(
    String nameAr,
    String nameEn,
    String phone,
    String jobAr,
    String jobEn,
    String address,
  ) async {
    final url = Uri.parse('$baseUrl/parent/profile');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "Name_Father": {
          "ar": nameAr,
          "en": nameEn,
        },
        "Phone_Father": phone,
        "Job_Father": {
          "ar": jobAr,
          "en": jobEn,
        },
        "Address_Father": address,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث البيانات بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      fetchProfile();
    } else {
      final error = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error['message'] ?? 'فشل في تحديث البيانات'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.right),
      subtitle: Text(value, textAlign: TextAlign.right),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      drawer: ParentDrawer(
        token: widget.token,
        name: widget.name,
        email: widget.email,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileData == null
              ? const Center(child: Text("لا توجد بيانات"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'معلومات الأب',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const Divider(thickness: 1),
                              _buildInfoTile(
                                  'الاسم', profileData!['Name_Father']['ar']),
                              _buildInfoTile('رقم الهوية',
                                  profileData!['National_ID_Father']),
                              _buildInfoTile('رقم الجواز',
                                  profileData!['Passport_ID_Father']),
                              _buildInfoTile(
                                  'رقم الجوال', profileData!['Phone_Father']),
                              _buildInfoTile(
                                  'الوظيفة', profileData!['Job_Father']['ar']),
                              _buildInfoTile(
                                  'العنوان', profileData!['Address_Father']),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _editProfileDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text(
                          'تعديل المعلومات',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _changePasswordDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        icon: const Icon(Icons.lock),
                        label: const Text(
                          'تغيير كلمة المرور',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<void> _changePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    bool showCurrent = false;
    bool showNew = false;
    bool showConfirm = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('تغيير كلمة المرور'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentController,
                  obscureText: !showCurrent,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور الحالية',
                    suffixIcon: IconButton(
                      icon: Icon(
                        showCurrent ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() {
                        showCurrent = !showCurrent;
                      }),
                    ),
                  ),
                ),
                TextField(
                  controller: newController,
                  obscureText: !showNew,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    suffixIcon: IconButton(
                      icon: Icon(
                        showNew ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() {
                        showNew = !showNew;
                      }),
                    ),
                  ),
                ),
                TextField(
                  controller: confirmController,
                  obscureText: !showConfirm,
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirm ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() {
                        showConfirm = !showConfirm;
                      }),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('إلغاء'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('حفظ'),
                onPressed: () async {
                  Navigator.pop(context);
                  await _submitPasswordChange(
                    currentController.text,
                    newController.text,
                    confirmController.text,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitPasswordChange(
      String current, String newPass, String confirm) async {
    final url = Uri.parse('$baseUrl/parent/change-password');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'current_password': current,
        'new_password': newPass,
        'new_password_confirmation': confirm,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
      );
    } else {
      final error = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error['message'] ?? 'فشل في تغيير كلمة المرور'),
        ),
      );
    }
  }
}
