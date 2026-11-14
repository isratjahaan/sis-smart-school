import 'package:flutter/material.dart';

class DigitalIdCardScreen extends StatelessWidget {
  final String studentName;
  final String studentIdNumber;
  final String className;
  final int rollNumber;
  final String bloodGroup;
  final String schoolName;

  const DigitalIdCardScreen({
    Key? key,
    this.studentName = 'Tahmid Rahman',
    this.studentIdNumber = 'SAS-2026-001',
    this.className = 'Class 10 (Padma)',
    this.rollNumber = 1,
    this.bloodGroup = 'B+',
    this.schoolName = 'SAS SMART SCHOOL',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Student ID'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Card Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.school_rounded, color: Colors.white, size: 36),
                          const SizedBox(height: 6),
                          Text(
                            schoolName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Text(
                            'STUDENT IDENTIFICATION CARD',
                            style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    // Photo & Details
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF2563EB), width: 3),
                              color: const Color(0xFFEFF6FF),
                            ),
                            child: const Center(
                              child: Text(
                                'TR',
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            studentName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            studentIdNumber,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 10),

                          _buildInfoRow('Class / Section', className),
                          const SizedBox(height: 8),
                          _buildInfoRow('Roll Number', '#$rollNumber'),
                          const SizedBox(height: 8),
                          _buildInfoRow('Blood Group', bloodGroup),
                          const SizedBox(height: 8),
                          _buildInfoRow('Session', '2026 (Valid until Dec 2026)'),

                          const SizedBox(height: 20),
                          // Simulated Barcode
                          Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                32,
                                (index) => Container(
                                  width: index % 3 == 0 ? 3 : (index % 2 == 0 ? 1 : 2),
                                  height: 26,
                                  color: Colors.black87,
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.between,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
