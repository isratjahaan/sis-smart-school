import 'package:flutter/material.dart';

class AttendanceMarkingScreen extends StatefulWidget {
  const AttendanceMarkingScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  final students = [
    {'id': '1', 'roll': 1, 'idNumber': 'DMS-2026-001', 'name': 'Tahmid Rahman', 'status': 'present'},
    {'id': '2', 'roll': 2, 'idNumber': 'DMS-2026-002', 'name': 'Samia Chowdhury', 'status': 'present'},
    {'id': '3', 'roll': 3, 'idNumber': 'DMS-2026-003', 'name': 'Nafis Iqbal', 'status': 'absent'},
  ];

  void _setStatus(int index, String status) {
    setState(() {
      students[index]['status'] = status;
    });
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance submitted and synchronized with central Supabase backend!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = students.where((s) => s['status'] == 'present').length;
    final absentCount = students.where((s) => s['status'] == 'absent').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance — Class 10 (Padma)'),
      ),
      body: Column(
        children: [
          // Summary Counter Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF1F5F9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ${students.length} Students', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Row(
                  children: [
                    Text('Present: $presentCount', style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 12),
                    Text('Absent: $absentCount', style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // Students Attendance List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final s = students[index];
                final status = s['status'] as String;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                          child: Text(
                            '#${s['roll']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(s['idNumber'] as String, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _setStatus(index, 'present'),
                              icon: Icon(
                                Icons.check_circle_rounded,
                                color: status == 'present' ? const Color(0xFF16A34A) : Colors.grey.shade300,
                                size: 28,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _setStatus(index, 'absent'),
                              icon: Icon(
                                Icons.cancel_rounded,
                                color: status == 'absent' ? const Color(0xFFDC2626) : Colors.grey.shade300,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Submit Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                child: const Text('Save & Submit Roll Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
