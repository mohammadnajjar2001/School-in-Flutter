import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:AFAQ/parent/parent_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:AFAQ/config.dart';

class ParentInvoicesPage0 extends StatefulWidget {
  final String token;
  const ParentInvoicesPage0({super.key, required this.token});

  @override
  State<ParentInvoicesPage0> createState() => _ParentInvoicesPage0State();
}

class _ParentInvoicesPage0State extends State<ParentInvoicesPage0> {
  List<Map<String, dynamic>> invoices = [];
  bool isLoading = true;
  String name = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    fetchParentInfoAndInvoices();
  }

  Future<void> fetchParentInfoAndInvoices() async {
    try {
      // جلب البيانات الشخصية
      final profileResponse = await http.get(
        Uri.parse('$baseUrl/parent/profile'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (profileResponse.statusCode == 200) {
        final profileBody = json.decode(profileResponse.body);
        final profileData = profileBody['data'];

        // التأكد من وجود الحقول قبل استخدامها
        final fetchedName = profileData['Name_Father']?['ar'] ?? 'غير معروف';
        final fetchedEmail = profileData['email'] ?? 'غير معروف';

        setState(() {
          name = fetchedName;
          email = fetchedEmail;
        });
      } else {
        throw Exception('فشل في تحميل الملف الشخصي');
      }

      // جلب الفواتير
      final invoiceResponse = await http.get(
        Uri.parse('$baseUrl/parent/fee-invoices'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (invoiceResponse.statusCode == 200) {
        final invoiceData = json.decode(invoiceResponse.body);
        setState(() {
          invoices = List<Map<String, dynamic>>.from(invoiceData['data']);
          isLoading = false;
        });
      } else {
        throw Exception('فشل في تحميل الفواتير');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' فواتير الواجب دفعها 💳'),
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
          : invoices.isEmpty
              ? const Center(child: Text('لا توجد فواتير حاليًا.'))
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
                        leading:
                            const Icon(Icons.receipt_long, color: Colors.green),
                        title: Text(
                          '💵 المبلغ: \$${invoice['amount']} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📅 التاريخ: ${invoice['invoice_date']}'),
                            Text('📄 الوصف: ${invoice['description']}'),
                          ],
                        ),
                        trailing: Text('#${invoice['id']}'),
                      ),
                    );
                  },
                ),
    );
  }
}
