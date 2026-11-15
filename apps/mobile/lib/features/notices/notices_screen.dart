import 'package:flutter/material.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notices = [
      {
        'title': 'First Term Examination 2026 Schedule Published',
        'content': 'Dear students and guardians, the schedule for the upcoming First Term Examination 2026 has been published. All students are requested to clear their academic fees before the exam commences.',
        'priority': 'High Priority',
        'date': 'April 10, 2026',
        'color': const Color(0xFFDC2626),
      },
      {
        'title': 'Annual Sports Day 2026',
        'content': 'Annual sports competition will be held on the school playground next Saturday. Attendance is mandatory for all students.',
        'priority': 'General Circular',
        'date': 'April 05, 2026',
        'color': const Color(0xFF2563EB),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notices & Circulars')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final n = notices[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (n['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          n['priority'] as String,
                          style: TextStyle(color: n['color'] as Color, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                      Text(n['date'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(n['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(n['content'] as String, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
