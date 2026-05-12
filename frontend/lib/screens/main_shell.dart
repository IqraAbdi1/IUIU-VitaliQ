import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/screens/lab_results_screen.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'my_health_screen.dart';
import 'prescriptions_screen.dart';
import 'doctor_queue_screen.dart';
import 'lab_tech_screen.dart';
import 'admin_screen.dart';
import 'notifications_screen.dart';
import 'nurse_screen.dart';
import 'staff_home_screen.dart';

// ---------------------------------------------------------------------------
// Breakpoint
// ---------------------------------------------------------------------------

const _kDesktopBreakpoint = 600.0;

/// Max width of the scrollable content area on desktop.
/// Cards stop stretching beyond this — right side gets the image panel.
const _kContentMaxWidth = 960.0;

/// Width of the right-side image panel (desktop only).
const _kImagePanelWidth = 500.0;

// ---------------------------------------------------------------------------
// Campus image assets — add your files to assets/images/ and list them here.
// The slider will cycle through them automatically.
// ---------------------------------------------------------------------------
const _campusImages = [
  'assets/images/campus_1.jpg',
  'assets/images/campus_2.jpg',
  'assets/images/campus_3.jpg',
  'assets/images/campus_4.jpg',
  'assets/images/campus_5.jpg',
  'assets/images/campus_6.jpg',
  'assets/images/campus_7.jpg',
  // add more as needed
];

// ---------------------------------------------------------------------------
// Tab configuration
// ---------------------------------------------------------------------------

class _TabItem {
  final String label;
  final IconData icon;
  final Widget screen;
  final bool showTopBar;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.screen,
    this.showTopBar = true,
  });
}

const _patientTabs = [
  _TabItem(
    label: 'Home',
    icon: Icons.home_rounded,
    screen: HomeScreen(),
    showTopBar: false,
  ),
  _TabItem(
    label: 'My Health',
    icon: Icons.monitor_heart_rounded,
    screen: MyHealthScreen(),
  ),
  _TabItem(
    label: 'Prescriptions',
    icon: Icons.medication_rounded,
    screen: PrescriptionsScreen(),
  ),
  _TabItem(
    label: 'Lab',
    icon: Icons.biotech_rounded,
    screen: LabResultsScreen(),
  ),
];

const _doctorTabs = [
  _TabItem(
    label: 'Home',
    icon: Icons.home_rounded,
    screen: StaffHomeScreen(role: 'doctor', staffName: 'Dr. Staff'),
    showTopBar: false,
  ),
  _TabItem(
    label: 'Queue',
    icon: Icons.format_list_bulleted_rounded,
    screen: DoctorQueueScreen(),
  ),
];

const _labTabs = [
  _TabItem(
    label: 'Home',
    icon: Icons.home_rounded,
    screen: StaffHomeScreen(role: 'lab', staffName: 'Lab Staff'),
    showTopBar: false,
  ),
  _TabItem(label: 'Lab', icon: Icons.biotech_rounded, screen: LabTechScreen()),
];

const _nurseTabs = [
  _TabItem(
    label: 'Home',
    icon: Icons.home_rounded,
    screen: StaffHomeScreen(role: 'nurse', staffName: 'Nurse Staff'),
    showTopBar: false,
  ),
  _TabItem(
    label: 'Station',
    icon: Icons.medical_services_rounded,
    screen: NurseScreen(canDispense: true),
  ),
];

const _adminTabs = [
  _TabItem(
    label: 'Home',
    icon: Icons.home_rounded,
    screen: StaffHomeScreen(role: 'admin', staffName: 'Admin'),
    showTopBar: false,
  ),
  _TabItem(
    label: 'Overview',
    icon: Icons.bar_chart_rounded,
    screen: AdminScreen(),
  ),
];

// ---------------------------------------------------------------------------
// Shell
// ---------------------------------------------------------------------------

class MainShell extends StatefulWidget {
  final String role;
  const MainShell({super.key, this.role = 'patient'});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final List<_TabItem> _tabs;

  @override
  void initState() {
    super.initState();
    switch (widget.role) {
      case 'doctor':
        _tabs = _doctorTabs;
        break;
      case 'lab':
        _tabs = _labTabs;
        break;
      case 'nurse':
        _tabs = _nurseTabs;
        break;
      case 'admin':
        _tabs = _adminTabs;
        break;
      default:
        _tabs = _patientTabs;
    }
  }

  void _onTabTap(int i) => setState(() => _currentIndex = i);

  void _logout() {
    // TODO: clear JWT token
    Navigator.of(context).pushReplacementNamed('/login');
  }

  /// Shows the menu as a centered floating dialog on both mobile and desktop.
  /// This looks correct on all window sizes — no more mid-screen bottom sheet.
  void _openMenu() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _AppMenuDialog(
        role: widget.role,
        onSwitchToPatient: () {
          Navigator.pop(context);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShell(role: 'patient')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;
    final tab = _tabs[_currentIndex];

    return isDesktop
        ? _DesktopLayout(
            tabs: _tabs,
            currentIndex: _currentIndex,
            onTap: _onTabTap,
            tab: tab,
            onLogout: _logout,
            onBellTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            onMenuTap: _openMenu,
          )
        : _MobileLayout(
            tabs: _tabs,
            currentIndex: _currentIndex,
            onTap: _onTabTap,
            tab: tab,
            onLogout: _logout,
            onMenuTap: _openMenu,
          );
  }
}

// ---------------------------------------------------------------------------
// Mobile layout
// ---------------------------------------------------------------------------

class _MobileLayout extends StatelessWidget {
  final List<_TabItem> tabs;
  final int currentIndex;
  final void Function(int) onTap;
  final _TabItem tab;
  final VoidCallback onLogout;
  final VoidCallback onMenuTap;

  const _MobileLayout({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    required this.tab,
    required this.onLogout,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            if (tab.showTopBar) _TopBar(title: tab.label, onLogout: onLogout),
            Expanded(child: tab.screen),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        tabs: tabs,
        currentIndex: currentIndex,
        onTap: onTap,
        onMenuTap: onMenuTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop layout
// ---------------------------------------------------------------------------

class _DesktopLayout extends StatelessWidget {
  final List<_TabItem> tabs;
  final int currentIndex;
  final void Function(int) onTap;
  final _TabItem tab;
  final VoidCallback onLogout;
  final VoidCallback onBellTap;
  final VoidCallback onMenuTap;

  const _DesktopLayout({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    required this.tab,
    required this.onLogout,
    required this.onBellTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Row(
          children: [
            // ── Side rail ──────────────────────────────────
            _SideRail(
              tabs: tabs,
              currentIndex: currentIndex,
              onTap: onTap,
              onLogout: onLogout,
              onBellTap: onBellTap,
              onMenuTap: onMenuTap,
            ),

            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.border,
            ),

            // ── Main content — capped at _kContentMaxWidth ─
            Expanded(
              child: Column(
                children: [
                  _TopBar(title: tab.label),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _kContentMaxWidth,
                        ),
                        child: tab.screen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Right image panel ──────────────────────────
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.border,
            ),
            const _CampusImagePanel(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Right-side campus image panel
// Clips from the top as the window shrinks vertically.
// The bottom of the image is always anchored.
// ---------------------------------------------------------------------------

class _CampusImagePanel extends StatefulWidget {
  const _CampusImagePanel();

  @override
  State<_CampusImagePanel> createState() => _CampusImagePanelState();
}

class _CampusImagePanelState extends State<_CampusImagePanel> {
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Auto-advance every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        _current = (_current + 1) % _campusImages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kImagePanelWidth,
      // ClipRect ensures the image is clipped by the container bounds.
      // Align.bottomCenter keeps the bottom anchored — top clips away
      // naturally as the window height is reduced.
      child: ClipRect(
        child: Stack(
          children: [
            // Crossfade between images
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: Align(
                key: ValueKey(_current),
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  _campusImages[_current],
                  width: _kImagePanelWidth,
                  // Use a very tall height so the image always fills
                  // the panel regardless of window height.
                  height: 2000,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),

            // Subtle gradient overlay at the top — softens the clip edge
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.bg, AppColors.bg.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),

            // Dot indicators at bottom
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_campusImages.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _current ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _current
                          ? AppColors.accent
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Side rail
// ---------------------------------------------------------------------------

class _SideRail extends StatelessWidget {
  final List<_TabItem> tabs;
  final int currentIndex;
  final void Function(int) onTap;
  final VoidCallback onLogout;
  final VoidCallback onBellTap;
  final VoidCallback onMenuTap;

  const _SideRail({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    required this.onLogout,
    required this.onBellTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Image.asset(
            'assets/images/vitaliq_logo_no_text.png',
            width: 86,
            height: 86,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 12),
          ...List.generate(tabs.length, (i) {
            final isActive = i == currentIndex;
            final tab = tabs[i];
            return _RailItem(
              icon: tab.icon,
              label: tab.label,
              isActive: isActive,
              onTap: () => onTap(i),
            );
          }),
          const Spacer(),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 8),
          _RailItem(
            icon: Icons.notifications_outlined,
            label: 'Alerts',
            isActive: false,
            onTap: onBellTap,
          ),
          _RailItem(
            icon: Icons.menu_rounded,
            label: 'Menu',
            isActive: false,
            onTap: onMenuTap,
          ),
          _RailItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            isActive: false,
            onTap: onLogout,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentLight : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? AppColors.accent : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.accent : AppColors.ink3,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.accent : AppColors.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Topbar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onLogout;
  const _TopBar({required this.title, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          if (onLogout != null)
            _IconBtn(
              onTap: onLogout!,
              child: const Icon(
                Icons.logout_rounded,
                size: 20,
                color: AppColors.ink2,
              ),
            ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
          if (MediaQuery.of(context).size.width < 600)
            _IconBtn(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    size: 22,
                    color: AppColors.ink2,
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.err,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _IconBtn({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom nav (mobile only)
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  final List<_TabItem> tabs;
  final int currentIndex;
  final void Function(int) onTap;
  final VoidCallback onMenuTap;

  const _BottomNav({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              ...List.generate(tabs.length, (i) {
                final isActive = i == currentIndex;
                final tab = tabs[i];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: isActive ? 22 : 0,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(3),
                            ),
                          ),
                        ),
                        Icon(
                          tab.icon,
                          size: 22,
                          color: isActive ? AppColors.accent : AppColors.ink3,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isActive ? AppColors.accent : AppColors.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Expanded(
                child: GestureDetector(
                  onTap: onMenuTap,
                  behavior: HitTestBehavior.opaque,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 9),
                      Icon(Icons.menu_rounded, size: 22, color: AppColors.ink3),
                      SizedBox(height: 3),
                      Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App Menu — centered floating dialog (works on mobile + desktop)
// Replaces the old bottom sheet that looked broken on desktop.
// ---------------------------------------------------------------------------

class _AppMenuDialog extends StatelessWidget {
  final String role;
  final VoidCallback onSwitchToPatient;

  const _AppMenuDialog({required this.role, required this.onSwitchToPatient});

  bool get _isStaff =>
      role == 'doctor' || role == 'nurse' || role == 'lab' || role == 'admin';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      // Remove default dialog padding/insets
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
                  child: Row(
                    children: [
                      const Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.ink2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border, height: 1),
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  label: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: navigate to ProfileScreen
                  },
                ),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About VitalIQ',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: navigate to AboutScreen
                  },
                ),
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: navigate to HelpScreen
                  },
                ),
                if (_isStaff) ...[
                  const Divider(color: AppColors.border, height: 1),
                  _MenuItem(
                    icon: Icons.switch_account_rounded,
                    label: 'Switch to Patient View',
                    valueColor: AppColors.accent,
                    onTap: onSwitchToPatient,
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? valueColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = valueColor ?? AppColors.ink;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}
