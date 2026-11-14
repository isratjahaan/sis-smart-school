import 'package:flutter/material.dart';
import 'attendance_marking_screen.dart';

class TeacherDashboardScreen extends StatelessWidget {
  final String teacherName;
  final String designation;
  final String department;

  const TeacherDashboardScreen({
    Key? key,
    this.teacherName = 'Kamrul Hasan',
    this.designation = 'Senior Assistant Teacher',
    this.department = 'Mathematics',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assignedClasses = [
      {'class': 'Class 10 (Section A)', 'subject': 'General Mathematics', 'students': 45, 'room': 'Room 301', 'time': '09:00 AM'},
      {'class': 'Class 9 (Section A)', 'subject': 'Higher Mathematics', 'students': 40, 'room': 'Room 201', 'time': '10:45 AM'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(teacherName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('$designation • $department', style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Action Card: Take Attendance
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Take Daily Attendance', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Class 10 • Section A (Padma)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AttendanceMarkingScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2563EB),
                    ),
                    child: const Text('Start Roll Call'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Today's Assigned Classes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),

            ...assignedClasses.map((ac) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.class_rounded, color: Color(0xFF2563EB), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ac['class'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('${ac['subject']} • ${ac['room']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(
                      ac['time'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
