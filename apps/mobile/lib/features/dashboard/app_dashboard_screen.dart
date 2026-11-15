import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
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

  // Real-time Anti-theft & Live Sync State
  bool _isDeviceLocked = false;
  String _lockMessage = 'This device has been reported Stolen/Lost to SAS Smart School authority.';
  String _emergencyPhone = '+8801711223344';
  RealtimeChannel? _realtimeChannel;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _activeRole = widget.initialRole;
    _buildRoleConfig();
    _fetchRemoteConfig();
    _subscribeToRealtime();
    _syncTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) _fetchRemoteConfig();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _fetchRemoteConfig() async {
    final client = SupabaseService.client;
    if (client == null) return;
    try {
      // 1. Check Anti-Theft Security State
      final secRes = await client
          .from('configuration_versions')
          .select('payload')
          .eq('screen_id', 'device_security')
          .order('version', ascending: false)
          .limit(1)
          .maybeSingle();

      if (secRes != null && secRes['payload'] != null) {
        final sec = Map<String, dynamic>.from(secRes['payload'] as Map);
        if (mounted) {
          setState(() {
            _isDeviceLocked = sec['is_locked'] == true;
            if (sec['lock_message'] != null) _lockMessage = sec['lock_message'].toString();
            if (sec['emergency_phone'] != null) _emergencyPhone = sec['emergency_phone'].toString();
          });
        }
      }

      // 2. Fetch Live Server-Driven UI Dashboard Layout
      final layoutRes = await client
          .from('configuration_versions')
          .select('payload')
          .eq('screen_id', 'student_home')
          .eq('is_published', true)
          .order('version', ascending: false)
          .limit(1)
          .maybeSingle();

      if (layoutRes != null && layoutRes['payload'] != null) {
        final payload = Map<String, dynamic>.from(layoutRes['payload'] as Map);
        if (mounted) {
          setState(() {
            _screenModel = SDUIScreenModel.fromJson(payload);
          });
        }
      }
    } catch (_) {
      // Keep local configuration safely
    }
  }

  void _subscribeToRealtime() {
    final client = SupabaseService.client;
    if (client == null) return;
    try {
      _realtimeChannel = client
          .channel('public:configuration_versions')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'configuration_versions',
            callback: (payload) {
              _fetchRemoteConfig();
            },
          )
          .subscribe();
    } catch (_) {}
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
    if (_isDeviceLocked) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: const Color(0xFF7F1D1D),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 96,
                    width: 96,
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.shade400, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.shield_rounded, size: 52, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'DEVICE REMOTELY LOCKED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'SAS SMART SCHOOL SECURITY ENFORCEMENT',
                    style: TextStyle(
                      color: Color(0xFFFCA5A5),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade700),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _lockMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 12),
                        const Text(
                          'PLEASE RETURN THIS DEVICE TO:',
                          style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'SAS Smart School Admin Office',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade600),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                _emergencyPhone,
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, color: Colors.white54, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Session terminated & sensitive data encrypted.',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
