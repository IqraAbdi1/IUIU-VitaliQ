import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// DATA MODELS
// These will be replaced by API responses from FastAPI /prescriptions endpoint
// ---------------------------------------------------------------------------

enum PrescriptionStatus { active, completed }

class PrescriptionDose {
  final String time; // e.g. "08:00"
  final String medicineName; // e.g. "Artemether-Lumefantrine"
  final String instructions; // e.g. "2 tablets · with food"
  bool taken;

  PrescriptionDose({
    required this.time,
    required this.medicineName,
    required this.instructions,
    this.taken = false,
  });
}

class CourseDay {
  final int dayNumber;
  final bool isToday;
  final int totalDoses;
  final int takenDoses;

  const CourseDay({
    required this.dayNumber,
    required this.isToday,
    required this.totalDoses,
    required this.takenDoses,
  });
}

class Prescription {
  final String id; // Backend: prescription.id
  final String courseTitle; // e.g. "Malaria Treatment"
  final String doctorName; // e.g. "Dr. Kato Emmanuel"
  final String issuedAt; // Backend: prescription.issued_at (formatted)
  final String endsOn; // e.g. "March 10"
  final String dayLabel; // e.g. "Day 2 of 3"
  final PrescriptionStatus status;
  final List<PrescriptionDose> doses;
  final List<CourseDay> courseDays;
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
  final String courseTitle; // e.g. "URI Treatment"
  final String summary; // e.g. "Amoxicillin 500mg · Jan 14 · Dr. Ssali"

  const PastPrescription({required this.courseTitle, required this.summary});
}

// ---------------------------------------------------------------------------
// MOCK DATA — swap for API call: GET /api/v1/prescriptions?patient_id={id}
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// SCREEN
// ---------------------------------------------------------------------------

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  // Local mutable copy so dose check-off updates UI without touching mock const
  late Prescription _active;

  @override
  void initState() {
    super.initState();
    // TODO: replace with API call → GET /api/v1/prescriptions/active?patient_id={id}
    _active = _mockActivePrescription;
  }

  void _toggleDose(int index) {
    setState(() {
      _active.doses[index].taken = !_active.doses[index].taken;
    });
  }

  int get _takenTodayCount => _active.doses.where((d) => d.taken).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF0F4),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        children: [
          _SectionLabel(label: 'Active Course · ${_active.issuedAt}'),
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
            _DoctorNoteBox(note: _active.doctorNote!),
          ],
          const SizedBox(height: 18),
          const _SectionLabel(label: 'Past Prescriptions'),
          const SizedBox(height: 8),
          _PastPrescriptionsCard(items: _mockPastPrescriptions),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGETS
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF44556A),
        letterSpacing: 0.07 * 11,
      ),
    );
  }
}

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: Color(0xFF1A7FC1), width: 3.5),
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
                          color: Color(0xFF151E2B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prescription.doctorName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A9BB0),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(label: prescription.dayLabel, type: _ChipType.warn),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E4EB)),

          // Dose rows
          ...List.generate(doses.length, (i) {
            final dose = doses[i];
            return _DoseRow(
              dose: dose,
              isLast: i == doses.length - 1,
              onTap: () => onToggleDose(i),
            );
          }),

          // Footer
          const Divider(height: 1, color: Color(0xFFE0E4EB)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF8A9BB0),
                    ),
                    children: [
                      const TextSpan(text: 'Ends '),
                      TextSpan(
                        text: prescription.endsOn,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF151E2B),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  label:
                      '$takenCount / ${prescription.doses.length} done today',
                  type: _ChipType.ok,
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
            : const Border(bottom: BorderSide(color: Color(0xFFE0E4EB))),
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
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8A9BB0),
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
                    color: Color(0xFF151E2B),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  dose.instructions,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A9BB0),
                  ),
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
                color: dose.taken
                    ? const Color(0xFF16714A)
                    : Colors.transparent,
                border: Border.all(
                  color: dose.taken
                      ? const Color(0xFF16714A)
                      : const Color(0xFFE0E4EB),
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
        color: Colors.white,
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
                color: Color(0xFF151E2B),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E4EB)),
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
                    ? const Color(0xFF16714A)
                    : day.isToday
                    ? const Color(0xFF151E2B)
                    : const Color(0xFF8A9BB0);
                final barColor = isComplete
                    ? const Color(0xFF16714A)
                    : day.isToday
                    ? const Color(0xFFA05C00)
                    : const Color(0xFFE0E4EB);

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
                              color: Color(0xFF44556A),
                            ),
                          ),
                          Text(
                            valueStr,
                            style: TextStyle(
                              fontFamily: 'monospace',
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
                          backgroundColor: const Color(0xFFE6E9EE),
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

// ── Doctor note info box ────────────────────────────────────────────────────

class _DoctorNoteBox extends StatelessWidget {
  final String note;
  const _DoctorNoteBox({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA8D4ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DOCTOR'S INSTRUCTIONS",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A7FC1),
              letterSpacing: 0.07 * 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF44556A),
              height: 1.6,
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
        color: Colors.white,
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
                  : const Border(bottom: BorderSide(color: Color(0xFFE0E4EB))),
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
                          color: Color(0xFF151E2B),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        item.summary,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A9BB0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const _StatusChip(label: 'Done', type: _ChipType.ok),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Shared status chip ──────────────────────────────────────────────────────

enum _ChipType { ok, warn, err, neutral, accent }

class _StatusChip extends StatelessWidget {
  final String label;
  final _ChipType type;

  const _StatusChip({required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final Color bg, fg, border;
    switch (type) {
      case _ChipType.ok:
        bg = const Color(0xFFEAFAF2);
        fg = const Color(0xFF16714A);
        border = const Color(0xFF96DEBB);
      case _ChipType.warn:
        bg = const Color(0xFFFFF7EA);
        fg = const Color(0xFFA05C00);
        border = const Color(0xFFF5C97A);
      case _ChipType.err:
        bg = const Color(0xFFFFF2F2);
        fg = const Color(0xFFB81C24);
        border = const Color(0xFFF5AAAA);
      case _ChipType.accent:
        bg = const Color(0xFFE8F4FB);
        fg = const Color(0xFF1A7FC1);
        border = const Color(0xFFA8D4ED);
      case _ChipType.neutral:
        bg = const Color(0xFFE6E9EE);
        fg = const Color(0xFF44556A);
        border = const Color(0xFFE0E4EB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
