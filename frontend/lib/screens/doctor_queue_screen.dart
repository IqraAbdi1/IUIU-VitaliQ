import 'package:flutter/material.dart';
import '../theme.dart';

// ─────────────────────────────────────────────
// MOCK DATA — replace with API call when backend is ready
// Backend: GET /api/v1/queue?role=doctor
// ─────────────────────────────────────────────

enum _Severity { urgent, moderate, routine }

class _QueuePatient {
  final String queueId; // Backend: queue.queue_id
  final String name; // Backend: queue.patient.full_name
  final String studentId; // Backend: queue.patient.username
  final String timeIn; // Backend: queue.created_at (formatted)
  final _Severity severity; // Backend: queue.ml_severity
  final String symptoms; // Backend: queue.symptoms[].name joined
  final String? aiNote; // Backend: queue.ai_assessment (nullable — only Urgent)

  const _QueuePatient({
    required this.queueId,
    required this.name,
    required this.studentId,
    required this.timeIn,
    required this.severity,
    required this.symptoms,
    this.aiNote,
  });
}

class _DashStats {
  final int todayTotal; // Backend: analytics.today_total
  final int todayRemaining; // Backend: analytics.today_remaining
  final int inQueue; // Backend: analytics.in_queue
  final int urgentCount; // Backend: analytics.urgent_count
  final int pendingLabs; // Backend: analytics.pending_labs
  final String
  avgConsultMin; // Backend: analytics.avg_consult_minutes (formatted)

  const _DashStats({
    required this.todayTotal,
    required this.todayRemaining,
    required this.inQueue,
    required this.urgentCount,
    required this.pendingLabs,
    required this.avgConsultMin,
  });
}

const _mockStats = _DashStats(
  todayTotal: 18,
  todayRemaining: 4,
  inQueue: 12,
  urgentCount: 3,
  pendingLabs: 4,
  avgConsultMin: '11m',
);

final _mockPatients = <_QueuePatient>[
  _QueuePatient(
    queueId: 'Q-042',
    name: 'Khalid Abdelgadir',
    studentId: 'STU-2024-1092',
    timeIn: '8:42 AM',
    severity: _Severity.urgent,
    symptoms: 'Fever 3 days, severe headache, vomiting, chills',
    aiNote: 'Strong indicators for malaria/typhoid. Urgent labs recommended.',
  ),
  _QueuePatient(
    queueId: 'Q-038',
    name: 'Fatima Osman',
    studentId: 'STU-2024-0901',
    timeIn: '9:05 AM',
    severity: _Severity.urgent,
    symptoms: 'Chest pain, difficulty breathing',
  ),
  _QueuePatient(
    queueId: 'Q-047',
    name: 'Amina Nakato',
    studentId: 'STU-2024-0842',
    timeIn: '9:30 AM',
    severity: _Severity.moderate,
    symptoms: 'Fever, cough · paracetamol ineffective',
  ),
  _QueuePatient(
    queueId: 'Q-051',
    name: 'Ibrahim Hassan',
    studentId: 'STU-2024-1134',
    timeIn: '9:55 AM',
    severity: _Severity.moderate,
    symptoms: 'Persistent headache, light sensitivity',
  ),
  _QueuePatient(
    queueId: 'Q-053',
    name: 'Zainab Musa',
    studentId: 'STU-2024-0776',
    timeIn: '10:10 AM',
    severity: _Severity.moderate,
    symptoms: 'Nausea, diarrhoea, mild fever since yesterday',
  ),
  _QueuePatient(
    queueId: 'Q-055',
    name: 'Daniel Okello',
    studentId: 'STU-2024-0623',
    timeIn: '10:22 AM',
    severity: _Severity.moderate,
    symptoms: 'Sore throat, body aches, fatigue',
  ),
  _QueuePatient(
    queueId: 'Q-056',
    name: 'Grace Apio',
    studentId: 'STU-2024-0589',
    timeIn: '10:33 AM',
    severity: _Severity.moderate,
    symptoms: 'Cough, runny nose, low-grade fever',
  ),
  _QueuePatient(
    queueId: 'Q-057',
    name: 'Yusuf Kamau',
    studentId: 'STU-2024-0412',
    timeIn: '10:45 AM',
    severity: _Severity.moderate,
    symptoms: 'Stomach cramps, loose stool since morning',
  ),
  _QueuePatient(
    queueId: 'Q-058',
    name: 'Mariam Ssali',
    studentId: 'STU-2024-1201',
    timeIn: '11:00 AM',
    severity: _Severity.routine,
    symptoms: 'Mild headache, requesting paracetamol refill',
  ),
  _QueuePatient(
    queueId: 'Q-059',
    name: 'Ahmed Wario',
    studentId: 'STU-2024-0355',
    timeIn: '11:12 AM',
    severity: _Severity.routine,
    symptoms: 'Eye irritation, watery discharge',
  ),
  _QueuePatient(
    queueId: 'Q-060',
    name: 'Hana Abdi',
    studentId: 'STU-2024-0298',
    timeIn: '11:25 AM',
    severity: _Severity.routine,
    symptoms: 'Minor skin rash on forearm, no fever',
  ),
];

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class DoctorQueueScreen extends StatefulWidget {
  const DoctorQueueScreen({super.key});

  @override
  State<DoctorQueueScreen> createState() => _DoctorQueueScreenState();
}

class _DoctorQueueScreenState extends State<DoctorQueueScreen> {
  // Backend: GET /api/v1/queue/stats?role=doctor
  final _DashStats _stats = _mockStats;

  // Backend: GET /api/v1/queue?role=doctor
  List<_QueuePatient> _patients = _mockPatients;

  _Severity _activeFilter = _Severity.urgent;

  List<_QueuePatient> get _filteredPatients =>
      _patients.where((p) => p.severity == _activeFilter).toList();

  int _countFor(_Severity s) => _patients.where((p) => p.severity == s).length;

  void _skipPatient(_QueuePatient patient) {
    // Backend: PATCH /api/v1/queue/{visit_id}/skip
    setState(
      () => _patients = _patients
          .where((p) => p.queueId != patient.queueId)
          .toList(),
    );
  }

  void _openConsultation(_QueuePatient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConsultationSheet(patient: patient),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatsStrip(stats: _stats),
        _FilterTabs(
          activeFilter: _activeFilter,
          counts: {
            _Severity.urgent: _countFor(_Severity.urgent),
            _Severity.moderate: _countFor(_Severity.moderate),
            _Severity.routine: _countFor(_Severity.routine),
          },
          onFilterChanged: (f) => setState(() => _activeFilter = f),
        ),
        Expanded(
          child: _filteredPatients.isEmpty
              ? _EmptyState(severity: _activeFilter)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                  itemCount: _filteredPatients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _PatientCard(
                    patient: _filteredPatients[i],
                    onConsult: () => _openConsultation(_filteredPatients[i]),
                    onSkip: () => _skipPatient(_filteredPatients[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// STATS STRIP
// ─────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final _DashStats stats;
  const _StatsStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Today',
                    value: '${stats.todayTotal}',
                    sub: '${stats.todayRemaining} remaining',
                    valueColor: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'In Queue',
                    value: '${stats.inQueue}',
                    sub: '${stats.urgentCount} urgent',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Pending Labs',
                    value: '${stats.pendingLabs}',
                    valueColor: const Color(0xFFA05C00),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Avg. Consult',
                    value: stats.avgConsultMin,
                    valueColor: const Color(0xFF16714A),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.sub,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.ink3,
              letterSpacing: 0.07 * 9.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DMMono',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.ink,
              height: 1,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(
              sub!,
              style: const TextStyle(fontSize: 10.5, color: AppColors.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FILTER TABS
// ─────────────────────────────────────────────

class _FilterTabs extends StatelessWidget {
  final _Severity activeFilter;
  final Map<_Severity, int> counts;
  final ValueChanged<_Severity> onFilterChanged;

  const _FilterTabs({
    required this.activeFilter,
    required this.counts,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E4EB)),
          bottom: BorderSide(color: Color(0xFFE0E4EB)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _FilterPill(
              label: 'Urgent (${counts[_Severity.urgent]})',
              active: activeFilter == _Severity.urgent,
              onTap: () => onFilterChanged(_Severity.urgent),
            ),
            const SizedBox(width: 6),
            _FilterPill(
              label: 'Moderate (${counts[_Severity.moderate]})',
              active: activeFilter == _Severity.moderate,
              onTap: () => onFilterChanged(_Severity.moderate),
            ),
            const SizedBox(width: 6),
            _FilterPill(
              label: 'Routine (${counts[_Severity.routine]})',
              active: activeFilter == _Severity.routine,
              onTap: () => onFilterChanged(_Severity.routine),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE8F4FB) : const Color(0xFFF8F9FB),
          border: Border.all(
            color: active ? AppColors.accent : const Color(0xFFE0E4EB),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.accent : AppColors.ink2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PATIENT CARD
// ─────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  final _QueuePatient patient;
  final VoidCallback onConsult;
  final VoidCallback onSkip;

  const _PatientCard({
    required this.patient,
    required this.onConsult,
    required this.onSkip,
  });

  Color get _accentColor {
    switch (patient.severity) {
      case _Severity.urgent:
        return const Color(0xFFB81C24);
      case _Severity.moderate:
        return const Color(0xFFA05C00);
      case _Severity.routine:
        return AppColors.ink3;
    }
  }

  (String, Color, Color, Color) get _severityChip {
    switch (patient.severity) {
      case _Severity.urgent:
        return (
          'Urgent',
          const Color(0xFFB81C24),
          const Color(0xFFFFF2F2),
          const Color(0xFFF5AAAA),
        );
      case _Severity.moderate:
        return (
          'Moderate',
          const Color(0xFFA05C00),
          const Color(0xFFFFF7EA),
          const Color(0xFFF5C97A),
        );
      case _Severity.routine:
        return (
          'Routine',
          AppColors.ink2,
          const Color(0xFFE6E9EE),
          const Color(0xFFE0E4EB),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (chipLabel, chipFg, chipBg, chipBorder) = _severityChip;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: _accentColor, width: 3.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // — Top row: name + severity chip —
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${patient.studentId} · #${patient.queueId} · ${patient.timeIn}',
                        style: const TextStyle(
                          fontFamily: 'DMMono',
                          fontSize: 10.5,
                          color: AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    border: Border.all(color: chipBorder),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    chipLabel,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: chipFg,
                    ),
                  ),
                ),
              ],
            ),

            // — Symptoms —
            const SizedBox(height: 6),
            Text(
              patient.symptoms,
              style: const TextStyle(fontSize: 12, color: AppColors.ink2),
            ),

            // — AI Assessment box (Urgent only) —
            if (patient.aiNote != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F2),
                  border: Border.all(
                    color: const Color(0xFFF5AAAA),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI ASSESSMENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB81C24),
                        letterSpacing: 0.07 * 10,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      patient.aiNote!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.ink2,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // — Action buttons —
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Open Consultation',
                    primary: true,
                    onTap: onConsult,
                  ),
                ),
                const SizedBox(width: 7),
                _ActionButton(label: 'Lab Request', onTap: () {}),
                const SizedBox(width: 7),
                _ActionButton(
                  label: patient.severity == _Severity.routine
                      ? 'Notes'
                      : 'Skip',
                  onTap: patient.severity == _Severity.routine ? () {} : onSkip,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: primary ? AppColors.accent : const Color(0xFFF8F9FB),
          border: Border.all(
            color: primary ? AppColors.accent : const Color(0xFFE0E4EB),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: primary ? Colors.white : AppColors.ink2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final _Severity severity;
  const _EmptyState({required this.severity});

  String get _label {
    switch (severity) {
      case _Severity.urgent:
        return 'No urgent patients';
      case _Severity.moderate:
        return 'No moderate cases';
      case _Severity.routine:
        return 'No routine cases';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 44,
            color: AppColors.ink3.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            _label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Queue is clear for this category.',
            style: TextStyle(fontSize: 12, color: AppColors.ink3),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONSULTATION SHEET
// ─────────────────────────────────────────────

class _ConsultationSheet extends StatefulWidget {
  final _QueuePatient patient;
  const _ConsultationSheet({required this.patient});

  @override
  State<_ConsultationSheet> createState() => _ConsultationSheetState();
}

class _ConsultationSheetState extends State<_ConsultationSheet> {
  // Symptom chips — pre-populated from patient submission, doctor confirms/adjusts
  // Backend: visit.symptoms[].name
  late List<String> _confirmedSymptoms;

  // Backend: POST /api/v1/consultations body fields
  final _notesController = TextEditingController();
  final _medicineController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  bool _labRequestOpen = false;
  bool _isSubmitting = false;

  // Available symptom chips (same fixed list as patient sheet)
  static const _kSymptoms = [
    'Fever',
    'Cough',
    'Headache',
    'Nausea',
    'Fatigue',
    'Chills',
    'Body aches',
    'Diarrhoea',
    'Chest pain',
    'Breathlessness',
    'Vomiting',
    'Loss of appetite',
    'Joint pain',
    'Rash',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-populate confirmed symptoms from patient's submitted list
    // Backend: visit.symptoms[].name
    _confirmedSymptoms = widget.patient.symptoms
        .split(RegExp(r'[,·]'))
        .map((s) => s.trim())
        .where((s) => _kSymptoms.any((k) => k.toLowerCase() == s.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _medicineController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _toggleSymptom(String s) {
    setState(() {
      _confirmedSymptoms.contains(s)
          ? _confirmedSymptoms.remove(s)
          : _confirmedSymptoms.add(s);
    });
  }

  void _completeConsultation() async {
    // Backend: POST /api/v1/consultations
    // Body: { visit_id, confirmed_symptoms, diagnostic_notes,
    //         prescription: { medicine_name, dosage, instructions },
    //         lab_requested: bool }
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add diagnostic notes before completing.'),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // mock network delay
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consultation for ${widget.patient.name} completed.'),
          backgroundColor: const Color(0xFF16714A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 18),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E4EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // — Sheet header —
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Consultation',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.patient.name} · #${widget.patient.queueId}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.ink3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _SeverityChip(severity: widget.patient.severity),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const Divider(color: Color(0xFFE0E4EB), height: 1),
                    const SizedBox(height: 18),

                    // — Patient-submitted symptoms (read-only info) —
                    const _SheetLabel('Reported Symptoms'),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FB),
                        border: Border.all(color: const Color(0xFFE0E4EB)),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        widget.patient.symptoms,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.ink2,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // — Confirm / adjust symptoms —
                    const _SheetLabel('Confirm Symptoms'),
                    const SizedBox(height: 4),
                    const Text(
                      'Select all symptoms present after examination.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.ink3),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: _kSymptoms.map((s) {
                        final on = _confirmedSymptoms.contains(s);
                        return GestureDetector(
                          onTap: () => _toggleSymptom(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: on
                                  ? const Color(0xFFE8F4FB)
                                  : const Color(0xFFF8F9FB),
                              border: Border.all(
                                color: on
                                    ? AppColors.accent
                                    : const Color(0xFFE0E4EB),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: on ? AppColors.accent : AppColors.ink2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // — Diagnostic notes —
                    const _SheetLabel('Diagnostic Notes'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.ink,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Clinical findings, working diagnosis, reasoning…',
                        hintStyle: const TextStyle(
                          color: AppColors.ink3,
                          fontSize: 12.5,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E4EB),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E4EB),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: AppColors.accent,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(13),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // — Lab Request toggle —
                    GestureDetector(
                      onTap: () =>
                          setState(() => _labRequestOpen = !_labRequestOpen),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _labRequestOpen
                              ? const Color(0xFFE8F4FB)
                              : const Color(0xFFF8F9FB),
                          border: Border.all(
                            color: _labRequestOpen
                                ? AppColors.accent
                                : const Color(0xFFE0E4EB),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _labRequestOpen
                                  ? Icons.science_rounded
                                  : Icons.science_outlined,
                              size: 18,
                              color: _labRequestOpen
                                  ? AppColors.accent
                                  : AppColors.ink3,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Request Lab Tests',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _labRequestOpen
                                    ? AppColors.accent
                                    : AppColors.ink2,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _labRequestOpen
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: _labRequestOpen
                                  ? AppColors.accent
                                  : AppColors.ink3,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_labRequestOpen) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FB),
                          border: Border.all(color: const Color(0xFFE0E4EB)),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Backend: POST /api/v1/lab-requests
                            // TODO: replace with dynamic test selector when backend ready
                            Text(
                              'Common Tests',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink3,
                                letterSpacing: 0.06 * 10.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            _LabTestChips(),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // — Prescription —
                    const _SheetLabel('Prescription'),
                    const SizedBox(height: 6),
                    _SheetInput(
                      controller: _medicineController,
                      label: 'Medicine Name',
                      hint: 'e.g. Artemether-Lumefantrine 80/480mg',
                    ),
                    const SizedBox(height: 10),
                    _SheetInput(
                      controller: _dosageController,
                      label: 'Dosage & Schedule',
                      hint: 'e.g. 4 tablets at 0h, 8h, 24h, 36h, 48h, 60h',
                    ),
                    const SizedBox(height: 10),
                    _SheetInput(
                      controller: _instructionsController,
                      label: 'Doctor\'s Instructions',
                      hint: 'e.g. Take with food. Complete full course.',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // — Complete CTA —
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _isSubmitting ? null : _completeConsultation,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isSubmitting
                                  ? [AppColors.ink3, AppColors.ink3]
                                  : [AppColors.accent, const Color(0xFF155F94)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: _isSubmitting
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppColors.accent.withValues(
                                        alpha: 0.38,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isSubmitting)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              const SizedBox(width: 9),
                              Text(
                                _isSubmitting
                                    ? 'Saving…'
                                    : 'Complete Consultation',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.01 * 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // — Cancel button —
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                            side: const BorderSide(
                              color: Color(0xFFE0E4EB),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LAB TEST CHIPS (stateful, inside consultation sheet)
// ─────────────────────────────────────────────

class _LabTestChips extends StatefulWidget {
  const _LabTestChips();

  @override
  State<_LabTestChips> createState() => _LabTestChipsState();
}

class _LabTestChipsState extends State<_LabTestChips> {
  // Backend: POST /api/v1/lab-requests body: { visit_id, test_names[] }
  static const _kTests = [
    'Malaria RDT',
    'FBC',
    'Typhoid (Widal)',
    'Haemoglobin',
    'Blood Glucose',
    'Urine R/E',
    'Stool R/E',
    'Liver Function',
  ];

  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: _kTests.map((t) {
        final on = _selected.contains(t);
        return GestureDetector(
          onTap: () =>
              setState(() => on ? _selected.remove(t) : _selected.add(t)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: on ? const Color(0xFFE8F4FB) : AppColors.surface,
              border: Border.all(
                color: on ? AppColors.accent : const Color(0xFFE0E4EB),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              t,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: on ? AppColors.accent : AppColors.ink2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED SHEET WIDGETS
// ─────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: AppColors.ink3,
        letterSpacing: 0.07 * 10.5,
      ),
    );
  }
}

class _SheetInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  const _SheetInput({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SheetLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.ink3, fontSize: 12.5),
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(
                color: Color(0xFFE0E4EB),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(
                color: Color(0xFFE0E4EB),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(13),
          ),
        ),
      ],
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final _Severity severity;
  const _SeverityChip({required this.severity});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg, border) = switch (severity) {
      _Severity.urgent => (
        'Urgent',
        const Color(0xFFB81C24),
        const Color(0xFFFFF2F2),
        const Color(0xFFF5AAAA),
      ),
      _Severity.moderate => (
        'Moderate',
        const Color(0xFFA05C00),
        const Color(0xFFFFF7EA),
        const Color(0xFFF5C97A),
      ),
      _Severity.routine => (
        'Routine',
        AppColors.ink2,
        const Color(0xFFE6E9EE),
        const Color(0xFFE0E4EB),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(50),
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
