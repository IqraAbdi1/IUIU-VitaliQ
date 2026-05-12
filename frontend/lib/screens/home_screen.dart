import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';
import 'symptom_submission_sheet.dart';
import 'queue_submission_screen.dart';
import 'notifications_screen.dart';
import 'patient_profile_screen.dart';
import 'dart:async';
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

/// Active treatment plan for the patient.
/// Backend: GET /api/v1/treatment-plans?patient_id={id}
class PatientTreatmentPlan {
  final String planId;
  final String treatment;
  final String interval;
  final int totalDoses;
  final int dosesGiven;
  final String nextDoseTime;

  const PatientTreatmentPlan({
    required this.planId,
    required this.treatment,
    required this.interval,
    required this.totalDoses,
    required this.dosesGiven,
    required this.nextDoseTime,
  });

  bool get isComplete => dosesGiven >= totalDoses;
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
  final String doctorName; // Backend: queue/stats.doctor_name
  final String doctorSpecialty; // Backend: queue/stats.doctor_specialty
  final bool hasNewNotifications;
  final String healthAdvisoryTitle;

  const HomeData({
    required this.userName,
    required this.queuePosition,
    required this.estimatedWaitMinutes,
    required this.isDoctorAvailable,
    required this.doctorName,
    required this.doctorSpecialty,
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
  queuePosition: 7,
  estimatedWaitMinutes: 13,
  isDoctorAvailable: true,
  doctorName: 'Dr. Amina Hassan',
  doctorSpecialty: 'General Practice',
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

// TODO: replace with GET /api/v1/treatment-plans?patient_id={id}
const PatientTreatmentPlan? _mockTreatmentPlan = PatientTreatmentPlan(
  planId: 'TP-001',
  treatment: 'IV Drip — Normal Saline',
  interval: 'Every 8 hours',
  totalDoses: 6,
  dosesGiven: 2,
  nextDoseTime: '2:00 PM',
);
// set to null to simulate no active plan

// TODO: replace with GET /api/v1/medicines
const List<MedicineAvailability> _mockMedicines = [
  MedicineAvailability(name: 'Paracetamol 500mg', status: AppStatus.ok),
  MedicineAvailability(name: 'Amoxicillin 500mg', status: AppStatus.warn),
  MedicineAvailability(name: 'Cetirizine 10mg', status: AppStatus.ok),
  MedicineAvailability(name: 'Ibuprofen 400mg', status: AppStatus.err),
];

// =============================================================================
// Widgets
// =============================================================================

class _QuickAccessRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final bool active;
  final VoidCallback? onTap;

  const _QuickAccessRow({
    required this.icon,
    required this.label,
    required this.status,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? AppColors.accent : AppColors.ink3,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: active ? AppColors.ink : AppColors.ink3,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      color: active ? AppColors.accent : AppColors.ink3,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: active ? AppColors.ink3 : AppColors.border,
              ),
          ],
        ),
      ),
    );
  }
}

class _TreatmentPlanSheet extends StatelessWidget {
  final PatientTreatmentPlan plan;
  const _TreatmentPlanSheet({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Treatment Plan',
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
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),
              AppInfoBox(
                label: plan.treatment,
                body: '${plan.interval} · Next dose at ${plan.nextDoseTime}',
                variant: AppInfoVariant.accent,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Progress: ',
                    style: TextStyle(fontSize: 12, color: AppColors.ink3),
                  ),
                  Text(
                    '${plan.dosesGiven} of ${plan.totalDoses} doses',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: plan.dosesGiven / plan.totalDoses,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppInfoBox(
                label: 'What to do',
                body:
                    'Arrive at the clinic at your scheduled dose time. The nurse will be notified when you check in.',
                variant: AppInfoVariant.warn,
              ),
              const SizedBox(height: 16),
              // Backend: POST /api/v1/treatment-plans/{planId}/arrived
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  // TODO: POST /api/v1/treatment-plans/{planId}/arrived
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nurse notified of your arrival.'),
                      backgroundColor: AppColors.ok,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    "I've Arrived",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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

class _RemindersSheet extends StatelessWidget {
  final List<PrescriptionReminder> reminders;
  final void Function(int, bool) onToggle;

  const _RemindersSheet({required this.reminders, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
              child: Row(
                children: [
                  const Text(
                    "Today's Reminders",
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
            ...reminders.asMap().entries.map(
              (entry) => _ReminderTile(
                reminder: entry.value,
                onToggle: (val) => onToggle(entry.key, val),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

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

  // Backend: GET /api/v1/treatment-plans?patient_id={id}
  final PatientTreatmentPlan? _activePlan = _mockTreatmentPlan;

  // TODO: load from GET /api/v1/medicines
  final List<MedicineAvailability> _medicines = _mockMedicines;

  bool _isPatientInQueue = false;
  bool _showHealthAdvisory = true;

  // TODO: derive from GET /api/v1/queue/stats?patient_id={id}
  int get _queuePosition => _data.queuePosition;
  int get _estimatedWait => _data.estimatedWaitMinutes;

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

              // ── TREATMENT IN PROGRESS ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppSectionHeader(title: 'Treatment in Progress'),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _QuickAccessRow(
                          icon: Icons.vaccines_rounded,
                          label: 'Treatment Plan',
                          status:
                              _activePlan != null && !_activePlan!.isComplete
                              ? '${_activePlan!.dosesGiven}/${_activePlan!.totalDoses} doses · Next ${_activePlan!.nextDoseTime}'
                              : 'No active plan',
                          active:
                              _activePlan != null && !_activePlan!.isComplete,
                          onTap: _activePlan != null && !_activePlan!.isComplete
                              ? () => showDialog(
                                  context: context,
                                  barrierColor: Colors.black54,
                                  builder: (_) =>
                                      _TreatmentPlanSheet(plan: _activePlan!),
                                )
                              : null,
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        _QuickAccessRow(
                          icon: Icons.medication_rounded,
                          label: "Today's Reminders",
                          status: _reminders.any((r) => !r.isDone)
                              ? '${_reminders.where((r) => !r.isDone).length} pending'
                              : 'All done',
                          active: _reminders.any((r) => !r.isDone),
                          onTap: _reminders.isNotEmpty
                              ? () => showDialog(
                                  context: context,
                                  barrierColor: Colors.black54,
                                  builder: (_) => _RemindersSheet(
                                    reminders: _reminders,
                                    onToggle: (i, val) => setState(
                                      () => _reminders[i].isDone = val,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
                      onSubmitted: (_) =>
                          setState(() => _isPatientInQueue = true),
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
              _DoctorAvailabilityChip(
                isAvailable: data.isDoctorAvailable,
                doctorName: data.doctorName,
                doctorSpecialty: data.doctorSpecialty,
              ),
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
                  value: '~${data.estimatedWaitMinutes}m',
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

// ── Doctor Availability Chip ──────────────────────────────────────────────────

// Backend: GET /api/v1/queue/stats → doctor_name, doctor_specialty, is_available
class _DoctorAvailabilityChip extends StatefulWidget {
  final bool isAvailable;
  final String doctorName;
  final String doctorSpecialty;

  const _DoctorAvailabilityChip({
    required this.isAvailable,
    required this.doctorName,
    required this.doctorSpecialty,
  });

  @override
  State<_DoctorAvailabilityChip> createState() =>
      _DoctorAvailabilityChipState();
}

class _DoctorAvailabilityChipState extends State<_DoctorAvailabilityChip> {
  int _textIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() => _textIndex = (_textIndex + 1) % 3);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _currentText => switch (_textIndex) {
    0 => widget.doctorName,
    1 => widget.doctorSpecialty,
    _ => widget.isAvailable ? 'Dr. Available' : 'Dr. On Break',
  };

  @override
  Widget build(BuildContext context) {
    final color = widget.isAvailable ? AppColors.ok : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 10),
          SizedBox(
            width: 160, // wide enough for longest expected text
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                _currentText,
                key: ValueKey(_textIndex),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
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
