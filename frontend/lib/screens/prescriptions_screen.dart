import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

enum PrescriptionStatus { active, completed }

class PrescriptionDose {
  final String time; // Backend: prescription_dose.time
  final String medicineName; // Backend: prescription_dose.medicine_name
  final String instructions; // Backend: prescription_dose.instructions
  bool taken; // Backend: PATCH /api/v1/prescriptions/{id}/doses/{dose_id}/taken

  PrescriptionDose({
    required this.time,
    required this.medicineName,
    required this.instructions,
    this.taken = false,
  });
}

class CourseDay {
  final int dayNumber; // Backend: prescription_day.day_number
  final bool isToday; // Backend: derived from prescription_day.date vs today
  final int totalDoses; // Backend: prescription_day.total_doses
  final int takenDoses; // Backend: prescription_day.taken_doses

  const CourseDay({
    required this.dayNumber,
    required this.isToday,
    required this.totalDoses,
    required this.takenDoses,
  });
}

class Prescription {
  final String id; // Backend: prescription.id
  final String courseTitle; // Backend: prescription.course_title
  final String doctorName; // Backend: doctor.full_name
  final String issuedAt; // Backend: prescription.issued_at (formatted)
  final String endsOn; // Backend: prescription.ends_on (formatted)
  final String dayLabel; // Backend: derived — "Day X of Y"
  final PrescriptionStatus status; // Backend: prescription.status
  final List<PrescriptionDose>
  doses; // Backend: GET /api/v1/prescriptions/active
  final List<CourseDay> courseDays; // Backend: GET /api/v1/prescriptions/active
  final String? doctorNote; // Backend: consultation.diagnostic_notes

  const Prescription({
    required this.id,
    required this.courseTitle,
    required this.doctorName,
    required this.issuedAt,
    required this.endsOn,
    required this.dayLabel,
    required this.status,
    required this.doses,
    required this.courseDays,
    this.doctorNote,
  });
}

class PastPrescription {
  final String courseTitle; // Backend: prescription.course_title
  final String summary; // Backend: derived — medicine + date + doctor

  const PastPrescription({required this.courseTitle, required this.summary});
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK DATA
// Backend: GET /api/v1/prescriptions/active?patient_id={id}
//          GET /api/v1/prescriptions?patient_id={id}
// ─────────────────────────────────────────────────────────────────────────────

final _mockActivePrescription = Prescription(
  id: 'rx-001',
  courseTitle: 'Malaria Treatment',
  doctorName: 'Dr. Kato Emmanuel',
  issuedAt: 'Mar 8, 2025',
  endsOn: 'March 10',
  dayLabel: 'Day 2 of 3',
  status: PrescriptionStatus.active,
  doses: [
    PrescriptionDose(
      time: '08:00',
      medicineName: 'Artemether-Lumefantrine',
      instructions: '2 tablets · with food',
      taken: true,
    ),
    PrescriptionDose(
      time: '14:00',
      medicineName: 'Paracetamol 500mg',
      instructions: '1 tablet · if fever >38°C',
    ),
    PrescriptionDose(
      time: '20:00',
      medicineName: 'Artemether-Lumefantrine',
      instructions: '2 tablets · with food',
    ),
  ],
  courseDays: [
    CourseDay(dayNumber: 1, isToday: false, totalDoses: 6, takenDoses: 6),
    CourseDay(dayNumber: 2, isToday: true, totalDoses: 3, takenDoses: 1),
    CourseDay(dayNumber: 3, isToday: false, totalDoses: 3, takenDoses: 0),
  ],
  doctorNote:
      'Take artemether with food at all times to reduce nausea. Complete the full course even if symptoms improve. '
      'Return immediately if vomiting persists beyond 24 hours or fever does not subside by Day 3.',
);

const _mockPastPrescriptions = [
  PastPrescription(
    courseTitle: 'URI Treatment',
    summary: 'Amoxicillin 500mg · Jan 14 · Dr. Ssali',
  ),
  PastPrescription(
    courseTitle: 'Gastroenteritis',
    summary: 'ORS + Metronidazole · Oct 3 · Dr. Kato',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  // Local mutable copy so dose check-off updates UI without touching mock const
  // Backend: replace with API state management
  late Prescription _active;

  @override
  void initState() {
    super.initState();
    // TODO: replace with GET /api/v1/prescriptions/active?patient_id={id}
    _active = _mockActivePrescription;
  }

  void _toggleDose(int index) {
    // Backend: PATCH /api/v1/prescriptions/{id}/doses/{dose_id}/taken
    setState(() {
      _active.doses[index].taken = !_active.doses[index].taken;
    });
  }

  int get _takenTodayCount => _active.doses.where((d) => d.taken).length;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      children: [
        // ── Uses shared AppSectionHeader ──
        AppSectionHeader(title: 'Active Course · ${_active.issuedAt}'),
        const SizedBox(height: 8),
        _ActiveCourseCard(
          prescription: _active,
          takenCount: _takenTodayCount,
          onToggleDose: _toggleDose,
        ),
        const SizedBox(height: 12),
        _CourseProgressCard(prescription: _active),
        if (_active.doctorNote != null) ...[
          const SizedBox(height: 12),
          // ── Uses shared AppInfoBox ──
          AppInfoBox(
            label: "Doctor's Instructions",
            body: _active.doctorNote!,
            variant: AppInfoVariant.accent,
          ),
        ],
        const SizedBox(height: 18),
        // ── Uses shared AppSectionHeader ──
        const AppSectionHeader(title: 'Past Prescriptions'),
        const SizedBox(height: 8),
        _PastPrescriptionsCard(items: _mockPastPrescriptions),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// ── Active course card ──────────────────────────────────────────────────────

class _ActiveCourseCard extends StatelessWidget {
  final Prescription prescription;
  final int takenCount;
  final void Function(int index) onToggleDose;

  const _ActiveCourseCard({
    required this.prescription,
    required this.takenCount,
    required this.onToggleDose,
  });

  @override
  Widget build(BuildContext context) {
    final doses = prescription.doses;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: AppColors.accent, width: 3.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prescription.courseTitle,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prescription.doctorName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Uses shared AppStatusChip ──
                AppStatusChip(
                  label: prescription.dayLabel,
                  status: AppStatus.warn,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),

          // Dose rows
          ...List.generate(
            doses.length,
            (i) => _DoseRow(
              dose: doses[i],
              isLast: i == doses.length - 1,
              onTap: () => onToggleDose(i),
            ),
          ),

          // Footer
          Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.ink3,
                    ),
                    children: [
                      const TextSpan(text: 'Ends '),
                      TextSpan(
                        text: prescription.endsOn,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Uses shared AppStatusChip ──
                AppStatusChip(
                  label:
                      '$takenCount / ${prescription.doses.length} done today',
                  status: AppStatus.ok,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoseRow extends StatelessWidget {
  final PrescriptionDose dose;
  final bool isLast;
  final VoidCallback onTap;

  const _DoseRow({
    required this.dose,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 44,
            child: Text(
              dose.time,
              style: const TextStyle(
                fontFamily: 'DMMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.ink3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + instructions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dose.medicineName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  dose.instructions,
                  style: const TextStyle(fontSize: 11, color: AppColors.ink3),
                ),
              ],
            ),
          ),
          // Checkbox
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dose.taken ? AppColors.ok : Colors.transparent,
                border: Border.all(
                  color: dose.taken ? AppColors.ok : AppColors.border,
                  width: 2,
                ),
              ),
              child: dose.taken
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Course progress card ────────────────────────────────────────────────────

class _CourseProgressCard extends StatelessWidget {
  final Prescription prescription;
  const _CourseProgressCard({required this.prescription});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(
              'Course Progress',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: prescription.courseDays.map((day) {
                final progress = day.totalDoses == 0
                    ? 0.0
                    : day.takenDoses / day.totalDoses;
                final isComplete =
                    day.takenDoses == day.totalDoses && day.totalDoses > 0;
                final label = day.isToday
                    ? 'Day ${day.dayNumber} · Today'
                    : 'Day ${day.dayNumber}';
                final valueStr =
                    '${day.takenDoses} / ${day.totalDoses}${isComplete ? ' ✓' : ''}';
                final valueColor = isComplete
                    ? AppColors.ok
                    : day.isToday
                    ? AppColors.ink
                    : AppColors.ink3;
                final barColor = isComplete
                    ? AppColors.ok
                    : day.isToday
                    ? AppColors.warn
                    : AppColors.border;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink2,
                            ),
                          ),
                          Text(
                            valueStr,
                            style: TextStyle(
                              fontFamily: 'DMMono',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: valueColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: AppColors.bg2,
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Past prescriptions card ─────────────────────────────────────────────────

class _PastPrescriptionsCard extends StatelessWidget {
  final List<PastPrescription> items;
  const _PastPrescriptionsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Container(
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(bottom: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.courseTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        item.summary,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // ── Uses shared AppStatusChip ──
                const AppStatusChip(label: 'Done', status: AppStatus.ok),
              ],
            ),
          );
        }),
      ),
    );
  }
}
