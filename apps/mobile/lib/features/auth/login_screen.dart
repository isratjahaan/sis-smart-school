import 'package:flutter/material.dart';
import '../dashboard/app_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedSchool = 'dhaka-model';
  String _selectedRole = 'student';
  final _idController = TextEditingController(text: 'SAS-2026-001');
  final _passwordController = TextEditingController(text: '••••••••');
  bool _isLoading = false;

  void _handleLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() => _isLoading = false);
      final schoolName = _selectedSchool == 'dhaka-model'
          ? 'SAS SMART SCHOOL'
          : 'CHITTAGONG GRAMMAR SCHOOL';
      final schoolCode = _selectedSchool == 'dhaka-model' ? 'SAS' : 'CGS';

      // Route directly into the ONE master unified App Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AppDashboardScreen(
            initialRole: _selectedRole,
            schoolName: schoolName,
            schoolCode: schoolCode,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand Icon
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'SIS',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SIS SMART SCHOOL',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const Text(
                  'Unified Mobile Portal Authentication',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),

                const SizedBox(height: 32),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // School Selector
                      const Text('Select Your School', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSchool,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF0F172A),
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            items: const [
                              DropdownMenuItem(value: 'dhaka-model', child: Text('SAS Smart School (DMS)')),
                              DropdownMenuItem(value: 'cgs-ctg', child: Text('Chittagong Grammar School (CGS)')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedSchool = val);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Role Switcher Chips
                      const Text('Role Perspective', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildRoleChip('student', 'Student'),
                          const SizedBox(width: 8),
                          _buildRoleChip('parent', 'Parent'),
                          const SizedBox(width: 8),
                          _buildRoleChip('teacher', 'Teacher'),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ID Field
                      const Text('Institutional ID / Email', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _idController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.white60, size: 20),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      const Text('Password', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white60, size: 20),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Open Unified Dashboard', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role, String label) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
            if (role == 'student') {
              _idController.text = 'SAS-2026-001';
            } else if (role == 'parent') {
              _idController.text = 'parent@dhakamodel.edu.bd';
            } else {
              _idController.text = 'kamrul.hasan@dhakamodel.edu.bd';
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
