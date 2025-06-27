import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final int score;

  const QuizResultPage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("نتيجة الاختبار"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildResultCard(score),
            const SizedBox(height: 20),
            _buildFeedback(score),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(int score) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.emoji_events,
              color: Colors.green,
              size: 50,
            ),
            const SizedBox(height: 10),
            Text(
              'نتيجتك: $score',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              score >= 80
                  ? 'ممتاز! استمر في العمل الرائع.'
                  : score >= 50
                      ? 'جيد، لكن هناك مجال للتحسن.'
                      : 'حاول مرة أخرى! لا تيأس.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback(int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            'ملاحظات:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            score >= 80
                ? 'أنت قد أتممت الاختبار بنجاح وبمستوى عالٍ من الفهم. استمر في التحصيل العلمي الممتاز!'
                : score >= 50
                    ? 'أنت على المسار الصحيح! لكن تحتاج إلى بعض المراجعة والتحسين. لا تتوقف هنا!'
                    : 'لا بأس! تحتاج إلى مراجعة المحتوى بشكل أعمق. بإصرارك ستصل إلى النجاح.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(
            context); // يمكن استبدالها بالانتقال إلى صفحة الاختبار من البداية
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'إعادة المحاولة',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
