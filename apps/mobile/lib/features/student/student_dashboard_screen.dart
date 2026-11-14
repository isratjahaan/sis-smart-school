import 'package:flutter/material.dart';
import '../sdui/models/sdui_screen_model.dart';
import '../sdui/models/sdui_component_model.dart';
import '../sdui/engine/sdui_renderer.dart';
import '../../core/storage/offline_cache_manager.dart';
import 'digital_id_card_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentNavIndex = 0;
  late SDUIScreenModel _screenModel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadScreenConfig();
  }

  void _loadScreenConfig() {
    // Standard baseline configuration loaded from local cache / remote
    _screenModel = SDUIScreenModel(
      screenId: 'student_home',
      version: 1,
      title: 'Dhaka Model School Student Portal',
      components: [
        SDUIComponentModel(
          id: 'comp_welcome',
          type: 'welcome_banner',
          visible: true,
          order: 1,
          title: 'Welcome, Tahmid Rahman',
          subtitle: 'Class 10 (SSC) • Roll #1',
        ),
        SDUIComponentModel(
          id: 'comp_quick_actions',
          type: 'quick_actions',
          visible: true,
          order: 2,
        ),
        SDUIComponentModel(
          id: 'comp_attendance',
          type: 'attendance_card',
          visible: true,
          order: 3,
          title: "Today's Attendance Status",
        ),
        SDUIComponentModel(
          id: 'comp_routine',
          type: 'routine_strip',
          visible: true,
          order: 4,
          title: "Today's Class Timetable",
        ),
        SDUIComponentModel(
          id: 'comp_result',
          type: 'result_card',
          visible: true,
          order: 5,
          title: 'First Term Examination 2026',
        ),
        SDUIComponentModel(
          id: 'comp_fees',
          type: 'fee_summary_card',
          visible: true,
          order: 6,
          title: 'Monthly Tuition Fee Due',
        ),
        SDUIComponentModel(
          id: 'comp_notices',
          type: 'notice_list',
          visible: true,
          order: 7,
          title: 'School Circulars & Notices',
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    _loadScreenConfig();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DHAKA MODEL SCHOOL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Tahmid Rahman • Class 10', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.badge_rounded),
            tooltip: 'Digital ID Card',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DigitalIdCardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SDUIRenderer(
        screen: _screenModel,
        onRefresh: _handleRefresh,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (index) {
          setState(() => _currentNavIndex = index);
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DigitalIdCardScreen()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Routine',
          ),
          NavigationDestination(
            icon: Icon(Icons.military_tech_outlined),
            selectedIcon: Icon(Icons.military_tech_rounded),
            label: 'Results',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Fees',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge_rounded),
            label: 'ID Card',
          ),
        ],
      ),
    );
  }
}
