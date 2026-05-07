import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- STATE ---
  final TextEditingController _regNoController     = TextEditingController();
  final TextEditingController _passwordController  = TextEditingController();
  final ApiService            _apiService          = ApiService();

  bool    _isPasswordVisible = false;
  bool    _isLoading         = false;
  String? _errorMessage;

  // --- LOGIN ---
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    final regNo    = _regNoController.text.trim();
    final password = _passwordController.text.trim();

    if (regNo.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading    = false;
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    try {
      final data = await _apiService.login(regNo, password);

      setState(() => _isLoading = false);

      // get role from backend response
      final String role = (data['role'] as String).toLowerCase();

      // map backend roles to frontend route names
      final roleMap = {
        'patient':       'patient',
        'doctor':        'doctor',
        'nurse':         'nurse',
        'lab_attendant': 'lab',
        'admin':         'admin',
      };

      final mappedRole = roleMap[role] ?? 'patient';
      _navigateByRole(mappedRole);

    } catch (e) {
      setState(() {
        _isLoading    = false;
        _errorMessage = 'Invalid registration number or password.';
      });
    }
  }

  void _navigateByRole(String role) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainShell(role: role),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // --- LOGO ---
              Image.asset(
                'assets/images/vitaliq_logo.png',
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 5),

              // --- TITLES ---
              const Text(
                'Clinic Portal',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),

              RichText(
                text: TextSpan(
                  text: 'For IUIU Community  ',
                  style: TextStyle(
                    color: AppColors.ink3,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Main Campus',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- REGISTRATION NUMBER FIELD ---
              _buildTextField(
                controller: _regNoController,
                hint: 'Registration number',
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 12),

              // --- PASSWORD FIELD ---
              _buildTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.ink3,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),

              // --- FORGOT PASSWORD ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: navigate to forgot password / contact admin
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.ink2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Forgot Your Password ?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              // --- ERROR MESSAGE ---
              if (_errorMessage != null) ...[
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.err.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.err.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.err, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: AppColors.err, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ] else
                const SizedBox(height: 8),

              // --- LOGIN BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.accent.withValues(
                      alpha: 0.6,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // --- HELP FOOTER ---
              Text.rich(
                TextSpan(
                  text: 'Having trouble? ',
                  style: TextStyle(color: AppColors.ink3, fontSize: 13),
                  children: [
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: open help screen or contact info
                        },
                        child: const Text(
                          'Contact clinic staff',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  // --- FIELD BUILDER ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink3.withValues(alpha: 0.15)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.ink3,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: AppColors.ink3, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}









/* the below is khalids code but it uses 
a mock login system. 
 
import 'package:flutter/material.dart';
import '../theme.dart';
import 'main_shell.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- STATE ---
  // In the future, these will be sent to POST /auth/login
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  final ApiService _apiService = ApiService();

  // --- MOCK LOGIN ---
  // Each reg number maps to a role.
  // When FastAPI is ready, replace _handleLogin body with:
  // POST /auth/login → { username, password } → { access_token, role }
  final Map<String, String> _mockUsers = {
    'STU-2024-0842': 'patient',
    'STAFF-DOC-001': 'doctor',
    'STAFF-LAB-002': 'lab',
    'STAFF-NUR-003': 'nurse',
    'STAFF-ADM-001': 'admin',
  };

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulates network delay — remove when real API is connected
    await Future.delayed(const Duration(milliseconds: 1200));

    final regNo = _regNoController.text.trim();
    final password = _passwordController.text.trim();

    if (regNo.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    if (!_mockUsers.containsKey(regNo)) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Registration number not found.';
      });
      return;
    }

    final role = _mockUsers[regNo]!;
    setState(() => _isLoading = false);
    _navigateByRole(role);
  }

  void _navigateByRole(String role) {
    // Navigate to MainShell, passing the role so it can load the correct tabs.
    // pushReplacement removes LoginScreen from the stack — back button won't return to it.
    // TODO: When backend is ready, replace mock role with decoded JWT claim.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainShell(role: role),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // --- LOGO ---
              Image.asset(
                'assets/images/vitaliq_logo.png',
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 5),

              // --- TITLES ---
              const Text(
                'Clinic Portal',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),

              // "For IUIU Community · Main Campus"
              RichText(
                text: TextSpan(
                  text: 'For IUIU Community  ',
                  style: TextStyle(
                    color: AppColors.ink3,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Main Campus',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- REGISTRATION NUMBER FIELD ---
              _buildTextField(
                controller: _regNoController,
                hint: 'Registration number',
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 12),

              // --- PASSWORD FIELD ---
              _buildTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.ink3,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),

              // --- FORGOT PASSWORD ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: navigate to forgot password / contact admin
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.ink2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Forgot Your Password ?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              // --- ERROR MESSAGE ---
              if (_errorMessage != null) ...[
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.err.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.err.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.err, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: AppColors.err, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ] else
                const SizedBox(height: 8),

              // --- LOGIN BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.accent.withValues(
                      alpha: 0.6,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // --- HELP FOOTER ---
              Text.rich(
                TextSpan(
                  text: 'Having trouble? ',
                  style: TextStyle(color: AppColors.ink3, fontSize: 13),
                  children: [
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: open help screen or contact info
                        },
                        child: const Text(
                          'Contact clinic staff',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  // --- FIELD BUILDER ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink3.withValues(alpha: 0.15)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.ink3,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: AppColors.ink3, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}*/
