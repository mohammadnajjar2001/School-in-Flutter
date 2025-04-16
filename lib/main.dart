import 'package:flutter/material.dart';
import 'student/student_login_page.dart';
import 'parent/parent_login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AFAQ',
      theme: ThemeData(
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// Splash Screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    });

    return Scaffold(
      body: Center(
        child: Image.asset('images/logo.png', width: 150),
      ),
    );
  }
}

// Onboarding Screens
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'حلول ذكية لمستقبل أكثر إشراقًا',
      'subtitle':
          'غيّر طريقة إدارتك المدرسية مع ميزات متكاملة توفّر الوقت وتقلّل الجهد.',
      'image': 'images/image1.jpg',
      'background': 'images/image3.png', // صورة الخلفية للشاشة الأولى
    },
    {
      'title': 'ابدأ رحلتك التعليمية!',
      'subtitle': 'أدخل معلوماتك للوصول إلى حسابك الشخصي وإدارة مهامك.',
      'image': 'images/logo.png',
    },
  ];

  void _nextPage() {
    if (currentIndex < onboardingData.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginChoicePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = onboardingData[currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          // خلفية مخصصة إذا موجودة
          if (item.containsKey('background'))
            Positioned.fill(
              child: Image.asset(
                item['background']!,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    if (item['image'] != null)
                      Image.asset(item['image']!, height: 200),
                    const SizedBox(height: 30),
                    Text(
                      item['title']!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      item['subtitle']!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(onboardingData.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: currentIndex == index ? 16 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentIndex == index
                                ? Colors.green
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: currentIndex > 0
                              ? () {
                                  setState(() {
                                    currentIndex--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.arrow_back_rounded),
                          iconSize: 36,
                          color: currentIndex > 0 ? Colors.green : Colors.grey,
                          tooltip: 'السابق',
                        ),
                        IconButton(
                          onPressed: _nextPage,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          iconSize: 36,
                          color: Colors.green,
                          tooltip: 'التالي',
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Login Type Selection
class LoginChoicePage extends StatelessWidget {
  const LoginChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ✅ شعار AFAQ بخلفية خضراء عرض كامل
            Container(
              width: double.infinity,
              color: Colors.green,
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Image.asset('images/logo.png', height: 150),
              ),
            ),

            const SizedBox(height: 30),

            // باقي الصفحة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StudentLoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('تسجيل الدخول كطالب'),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ParentLoginPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('تسجيل الدخول كولي أمر'),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // سياسة الخصوصية
                    },
                    child: const Text(
                        "بالدخول فإنك توافق على سياسة الخصوصية الخاصة بنا"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
