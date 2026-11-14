import 'package:flutter/material.dart';
import '../models/sdui_component_model.dart';

class QuickActionsWidget extends StatelessWidget {
  final SDUIComponentModel config;

  const QuickActionsWidget({Key? key, required this.config}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'title': 'Routine', 'icon': Icons.calendar_month_rounded, 'color': const Color(0xFF2563EB)},
      {'title': 'Results', 'icon': Icons.emoji_events_rounded, 'color': const Color(0xFF7C3AED)},
      {'title': 'Fees', 'icon': Icons.account_balance_wallet_rounded, 'color': const Color(0xFF059669)},
      {'title': 'ID Card', 'icon': Icons.badge_rounded, 'color': const Color(0xFFD97706)},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: actions.map((act) {
            final color = act['color'] as Color;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(act['icon'] as IconData, color: color, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  act['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
