import 'package:flutter/material.dart';
import 'package:frontend/screens/lab_results_screen.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'my_health_screen.dart';
import 'prescriptions_screen.dart';
import 'doctor_queue_screen.dart';
import 'lab_tech_screen.dart';

// ---------------------------------------------------------------------------
// Tab configuration — easy to extend per role later
// ---------------------------------------------------------------------------

class _TabItem {
  final String label;
  final IconData icon;
  final Widget screen;
  final bool showTopBar; // HomeScreen has its own hero — no topbar needed

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
    showTopBar: false, // hero header handles its own chrome
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
    icon: Icons.search_off_rounded,
    screen: LabResultsScreen(),
  ),
];

const _doctorTabs = [
  _TabItem(
    label: 'Queue',
    icon: Icons.format_list_bulleted_rounded,
    screen: DoctorQueueScreen(),
  ),
  // TODO: add DoctorLabScreen() when built
  // _TabItem(
  //   label: 'Lab',
  //   icon: Icons.biotech_rounded,
  //   screen: DoctorLabScreen(),
  // ),
  // TODO: add ChatScreen() when built
  // _TabItem(
  //   label: 'Chat',
  //   icon: Icons.chat_bubble_outline_rounded,
  //   screen: ChatScreen(),
  // ),
];

// TODO: populate when screens are built
const _labTabs = [
  _TabItem(label: 'Lab', icon: Icons.biotech_rounded, screen: LabTechScreen()),
  // TODO: add ChatScreen() when built
  // _TabItem(
  //   label: 'Chat',
  //   icon: Icons.chat_bubble_outline_rounded,
  //   screen: ChatScreen(),
  // ),
];
// const _pharmacyTabs = [ ... ];
// const _adminTabs = [ ... ];

// ---------------------------------------------------------------------------
// Shell
// ---------------------------------------------------------------------------

class MainShell extends StatefulWidget {
  // Role passed from LoginScreen after successful auth.
  // Used to select the correct tab set for this user type.
  // Backend: decoded from JWT claim 'role' → 'patient' | 'doctor' | 'lab' | 'pharmacy' | 'admin'
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
      // Remaining roles fall back to patient tabs until their screens are built.
      // Uncomment each case as staff screens are added:
      case 'lab':
        _tabs = _labTabs;
        break;
      // case 'pharmacy': _tabs = _pharmacyTabs; break;
      // case 'admin':    _tabs = _adminTabs;    break;
      default:
        _tabs = _patientTabs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tab = _tabs[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        // HomeScreen hero intentionally bleeds to top — handled internally
        // with its own padding: fromLTRB(20, 60, 20, 30)
        child: Column(
          children: [
            // ── Topbar (hidden on Home) ──────────────────────────────────
            if (tab.showTopBar) _TopBar(title: tab.label),

            // ── Screen content ───────────────────────────────────────────
            Expanded(child: tab.screen),
          ],
        ),
      ),

      // ── Bottom nav ────────────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(
        tabs: _tabs,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Topbar widget — matches HTML .topbar exactly
// hamburger | centered title | notification bell
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E4EB))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Hamburger
          _IconBtn(
            onTap: () {
              // TODO: open drawer / side menu
            },
            child: const Icon(
              Icons.menu_rounded,
              size: 20,
              color: Color(0xFF44556A),
            ),
          ),

          // Centered title
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF151E2B),
              ),
            ),
          ),

          // Notification bell with red dot
          _IconBtn(
            onTap: () {
              // TODO: open notifications sheet
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  size: 22,
                  color: Color(0xFF44556A),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB81C24),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
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
          border: Border.all(color: const Color(0xFFE0E4EB)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom nav widget — matches HTML .tabs exactly
// active tab: accent colour + top pip indicator
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  final List<_TabItem> tabs;
  final int currentIndex;
  final void Function(int) onTap;

  const _BottomNav({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E4EB))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top:
            false, // only pad bottom (home indicator on iPhone / gesture bar on Android)
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final isActive = i == currentIndex;
              final tab = tabs[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top pip — active indicator matching HTML .tab-pip
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
          ),
        ),
      ),
    );
  }
}
