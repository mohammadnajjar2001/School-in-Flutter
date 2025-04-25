import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'quiz_result_page.dart';

class QuizQuestionsPage extends StatefulWidget {
  final int quizId;
  final String token;

  const QuizQuestionsPage({
    super.key,
    required this.quizId,
    required this.token,
  });

  @override
  State<QuizQuestionsPage> createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  List questions = [];
  Map<int, String> selectedAnswers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final url =
        'http://10.0.2.2:8000/api/student/quizze/${widget.quizId}/get-questions';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);

      // 1) إذا كانت النتيجة عدد صحيح مباشرة
      if (data is int) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QuizResultPage(score: data), // تمرير score مباشرةً
          ),
        );
        return;
      }

      // 2) إذا كانت خريطة وتحتوي على مفتاح 'score'
      if (data is Map<String, dynamic> && data['score'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                QuizResultPage(score: data['score']), // تمرير score مباشرةً
          ),
        );
        return;
      }

      // 3) خلاف ذلك نفترض أن لدينا قائمة أسئلة
      if (data is Map<String, dynamic> && data['questions'] != null) {
        setState(() {
          questions = data['questions'];
          isLoading = false;
        });
        return;
      }

      // 4) إذا وصلنا هنا، فالاستجابة غير متوقعة
      throw Exception('تنسيق الاستجابة غير معروف');
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في تحميل الأسئلة')),
      );
    }
  }

  Future<void> submitAnswers() async {
    final payload = selectedAnswers.entries
        .map((e) => {"q_id": e.key, "answer": e.value})
        .toList();
    final url =
        'http://10.0.2.2:8000/api/student/quizze/${widget.quizId}/answer-questions';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"data": payload}),
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      int score;
      if (data is int) {
        score = data;
      } else if (data is Map<String, dynamic> && data['score'] != null) {
        score = data['score'];
      } else {
        throw Exception('تنسيق نتيجة غير متوقع');
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultPage(score: score), // تمرير score مباشرةً
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إرسال الإجابات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
    final answered = selectedAnswers.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("الأسئلة"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : answered / total,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لقد أجبت على $answered من $total سؤال',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: total,
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        final answers = (q['answers'] as String).split('-');
                        final qId = q['id'] as int;
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'س${index + 1}: ${q['title']}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 12),
                                ...answers.map((answer) {
                                  return RadioListTile<String>(
                                    value: answer,
                                    groupValue: selectedAnswers[qId],
                                    onChanged: (val) {
                                      setState(() {
                                        selectedAnswers[qId] = val!;
                                      });
                                    },
                                    title: Text(
                                      answer,
                                      textAlign: TextAlign.right,
                                    ),
                                    activeColor: Colors.green,
                                    tileColor: selectedAnswers[qId] == answer
                                        ? Colors.green.shade50
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: answered == total ? submitAnswers : null,
                      child: const Text('إرسال الإجابات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
