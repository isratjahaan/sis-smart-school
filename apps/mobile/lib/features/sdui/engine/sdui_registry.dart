import 'package:flutter/material.dart';
import '../models/sdui_component_model.dart';
import '../widgets/welcome_banner_widget.dart';
import '../widgets/attendance_card_widget.dart';
import '../widgets/routine_strip_widget.dart';
import '../widgets/result_card_widget.dart';
import '../widgets/fee_summary_widget.dart';
import '../widgets/notice_list_widget.dart';
import '../widgets/quick_actions_widget.dart';

typedef SDUIWidgetBuilder = Widget Function(SDUIComponentModel config);

class SDUIRegistry {
  static final Map<String, SDUIWidgetBuilder> _registry = {
    'welcome_banner': (config) => WelcomeBannerWidget(config: config),
    'attendance_card': (config) => AttendanceCardWidget(config: config),
    'routine_strip': (config) => RoutineStripWidget(config: config),
    'result_card': (config) => ResultCardWidget(config: config),
    'fee_summary_card': (config) => FeeSummaryWidget(config: config),
    'notice_list': (config) => NoticeListWidget(config: config),
    'quick_actions': (config) => QuickActionsWidget(config: config),
  };

  static Widget buildComponent(SDUIComponentModel config) {
    if (!config.visible) return const SizedBox.shrink();

    final builder = _registry[config.type];
    if (builder != null) {
      return builder(config);
    }

    // Safe fallback for unknown components (No crashes)
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Component [${config.type}] is not yet supported in this app version.',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ),
    );
  }
}
