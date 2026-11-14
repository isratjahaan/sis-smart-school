import 'package:flutter/material.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final schedule = [
      {
        'day': 'Sunday',
        'periods': [
          {'time': '09:00 - 09:45 AM', 'subject': 'General Mathematics', 'teacher': 'Kamrul Hasan', 'room': 'Room 301'},
          {'time': '09:45 - 10:30 AM', 'subject': 'English 1st Paper', 'teacher': 'Farhana Akter', 'room': 'Room 301'},
          {'time': '10:45 - 11:30 AM', 'subject': 'Information & Comm. Tech (ICT)', 'teacher': 'Shahidul Alam', 'room': 'Computer Lab 1'},
          {'time': '11:30 - 12:15 PM', 'subject': 'General Science', 'teacher': 'Kamrul Hasan', 'room': 'Science Lab 2'},
        ],
      },
      {
        'day': 'Monday',
        'periods': [
          {'time': '09:00 - 09:45 AM', 'subject': 'Bangla 1st Paper', 'teacher': 'Farhana Akter', 'room': 'Room 301'},
          {'time': '09:45 - 10:30 AM', 'subject': 'General Mathematics', 'teacher': 'Kamrul Hasan', 'room': 'Room 301'},
          {'time': '10:45 - 11:30 AM', 'subject': 'General Science', 'teacher': 'Kamrul Hasan', 'room': 'Science Lab 2'},
          {'time': '11:30 - 12:15 PM', 'subject': 'Bangladesh & Global Studies', 'teacher': 'Farhana Akter', 'room': 'Room 301'},
        ],
      },
      {
        'day': 'Tuesday',
        'periods': [
          {'time': '09:00 - 09:45 AM', 'subject': 'English 1st Paper', 'teacher': 'Farhana Akter', 'room': 'Room 301'},
          {'time': '09:45 - 10:30 AM', 'subject': 'Bangla 1st Paper', 'teacher': 'Kamrul Hasan', 'room': 'Room 301'},
          {'time': '10:45 - 11:30 AM', 'subject': 'General Mathematics', 'teacher': 'Kamrul Hasan', 'room': 'Room 301'},
          {'time': '11:30 - 12:15 PM', 'subject': 'ICT Practical', 'teacher': 'Shahidul Alam', 'room': 'Computer Lab 1'},
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Timetable Routine'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedule.length,
        itemBuilder: (context, dayIndex) {
          final dayData = schedule[dayIndex];
          final dayName = dayData['day'] as String;
          final periods = dayData['periods'] as List<Map<String, String>>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dayName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              ...periods.map((p) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p['time']!,
                          style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['subject']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Teacher: ${p['teacher']} • ${p['room']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
