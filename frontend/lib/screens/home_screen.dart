import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';
import '../services/api_service.dart';
import 'symptom_submission_sheet.dart';
import 'queue_submission_screen.dart';
import 'notifications_screen.dart';
import 'patient_profile_screen.dart';

// =============================================================================
// MODELS
// =============================================================================

/// A single prescription reminder for today's schedule.
/// Backend: GET /api/v1/prescriptions/active?patient_id={id}
class PrescriptionReminder {
  final String time;
  final String medicineName;
  final String dose;
  bool isDone;

  PrescriptionReminder({
    required this.time,
    required this.medicineName,
    required this.dose,
    this.isDone = false,
  });
}

/// A medicine's current stock availability shown on the home screen.
/// Backend: GET /api/v1/medicines
class MedicineAvailability {
  final String name;
  final AppStatus status; // drives chip color — no hardcoding

  const MedicineAvailability({required this.name, required this.status});
}

/// Top-level home screen data — everything that will come from the API.
/// Backend: GET /api/v1/queue/stats?patient_id={id}
class HomeData {
  final String userName;
  final int queuePosition;
  final int estimatedWaitMinutes;
  final bool isDoctorAvailable;
  final bool hasNewNotifications;
  final String healthAdvisoryTitle;

  const HomeData({
    required this.userName,
    required this.queuePosition,
    required this.estimatedWaitMinutes,
    required this.isDoctorAvailable,
    required this.hasNewNotifications,
    required this.healthAdvisoryTitle,
  });
}

// =============================================================================
// MOCK DATA
// =============================================================================

// TODO: replace with GET /api/v1/queue/stats?patient_id={id}
const _mockHomeData = HomeData(
  userName: 'Khalid Gurashi',
  queuePosition: 0,
  estimatedWaitMinutes: 0,
  isDoctorAvailable: false,
  hasNewNotifications: false,
  healthAdvisoryTitle: 'Rainy Season Health Advisory',
);

// TODO: replace with GET /api/v1/prescriptions/active?patient_id={id}
final List<PrescriptionReminder> _mockReminders = [
  PrescriptionReminder(
    time: '08:00',
    medicineName: 'Artemether-Lumefantrine',
    dose: '2 tablets · with food',
    isDone: true,
  ),
  PrescriptionReminder(
    time: '14:00',
    medicineName: 'Paracetamol 500mg',
    dose: '1 tablet · if fever',
  ),
  PrescriptionReminder(
    time: '20:00',
    medicineName: 'Artemether-Lumefantrine',
    dose: '2 tablets · with food',
  ),
];

// TODO: replace with GET /api/v1/medicines
const List<MedicineAvailability> _mockMedicines = [
  MedicineAvailability(name: 'Paracetamol 500mg', status: AppStatus.ok),
  MedicineAvailability(name: 'Amoxicillin 500mg', status: AppStatus.warn),
  MedicineAvailability(name: 'Cetirizine 10mg', status: AppStatus.ok),
  MedicineAvailability(name: 'Ibuprofen 400mg', status: AppStatus.err),
];

// =============================================================================
// SCREEN
// =============================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: load from GET /api/v1/queue/stats?patient_id={id}
  late HomeData _data = _mockHomeData;

  // TODO: load from GET /api/v1/prescriptions/active?patient_id={id}
  late List<PrescriptionReminder> _reminders = _mockReminders;

  // TODO: load from GET /api/v1/medicines
  final List<MedicineAvailability> _medicines = _mockMedicines;

  bool _isPatientInQueue = false;
  bool _showHealthAdvisory = true;

  // TODO: derive from GET /api/v1/queue/stats?patient_id={id}
  int get _queuePosition => _data.queuePosition;
  int get _estimatedWait => _data.estimatedWaitMinutes;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  // ── load real data from backend ──
  // only shows queue position if patient has actually checked in (currentVisitId != null)
  // falls back to mock data if API fails or user not yet in queue
  Future<void> _loadHomeData() async {
    try {
      await ApiService().getQueue();
      if (!mounted) return;
      setState(() {
        _data = HomeData(
          userName:             ApiService.currentUsername ?? _mockHomeData.userName,
          // only show real queue position after patient has checked in
          queuePosition:        ApiService.currentVisitId != null
                                  ? (ApiService.currentQueuePosition ?? 0)
                                  : 0,
          estimatedWaitMinutes: ApiService.currentVisitId != null
                                  ? ((ApiService.currentQueuePosition ?? 0) * 8)
                                  : 0,
          isDoctorAvailable:    true,
          hasNewNotifications:  false,
          healthAdvisoryTitle:  _mockHomeData.healthAdvisoryTitle,
        );
        // show active queue CTA only if patient has checked in
        if (ApiService.currentVisitId != null) {
          _isPatientInQueue = true;
        }
      });
    } catch (e) {
      // keep mock data if API fails — silent fallback
      setState(() {
        _data = HomeData(
          userName:             ApiService.currentUsername ?? _mockHomeData.userName,
          queuePosition:        0,
          estimatedWaitMinutes: 0,
          isDoctorAvailable:    false,
          hasNewNotifications:  false,
          healthAdvisoryTitle:  _mockHomeData.healthAdvisoryTitle,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── HERO HEADER ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _HeroHeader(
                  data: _data,
                  onBellTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                  onLogout: () =>
                      Navigator.of(context).pushReplacementNamed('/login'),
                  showLogout: MediaQuery.of(context).size.width < 600,
                  showBell: MediaQuery.of(context).size.width < 600,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── TODAY'S REMINDERS ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppSectionHeader(title: "Today's Reminders"),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    color: AppColors.surface,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: _reminders.asMap().entries.map((entry) {
                        return _ReminderTile(
                          reminder: entry.value,
                          onToggle: (val) => setState(
                            () => _reminders[entry.key].isDone = val,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── CLINIC UPDATES ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppSectionHeader(title: 'Clinic Updates'),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              if (_showHealthAdvisory)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _AdvisoryCard(
                      title: _data.healthAdvisoryTitle,
                      onDismiss: () =>
                          setState(() => _showHealthAdvisory = false),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: _UpdateCard(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── MEDICINE AVAILABILITY ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppSectionHeader(title: 'Medicine Availability'),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: _MedicineCard(medicines: _medicines),
                ),
              ),

              // Space so CTA doesn't cover last card
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // ── CTA (fixed at bottom) ────────────────────────────────────────
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _isPatientInQueue
                ? _ActiveQueueCta(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QueueSubmissionScreen(
                          queueNumber: _queuePosition + 1,
                          onCancelled: () =>
                              setState(() => _isPatientInQueue = false),
                        ),
                      ),
                    ),
                  )
                : _CheckInCta(
                    onTap: () => showSymptomSubmissionSheet(
                      context,
                      onSubmitted: (_) {
                        setState(() => _isPatientInQueue = true);
                        _loadHomeData(); // refresh queue position after check-in
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PRIVATE WIDGETS
// =============================================================================

// ── Hero Header ───────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final HomeData data;
  final VoidCallback onBellTap;
  final VoidCallback onLogout;
  final bool showLogout;
  final bool showBell;

  const _HeroHeader({
    required this.data,
    required this.onBellTap,
    required this.onLogout,
    this.showLogout = true,
    this.showBell = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.hero, AppColors.hero2, AppColors.hero3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: greeting + logout ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Avatar + greeting + name ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PatientProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good afternoon',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        data.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (showLogout)
                GestureDetector(
                  onTap: onLogout,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Doctor availability + bell on same row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DoctorAvailabilityChip(isAvailable: data.isDoctorAvailable),
              if (showBell)
                _NotificationBell(
                  hasUpdate: data.hasNewNotifications,
                  onTap: onBellTap,
                ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Stat cards ──
          Row(
            children: [
              Expanded(
                child: _HStatCard(
                  label: 'Queue Now',
                  value: data.queuePosition.toString(),
                  sub: 'patients ahead',
                  color: AppColors.heroStatBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HStatCard(
                  label: 'Est. Time',
                  value: data.estimatedWaitMinutes == 0
                      ? '—'
                      : '~${data.estimatedWaitMinutes}m',
                  sub: 'before your turn',
                  color: AppColors.heroStatAmber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Hero Stat Card ────────────────────────────────────────────────────────────

class _HStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _HStatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'DM Mono',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Doctor Availability Chip ──────────────────────────────────────────────────

class _DoctorAvailabilityChip extends StatelessWidget {
  final bool isAvailable;
  const _DoctorAvailabilityChip({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? AppColors.ok : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 10),
          Text(
            isAvailable ? 'Dr. Available' : 'Dr. On Break',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification Bell ─────────────────────────────────────────────────────────

class _NotificationBell extends StatelessWidget {
  final bool hasUpdate;
  final VoidCallback onTap;

  const _NotificationBell({required this.hasUpdate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (hasUpdate)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Reminder Tile ─────────────────────────────────────────────────────────────

class _ReminderTile extends StatelessWidget {
  final PrescriptionReminder reminder;
  final ValueChanged<bool> onToggle;

  const _ReminderTile({required this.reminder, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        reminder.time,
        style: TextStyle(
          color: AppColors.ink3,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontFamily: 'DM Mono',
        ),
      ),
      title: Text(
        reminder.medicineName,
        style: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.bold,
          decoration: reminder.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(reminder.dose, style: TextStyle(color: AppColors.ink2)),
      trailing: Checkbox(
        value: reminder.isDone,
        activeColor: AppColors.accent,
        onChanged: (val) => onToggle(val!),
      ),
    );
  }
}

// ── Advisory Card ─────────────────────────────────────────────────────────────

class _AdvisoryCard extends StatelessWidget {
  final String title;
  final VoidCallback onDismiss;

  const _AdvisoryCard({required this.title, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.hero,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠ HEALTH ADVISORY',
                style: TextStyle(
                  color: AppColors.err.withValues(alpha: 0.85),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stay safe and follow clinic guidelines.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Update Card ───────────────────────────────────────────────────────────────

class _UpdateCard extends StatelessWidget {
  const _UpdateCard();

  @override
  Widget build(BuildContext context) {
    // TODO: replace with list from GET /api/v1/announcements
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.ink.withValues(alpha: 0.05),
          child: Icon(Icons.info_outline, color: AppColors.ink2),
        ),
        title: Text(
          'Clinic closing early Friday',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
        ),
        subtitle: Text('March 12th', style: TextStyle(color: AppColors.ink3)),
      ),
    );
  }
}

// ── Medicine Card ─────────────────────────────────────────────────────────────

class _MedicineCard extends StatelessWidget {
  final List<MedicineAvailability> medicines;
  const _MedicineCard({required this.medicines});

  String _label(AppStatus s) => switch (s) {
    AppStatus.ok => 'Available',
    AppStatus.warn => 'Limited',
    AppStatus.err => 'Out of Stock',
    _ => 'Unknown',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: medicines.map((med) {
          return ListTile(
            leading: Icon(
              Icons.medication_liquid_outlined,
              color: AppColors.statusFg(med.status),
            ),
            title: Text(
              med.name,
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: AppStatusChip(
              label: _label(med.status),
              status: med.status,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── CTA Buttons ───────────────────────────────────────────────────────────────

class _CheckInCta extends StatelessWidget {
  final VoidCallback onTap;
  const _CheckInCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: AppColors.err,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.err.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sick_outlined, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              "Feeling sick? Check-in",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveQueueCta extends StatelessWidget {
  final VoidCallback onTap;
  const _ActiveQueueCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: AppColors.ok,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.ok.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              "Check submission status",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
