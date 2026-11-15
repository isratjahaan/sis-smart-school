import 'package:flutter/material.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({Key? key}) : super(key: key);

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  final invoices = [
    {
      'number': 'INV-SAS-2026-0001',
      'title': 'January 2026 Tuition Fee',
      'amount': '৳2,500',
      'due': '৳0',
      'status': 'paid',
      'date': 'Paid on Jan 12, 2026',
    },
    {
      'number': 'INV-SAS-2026-0002',
      'title': 'February 2026 Tuition Fee',
      'amount': '৳2,500',
      'due': '৳2,500',
      'status': 'unpaid',
      'date': 'Due Date: Feb 15, 2026',
    },
  ];

  void _showPaymentModal(BuildContext context) {
    final trxController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Clear Tuition Fee via bKash', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFCE7F3), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.phone_android_rounded, color: Color(0xFFBE185D)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('bKash Merchant Account:', style: TextStyle(fontSize: 11, color: Color(0xFF831843))),
                        Text('01711223344', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF831843), fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Enter bKash Transaction ID (TrxID):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: trxController,
              decoration: InputDecoration(
                hintText: 'e.g. 9JH3KA19',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment submitted for automated verification!')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBE185D)),
                child: const Text('Confirm bKash Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fee Invoices & Payments')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Due Amount Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Outstanding Tuition Due', style: TextStyle(color: Color(0xFF991B1B), fontSize: 12, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('৳2,500', style: TextStyle(color: Color(0xFFDC2626), fontSize: 24, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _showPaymentModal(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                    child: const Text('Pay Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Academic Invoices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),

            ...invoices.map((inv) {
              final isPaid = inv['status'] == 'paid';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(inv['number']!, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPaid ? 'PAID' : 'UNPAID',
                              style: TextStyle(
                                color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(inv['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(inv['date']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(inv['amount']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
