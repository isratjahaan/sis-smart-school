import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subjects = [
      {'name': 'Bangla 1st Paper', 'marks': 88, 'grade': 'A+', 'point': '5.00'},
      {'name': 'English 1st Paper', 'marks': 84, 'grade': 'A+', 'point': '5.00'},
      {'name': 'General Mathematics', 'marks': 95, 'grade': 'A+', 'point': '5.00'},
      {'name': 'General Science', 'marks': 91, 'grade': 'A+', 'point': '5.00'},
      {'name': 'ICT', 'marks': 46, 'grade': 'A+', 'point': '5.00'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Examination Results & GPA'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // GPA Highlight Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  const Text('FIRST TERM EXAMINATION 2026', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('GPA 5.00', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.black)),
                  const Text('Letter Grade: A+ (Outstanding)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Class Rank: #1 • Section Rank: #1', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Subject Marks Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Subject-wise Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    ...subjects.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          Expanded(
                            child: Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                          Text('${s['marks']} marks', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${s['grade']} (${s['point']})',
                              style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
