import 'package:flutter/material.dart';
import '../sdui/models/sdui_screen_model.dart';
import '../sdui/models/sdui_component_model.dart';
import '../sdui/engine/sdui_renderer.dart';
import '../student/routine_screen.dart';
import '../student/results_screen.dart';
import '../student/fees_screen.dart';
import '../student/digital_id_card_screen.dart';
import '../notices/notices_screen.dart';
import '../teacher/attendance_marking_screen.dart';

class AppDashboardScreen extends StatefulWidget {
  final String initialRole;
  final String schoolName;
  final String schoolCode;

  const AppDashboardScreen({
    Key? key,
    this.initialRole = 'student',
    this.schoolName = 'SAS SMART SCHOOL',
    this.schoolCode = 'SAS',
  }) : super(key: key);

  @override
  State<AppDashboardScreen> createState() => _AppDashboardScreenState();
}

class _AppDashboardScreenState extends State<AppDashboardScreen> {
  int _currentNavIndex = 0;
  late String _activeRole;
  late SDUIScreenModel _screenModel;

  @override
  void initState() {
    super.initState();
    _activeRole = widget.initialRole;
    _buildRoleConfig();
  }

  void _buildRoleConfig() {
    String welcomeTitle = 'Welcome, Tahmid Rahman';
    String welcomeSub = 'Class 10 (SSC) • Roll #1';

    if (_activeRole == 'teacher') {
      welcomeTitle = 'Welcome, Kamrul Hasan';
      welcomeSub = 'Senior Assistant Teacher • Mathematics';
    } else if (_activeRole == 'parent') {
      welcomeTitle = 'Parent Portal: Monitoring Tahmid Rahman';
      welcomeSub = 'Class 10 (Section A) • Guardian View';
    }

    _screenModel = SDUIScreenModel(
      screenId: '${_activeRole}_home',
      version: 1,
      title: '${widget.schoolName} Master Dashboard',
      components: [
        SDUIComponentModel(
          id: 'comp_welcome',
          type: 'welcome_banner',
          visible: true,
          order: 1,
          title: welcomeTitle,
          subtitle: welcomeSub,
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
          title: _activeRole == 'teacher'
              ? 'Class Attendance Register (Class 10)'
              : "Today's Attendance Status",
        ),
        SDUIComponentModel(
          id: 'comp_routine',
          type: 'routine_strip',
          visible: true,
          order: 4,
          title: _activeRole == 'teacher'
              ? "Next Class: General Math (Room 301)"
              : "Today's Class Timetable",
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
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _buildRoleConfig();
    });
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return SDUIRenderer(
          screen: _screenModel,
          onRefresh: _handleRefresh,
        );
      case 1:
        return const RoutineScreen();
      case 2:
        return const ResultsScreen();
      case 3:
        return const FeesScreen();
      case 4:
        return const DigitalIdCardScreen();
      default:
        return SDUIRenderer(screen: _screenModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentNavIndex == 0
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.schoolName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  Text(
                    'Active Role: ${_activeRole.toUpperCase()} • Session 2026',
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
              actions: [
                // Quick Role Switcher Pill in App Bar
                PopupMenuButton<String>(
                  icon: const Icon(Icons.swap_horiz_rounded),
                  tooltip: 'Switch Dashboard Role Perspective',
                  onSelected: (newRole) {
                    setState(() {
                      _activeRole = newRole;
                      _buildRoleConfig();
                    });
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'student', child: Text('Switch to Student View')),
                    PopupMenuItem(value: 'parent', child: Text('Switch to Parent View')),
                    PopupMenuItem(value: 'teacher', child: Text('Switch to Teacher View')),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.badge_rounded),
                  tooltip: 'Digital Student ID',
                  onPressed: () => setState(() => _currentNavIndex = 4),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticesScreen()));
                  },
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // If teacher is active on home, show Teacher Quick Roll Call action bar
          if (_currentNavIndex == 0 && _activeRole == 'teacher')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFEFF6FF),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  const Text('Class 10 (Padma) Roll Call Pending', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1D4ED8))),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceMarkingScreen()));
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Start Roll Call', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (index) {
          setState(() => _currentNavIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
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
