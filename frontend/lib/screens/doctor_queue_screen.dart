import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

enum _Severity { urgent, moderate, routine }

enum _LabStatus { sent, resultsIn, completed }

enum _QueueTab { active, completed }

class _QueuePatient {
  final String queueId; // Backend: queue.queue_id
  final String name; // Backend: queue.patient.full_name
  final String studentId; // Backend: queue.patient.username
  final String timeIn; // Backend: queue.created_at (formatted)
  final _Severity severity; // Backend: queue.ml_severity
  final String symptoms; // Backend: queue.symptoms[].name joined
  final String? aiNote; // Backend: queue.ai_assessment (nullable)

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

class _LabResult {
  final String testName; // Backend: lab_result.test_name
  final String value; // Backend: lab_result.value
  final bool flagged; // Backend: lab_result.flagged
  final _LabStatus status; // Backend: lab_result.status

  const _LabResult({
    required this.testName,
    required this.value,
    required this.flagged,
    required this.status,
  });
}

class _CompletedPatient {
  final _QueuePatient patient;
  final String consultNotes; // Backend: consultation.diagnostic_notes
  final String
  prescriptionSummary; // Backend: prescription.medicine_name + dosage
  final List<_LabResult> labResults; // Backend: lab_results for visit

  const _CompletedPatient({
    required this.patient,
    required this.consultNotes,
    required this.prescriptionSummary,
    required this.labResults,
  });
}

class _DashStats {
  final int todayTotal; // Backend: analytics.today_total
  final int todayRemaining; // Backend: analytics.today_remaining
  final int inQueue; // Backend: analytics.in_queue
  final int urgentCount; // Backend: analytics.urgent_count
  final int pendingLabs; // Backend: analytics.pending_labs
  final String avgConsultMin; // Backend: analytics.avg_consult_minutes

  const _DashStats({
    required this.todayTotal,
    required this.todayRemaining,
    required this.inQueue,
    required this.urgentCount,
    required this.pendingLabs,
    required this.avgConsultMin,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// Backend: GET /api/v1/queue?role=doctor
// Backend: GET /api/v1/queue/stats?role=doctor
// ─────────────────────────────────────────────

final _mockStats = _DashStats(
  todayTotal: 18,
  todayRemaining: 4,
  inQueue: 11,
  urgentCount: 2,
  pendingLabs: 4,
  avgConsultMin: '11m',
);

// Ordered by submission time — backend returns sorted by created_at asc
final _mockPatients = <_QueuePatient>[
  _QueuePatient(
    queueId: 'Q-038',
    name: 'Fatima Osman',
    studentId: 'STU-2024-0901',
    timeIn: '8:38 AM',
    severity: _Severity.urgent,
    symptoms: 'Chest pain, difficulty breathing',
    aiNote:
        'Possible cardiac or respiratory event. Immediate assessment required.',
  ),
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

// Mock lab results per patient — Backend: GET /api/v1/lab-results?visit_id={id}
final _mockLabResults = <String, List<_LabResult>>{
  'Q-038': [
    _LabResult(
      testName: 'ECG Trace',
      value: 'Sinus tachycardia',
      flagged: true,
      status: _LabStatus.completed,
    ),
    _LabResult(
      testName: 'Troponin',
      value: 'Pending...',
      flagged: false,
      status: _LabStatus.sent,
    ),
  ],
  'Q-042': [
    _LabResult(
      testName: 'Malaria RDT',
      value: 'Positive (P. falciparum)',
      flagged: true,
      status: _LabStatus.completed,
    ),
    _LabResult(
      testName: 'FBC',
      value: 'Hb 9.2 g/dL',
      flagged: true,
      status: _LabStatus.completed,
    ),
    _LabResult(
      testName: 'Blood Glucose',
      value: '5.1 mmol/L',
      flagged: false,
      status: _LabStatus.resultsIn,
    ),
    _LabResult(
      testName: 'Typhoid (Widal)',
      value: 'Pending...',
      flagged: false,
      status: _LabStatus.sent,
    ),
  ],
};

// Mock completed patients — Backend: GET /api/v1/queue?role=doctor&status=completed
final _mockCompleted = <_CompletedPatient>[
  _CompletedPatient(
    patient: _QueuePatient(
      queueId: 'Q-031',
      name: 'Aisha Kamau',
      studentId: 'STU-2024-0211',
      timeIn: '7:55 AM',
      severity: _Severity.moderate,
      symptoms: 'Fever, body aches',
    ),
    consultNotes:
        'Likely viral infection. No bacterial signs. Rest and fluids advised.',
    prescriptionSummary: 'Paracetamol 500mg · 3×/day for 5 days',
    labResults: [],
  ),
  _CompletedPatient(
    patient: _QueuePatient(
      queueId: 'Q-033',
      name: 'Omar Diallo',
      studentId: 'STU-2024-0188',
      timeIn: '8:10 AM',
      severity: _Severity.routine,
      symptoms: 'Mild headache',
    ),
    consultNotes: 'Tension headache. No neurological signs.',
    prescriptionSummary: 'Ibuprofen 400mg · as needed',
    labResults: [],
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
  // Derived from live queue state — Backend: GET /api/v1/queue/stats?role=doctor
  _DashStats get _stats => _DashStats(
    todayTotal:
        _mockStats.todayTotal, // Backend: still static until endpoint live
    todayRemaining: _mockStats.todayRemaining,
    inQueue: _patients.length,
    urgentCount: _patients.where((p) => p.severity == _Severity.urgent).length,
    pendingLabs: _labSentIds.length,
    avgConsultMin: _mockStats.avgConsultMin,
  );

  // Backend: GET /api/v1/queue?role=doctor&status=active
  List<_QueuePatient> _patients = List.from(_mockPatients);

  // Backend: GET /api/v1/queue?role=doctor&status=completed
  List<_CompletedPatient> _completed = List.from(_mockCompleted);

  _QueueTab _activeTab = _QueueTab.active;

  // Per-card state — keyed by queueId
  // Backend: derived from visit.status
  final Set<String> _consultedIds = {};
  final Set<String> _labSentIds = {};
  final Map<String, List<_LabResult>> _patientLabResults = {};
  // Stores consult notes per patient for completed card summary
  final Map<String, String> _consultNotes = {};

  void _markConsulted(String queueId, String notes) => setState(() {
    _consultedIds.add(queueId);
    _consultNotes[queueId] = notes;
  });

  void _markLabSent(String queueId, List<_LabResult> results) => setState(() {
    _labSentIds.add(queueId);
    _patientLabResults[queueId] = results;
  });

  void _completePatient(String queueId, String prescription) {
    final patient = _patients.firstWhere((p) => p.queueId == queueId);
    setState(() {
      _patients.removeWhere((p) => p.queueId == queueId);
      _completed.insert(
        0,
        _CompletedPatient(
          patient: patient,
          consultNotes: _consultNotes[queueId] ?? '',
          prescriptionSummary: prescription,
          labResults: _patientLabResults[queueId] ?? [],
        ),
      );
    });
  }

  List<_LabResult> _labResultsFor(String queueId) =>
      _patientLabResults[queueId] ?? _mockLabResults[queueId] ?? [];

  void _openConsultSheet(_QueuePatient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConsultationSheet(
        patient: patient,
        onConsultComplete: (notes) => _markConsulted(patient.queueId, notes),
      ),
    );
  }

  void _openLabSheet(_QueuePatient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LabSheet(
        patient: patient,
        labAlreadySent: _labSentIds.contains(patient.queueId),
        existingResults: _labResultsFor(patient.queueId),
        onLabSent: (results) => _markLabSent(patient.queueId, results),
        onProceedToPrescribe: () => _openPrescribeSheet(patient),
      ),
    );
  }

  void _openPrescribeSheet(_QueuePatient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrescribeSheet(
        patient: patient,
        labResults: _labResultsFor(patient.queueId),
        onComplete: (prescription) =>
            _completePatient(patient.queueId, prescription),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatsStrip(stats: _stats),
        _TabToggle(
          activeTab: _activeTab,
          activeCount: _patients.length,
          completedCount: _completed.length,
          onTabChanged: (t) => setState(() => _activeTab = t),
        ),
        Expanded(
          child: _activeTab == _QueueTab.active
              ? _ActiveList(
                  patients: _patients,
                  consultedIds: _consultedIds,
                  labSentIds: _labSentIds,
                  onConsult: _openConsultSheet,
                  onLab: _openLabSheet,
                  onPrescribe: _openPrescribeSheet,
                )
              : _CompletedList(completed: _completed),
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AppStatCard(
                    label: 'Today',
                    value: '${stats.todayTotal}',
                    sub: '${stats.todayRemaining} remaining',
                    valueColor: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppStatCard(
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
                  child: AppStatCard(
                    label: 'Pending Labs',
                    value: '${stats.pendingLabs}',
                    valueColor: AppColors.warn,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppStatCard(
                    label: 'Avg. Consult',
                    value: stats.avgConsultMin,
                    valueColor: AppColors.ok,
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

// ─────────────────────────────────────────────
// TAB TOGGLE — Active | Completed
// ─────────────────────────────────────────────

class _TabToggle extends StatelessWidget {
  final _QueueTab activeTab;
  final int activeCount;
  final int completedCount;
  final ValueChanged<_QueueTab> onTabChanged;

  const _TabToggle({
    required this.activeTab,
    required this.activeCount,
    required this.completedCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          _TabPill(
            label: 'Active ($activeCount)',
            active: activeTab == _QueueTab.active,
            onTap: () => onTabChanged(_QueueTab.active),
          ),
          _TabPill(
            label: 'Completed ($completedCount)',
            active: activeTab == _QueueTab.completed,
            onTap: () => onTabChanged(_QueueTab.completed),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.accent : AppColors.ink3,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ACTIVE LIST
// ─────────────────────────────────────────────

class _ActiveList extends StatelessWidget {
  final List<_QueuePatient> patients;
  final Set<String> consultedIds;
  final Set<String> labSentIds;
  final ValueChanged<_QueuePatient> onConsult;
  final ValueChanged<_QueuePatient> onLab;
  final ValueChanged<_QueuePatient> onPrescribe;

  const _ActiveList({
    required this.patients,
    required this.consultedIds,
    required this.labSentIds,
    required this.onConsult,
    required this.onLab,
    required this.onPrescribe,
  });

  @override
  Widget build(BuildContext context) {
    if (patients.isEmpty) return const _EmptyState(tab: _QueueTab.active);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      itemCount: patients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final p = patients[i];
        return _PatientCard(
          patient: p,
          consultDone: consultedIds.contains(p.queueId),
          labSent: labSentIds.contains(p.queueId),
          onConsult: () => onConsult(p),
          onLab: () => onLab(p),
          onPrescribe: () => onPrescribe(p),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// COMPLETED LIST
// ─────────────────────────────────────────────

class _CompletedList extends StatelessWidget {
  final List<_CompletedPatient> completed;
  const _CompletedList({required this.completed});

  @override
  Widget build(BuildContext context) {
    if (completed.isEmpty) return const _EmptyState(tab: _QueueTab.completed);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      itemCount: completed.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _CompletedCard(entry: completed[i]),
    );
  }
}

// ─────────────────────────────────────────────
// PATIENT CARD (active)
// ─────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  final _QueuePatient patient;
  final bool consultDone;
  final bool labSent;
  final VoidCallback onConsult;
  final VoidCallback onLab;
  final VoidCallback onPrescribe;

  const _PatientCard({
    required this.patient,
    required this.consultDone,
    required this.labSent,
    required this.onConsult,
    required this.onLab,
    required this.onPrescribe,
  });

  bool get _isUrgent => patient.severity == _Severity.urgent;

  Color get _leftBorderColor => switch (patient.severity) {
    _Severity.urgent => const Color(0xFFFF4C4C),
    _Severity.moderate => AppColors.warn,
    _Severity.routine => AppColors.ink3,
  };

  Color get _cardBg => _isUrgent ? const Color(0xFF151E2B) : AppColors.surface;
  Color get _nameColor => _isUrgent ? Colors.white : AppColors.ink;
  Color get _metaColor => _isUrgent ? const Color(0xFF8A9BB0) : AppColors.ink3;
  Color get _symptomsColor =>
      _isUrgent ? const Color(0xFFCFD8E3) : AppColors.ink2;

  AppStatus get _chipStatus => switch (patient.severity) {
    _Severity.urgent => AppStatus.err,
    _Severity.moderate => AppStatus.warn,
    _Severity.routine => AppStatus.neutral,
  };

  String get _chipLabel => switch (patient.severity) {
    _Severity.urgent => 'Urgent',
    _Severity.moderate => 'Moderate',
    _Severity.routine => 'Routine',
  };

  void _showLockedNotice(BuildContext context, String action) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 36),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.warnBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.warn,
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Consult first',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Complete the consultation before accessing $action.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.ink2,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink2,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: _leftBorderColor, width: 3.5)),
        boxShadow: [
          BoxShadow(
            color: _isUrgent
                ? Colors.black.withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: _isUrgent ? 16 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // — Top row —
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _nameColor,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${patient.studentId} · #${patient.queueId} · ${patient.timeIn}',
                        style: TextStyle(
                          fontFamily: 'DMMono',
                          fontSize: 10,
                          color: _metaColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AppStatusChip(label: _chipLabel, status: _chipStatus),
              ],
            ),

            // — Symptoms —
            const SizedBox(height: 5),
            Text(
              patient.symptoms,
              style: TextStyle(fontSize: 11.5, color: _symptomsColor),
            ),

            // — AI Assessment (urgent only) —
            if (patient.aiNote != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D3A5C),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xFF2D5278),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 13,
                      color: Color(0xFF7ECFF5),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        patient.aiNote!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFCFD8E3),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // — Action buttons —
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _CardButton(
                    label: consultDone ? 'Consulted ✓' : 'Consult',
                    primary: !consultDone,
                    done: consultDone,
                    isUrgent: _isUrgent,
                    onTap: consultDone ? () {} : onConsult,
                  ),
                ),
                const SizedBox(width: 6),
                _CardButton(
                  label: 'Lab',
                  isUrgent: _isUrgent,
                  labPending: labSent,
                  locked: !consultDone,
                  onTap: consultDone
                      ? onLab
                      : () => _showLockedNotice(context, 'Lab'),
                ),
                const SizedBox(width: 6),
                _CardButton(
                  label: 'Prescribe',
                  isUrgent: _isUrgent,
                  locked: !consultDone,
                  onTap: consultDone
                      ? onPrescribe
                      : () => _showLockedNotice(context, 'Prescribe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  final String label;
  final bool primary;
  final bool locked;
  final bool done;
  final bool labPending;
  final bool isUrgent;
  final VoidCallback onTap;

  const _CardButton({
    required this.label,
    required this.onTap,
    this.primary = false,
    this.locked = false,
    this.done = false,
    this.labPending = false,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color borderColor;
    Color textColor;

    if (primary) {
      bg = AppColors.accent;
      borderColor = AppColors.accent;
      textColor = Colors.white;
    } else if (done) {
      bg = AppColors.okBg;
      borderColor = AppColors.okBorder;
      textColor = AppColors.ok;
    } else if (labPending) {
      bg = AppColors.warnBg;
      borderColor = AppColors.warnBorder;
      textColor = AppColors.warn;
    } else if (locked) {
      bg = isUrgent ? const Color(0xFF1D3A5C) : AppColors.surface2;
      borderColor = isUrgent ? const Color(0xFF2D5278) : AppColors.border;
      textColor = isUrgent ? const Color(0xFF4A6A85) : AppColors.ink3;
    } else {
      bg = isUrgent ? const Color(0xFF1D3A5C) : AppColors.surface2;
      borderColor = isUrgent ? const Color(0xFF2D5278) : AppColors.border;
      textColor = isUrgent ? const Color(0xFFCFD8E3) : AppColors.ink2;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (locked)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 10,
                  color: textColor,
                ),
              ),
            if (labPending)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  size: 10,
                  color: textColor,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COMPLETED CARD (read-only, collapsible)
// ─────────────────────────────────────────────

class _CompletedCard extends StatefulWidget {
  final _CompletedPatient entry;
  const _CompletedCard({required this.entry});

  @override
  State<_CompletedCard> createState() => _CompletedCardState();
}

class _CompletedCardState extends State<_CompletedCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.entry.patient;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: AppColors.ok, width: 3.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '#${p.queueId} · ${p.timeIn}',
                          style: const TextStyle(
                            fontFamily: 'DMMono',
                            fontSize: 10,
                            color: AppColors.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppStatusChip(label: 'Done', status: AppStatus.ok),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: AppColors.ink3,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SheetLabel("Doctor's Notes"),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      widget.entry.consultNotes.isEmpty
                          ? '—'
                          : widget.entry.consultNotes,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.ink2,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _SheetLabel('Prescription'),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accentMid),
                    ),
                    child: Text(
                      widget.entry.prescriptionSummary.isEmpty
                          ? 'No prescription'
                          : widget.entry.prescriptionSummary,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (widget.entry.labResults.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const _SheetLabel('Lab Results'),
                    const SizedBox(height: 6),
                    ...widget.entry.labResults.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: [
                            if (r.flagged)
                              const Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.flag_rounded,
                                  size: 11,
                                  color: AppColors.err,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                r.testName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.ink2,
                                ),
                              ),
                            ),
                            Text(
                              r.value,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: r.flagged ? AppColors.err : AppColors.ok,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final _QueueTab tab;
  const _EmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    final isActive = tab == _QueueTab.active;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive
                ? Icons.check_circle_outline_rounded
                : Icons.history_rounded,
            size: 44,
            color: AppColors.ink3.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            isActive ? 'Queue is clear' : 'No completed consultations',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isActive
                ? 'All patients have been seen.'
                : 'Completed patients will appear here.',
            style: const TextStyle(fontSize: 12, color: AppColors.ink3),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONSULTATION SHEET
// One job: Call In → symptoms + notes → Complete
// ─────────────────────────────────────────────

class _ConsultationSheet extends StatefulWidget {
  final _QueuePatient patient;
  final ValueChanged<String> onConsultComplete; // passes notes back

  const _ConsultationSheet({
    required this.patient,
    required this.onConsultComplete,
  });

  @override
  State<_ConsultationSheet> createState() => _ConsultationSheetState();
}

class _ConsultationSheetState extends State<_ConsultationSheet> {
  bool _calledIn = false;
  late List<String> _confirmedSymptoms;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

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
    super.dispose();
  }

  void _toggleSymptom(String s) => setState(() {
    _confirmedSymptoms.contains(s)
        ? _confirmedSymptoms.remove(s)
        : _confirmedSymptoms.add(s);
  });

  Future<void> _complete() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add diagnostic notes before completing.'),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    // Backend: POST /api/v1/consultations
    // Body: { visit_id, confirmed_symptoms, diagnostic_notes }
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    widget.onConsultComplete(_notesController.text.trim());
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Consultation for ${widget.patient.name} completed.'),
        backgroundColor: AppColors.ok,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            const _SheetHandle(),
            Expanded(
              child: SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SheetHeader(
                      title: 'Consultation',
                      patient: widget.patient,
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 16),

                    if (!_calledIn) ...[
                      AppInfoBox(
                        label: 'Ready to begin',
                        body:
                            'Call the patient in before starting the consultation.',
                        variant: AppInfoVariant.accent,
                      ),
                      const SizedBox(height: 20),
                      _PrimaryButton(
                        label: 'Call In Patient',
                        icon: Icons.person_add_rounded,
                        onTap: () => setState(() => _calledIn = true),
                      ),
                    ],

                    if (_calledIn) ...[
                      const _SheetLabel('Reported Symptoms'),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          widget.patient.symptoms,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.ink2,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      const _SheetLabel('Confirm Symptoms'),
                      const SizedBox(height: 4),
                      const Text(
                        'Select all symptoms present after examination.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.ink3),
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _kSymptoms.map((s) {
                          final on = _confirmedSymptoms.contains(s);
                          return GestureDetector(
                            onTap: () => _toggleSymptom(s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: on
                                    ? AppColors.accentLight
                                    : AppColors.surface2,
                                border: Border.all(
                                  color: on
                                      ? AppColors.accent
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: on ? AppColors.accent : AppColors.ink2,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),
                      const _SheetLabel('Diagnostic Notes'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.ink,
                        ),
                        decoration: _inputDecoration(
                          'Clinical findings, working diagnosis, reasoning…',
                        ),
                      ),

                      const SizedBox(height: 22),
                      _PrimaryButton(
                        label: _isSubmitting
                            ? 'Saving…'
                            : 'Complete Consultation',
                        icon: Icons.check_rounded,
                        loading: _isSubmitting,
                        onTap: _isSubmitting ? () {} : _complete,
                      ),
                      const SizedBox(height: 10),
                      const _CancelButton(),
                    ],
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
// LAB SHEET
// Mode A — no lab sent: test selector + Send button
// Mode B — lab sent: results + status chips
//           all completed → Proceed to Prescribe
// ─────────────────────────────────────────────

class _LabSheet extends StatefulWidget {
  final _QueuePatient patient;
  final bool labAlreadySent;
  final List<_LabResult> existingResults;
  final ValueChanged<List<_LabResult>> onLabSent;
  final VoidCallback onProceedToPrescribe;

  const _LabSheet({
    required this.patient,
    required this.labAlreadySent,
    required this.existingResults,
    required this.onLabSent,
    required this.onProceedToPrescribe,
  });

  @override
  State<_LabSheet> createState() => _LabSheetState();
}

class _LabSheetState extends State<_LabSheet> {
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
  bool _isSending = false;

  bool get _allCompleted =>
      widget.existingResults.isNotEmpty &&
      widget.existingResults.every((r) => r.status == _LabStatus.completed);

  Future<void> _sendRequest() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one test.')),
      );
      return;
    }
    setState(() => _isSending = true);
    // Backend: POST /api/v1/lab-requests
    // Body: { visit_id, test_names: _selected.toList() }
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final results = _selected
        .map(
          (t) => _LabResult(
            testName: t,
            value: 'Pending...',
            flagged: false,
            status: _LabStatus.sent,
          ),
        )
        .toList();

    widget.onLabSent(results);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lab request sent.'),
        backgroundColor: AppColors.ok,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: widget.labAlreadySent ? 0.75 : 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            const _SheetHandle(),
            Expanded(
              child: SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SheetHeader(title: 'Lab', patient: widget.patient),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 16),

                    // ── Mode A: select and send ──
                    if (!widget.labAlreadySent) ...[
                      const _SheetLabel('Select Tests'),
                      const SizedBox(height: 4),
                      const Text(
                        'Choose tests to request from the lab.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.ink3),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: _kTests.map((t) {
                          final on = _selected.contains(t);
                          return GestureDetector(
                            onTap: () => setState(
                              () => on ? _selected.remove(t) : _selected.add(t),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: on
                                    ? AppColors.accentLight
                                    : AppColors.surface2,
                                border: Border.all(
                                  color: on
                                      ? AppColors.accent
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                t,
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
                      const SizedBox(height: 22),
                      _PrimaryButton(
                        label: _isSending ? 'Sending…' : 'Send Lab Request',
                        icon: Icons.send_rounded,
                        loading: _isSending,
                        onTap: _isSending ? () {} : _sendRequest,
                      ),
                      const SizedBox(height: 10),
                      const _CancelButton(),
                    ],

                    // ── Mode B: view results ──
                    if (widget.labAlreadySent) ...[
                      const _SheetLabel('Test Results'),
                      const SizedBox(height: 10),
                      ...widget.existingResults.map(
                        (r) => _LabResultRow(result: r),
                      ),

                      if (_allCompleted) ...[
                        const SizedBox(height: 8),
                        AppInfoBox(
                          label: 'All results in',
                          body:
                              'All lab tests are complete. You can now prescribe.',
                          variant: AppInfoVariant.accent,
                        ),
                        const SizedBox(height: 16),
                        _PrimaryButton(
                          label: 'Proceed to Prescribe',
                          icon: Icons.medication_rounded,
                          onTap: () {
                            Navigator.pop(context);
                            widget.onProceedToPrescribe();
                          },
                        ),
                        const SizedBox(height: 10),
                        const _CancelButton(),
                      ] else ...[
                        const SizedBox(height: 10),
                        AppInfoBox(
                          label: 'Results pending',
                          body:
                              'Some tests are still being processed by the lab.',
                          variant: AppInfoVariant.warn,
                        ),
                        const SizedBox(height: 16),
                        const _CancelButton(),
                      ],
                    ],
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

class _LabResultRow extends StatelessWidget {
  final _LabResult result;
  const _LabResultRow({required this.result});

  String get _statusLabel => switch (result.status) {
    _LabStatus.sent => 'Sent · Awaiting',
    _LabStatus.resultsIn => 'Results In',
    _LabStatus.completed => 'Completed',
  };

  AppStatus get _chipStatus => switch (result.status) {
    _LabStatus.sent => AppStatus.neutral,
    _LabStatus.resultsIn => AppStatus.warn,
    _LabStatus.completed => AppStatus.ok,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.testName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      result.value,
                      style: TextStyle(
                        fontSize: 12,
                        color: result.flagged ? AppColors.err : AppColors.ink2,
                        fontWeight: result.flagged
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (result.flagged) ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.flag_rounded,
                        size: 12,
                        color: AppColors.err,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          AppStatusChip(label: _statusLabel, status: _chipStatus),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRESCRIBE SHEET
// Lab preview at top → prescription fields → Save
// Completing moves patient to completed tab
// ─────────────────────────────────────────────

class _PrescribeSheet extends StatefulWidget {
  final _QueuePatient patient;
  final List<_LabResult> labResults;
  final ValueChanged<String> onComplete; // passes prescription summary

  const _PrescribeSheet({
    required this.patient,
    required this.labResults,
    required this.onComplete,
  });

  @override
  State<_PrescribeSheet> createState() => _PrescribeSheetState();
}

class _PrescribeSheetState extends State<_PrescribeSheet> {
  // Backend: POST /api/v1/prescriptions
  final _medicineController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _medicineController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_medicineController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a medicine name.')));
      return;
    }
    setState(() => _isSubmitting = true);
    // Backend: POST /api/v1/prescriptions
    // Body: { visit_id, medicine_name, dosage, instructions }
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final summary =
        '${_medicineController.text.trim()} · ${_dosageController.text.trim()}';
    widget.onComplete(summary);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prescription for ${widget.patient.name} saved.'),
        backgroundColor: AppColors.ok,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final relevantResults = widget.labResults
        .where((r) => r.status != _LabStatus.sent)
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            const _SheetHandle(),
            Expanded(
              child: SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SheetHeader(title: 'Prescribe', patient: widget.patient),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 16),

                    // ── Lab preview ──
                    const _SheetLabel('Lab Results'),
                    const SizedBox(height: 8),
                    if (relevantResults.isEmpty)
                      AppInfoBox(
                        label: 'No lab results',
                        body:
                            'No labs were requested or results are still pending.',
                        variant: AppInfoVariant.warn,
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: List.generate(relevantResults.length, (i) {
                            final r = relevantResults[i];
                            final isLast = i == relevantResults.length - 1;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                border: isLast
                                    ? null
                                    : const Border(
                                        bottom: BorderSide(
                                          color: AppColors.border,
                                        ),
                                      ),
                              ),
                              child: Row(
                                children: [
                                  if (r.flagged)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: Icon(
                                        Icons.flag_rounded,
                                        size: 12,
                                        color: AppColors.err,
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      r.testName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.ink2,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    r.value,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: r.flagged
                                          ? AppColors.err
                                          : AppColors.ok,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ── Prescription fields ──
                    const _SheetLabel('Prescription'),
                    const SizedBox(height: 10),
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
                      label: "Doctor's Instructions",
                      hint: 'e.g. Take with food. Complete full course.',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 22),
                    _PrimaryButton(
                      label: _isSubmitting ? 'Saving…' : 'Save Prescription',
                      icon: Icons.save_rounded,
                      loading: _isSubmitting,
                      onTap: _isSubmitting ? () {} : _submit,
                    ),
                    const SizedBox(height: 10),
                    const _CancelButton(),
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
// SHARED SHEET COMPONENTS
// ─────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final _QueuePatient patient;

  const _SheetHeader({required this.title, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${patient.name} · #${patient.queueId}',
                style: const TextStyle(fontSize: 12, color: AppColors.ink3),
              ),
            ],
          ),
        ),
        AppStatusChip(
          label: switch (patient.severity) {
            _Severity.urgent => 'Urgent',
            _Severity.moderate => 'Moderate',
            _Severity.routine => 'Routine',
          },
          status: switch (patient.severity) {
            _Severity.urgent => AppStatus.err,
            _Severity.moderate => AppStatus.warn,
            _Severity.routine => AppStatus.neutral,
          },
        ),
      ],
    );
  }
}

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
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: loading
                  ? [AppColors.ink3, AppColors.ink3]
                  : [AppColors.accent, AppColors.accentDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: loading
                ? []
                : [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(icon, color: Colors.white, size: 17),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
            side: const BorderSide(color: AppColors.border, width: 1.5),
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
    );
  }
}

// ─────────────────────────────────────────────
// INPUT DECORATION HELPER
// ─────────────────────────────────────────────

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: AppColors.ink3, fontSize: 12.5),
  filled: true,
  fillColor: AppColors.surface2,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
  ),
  contentPadding: const EdgeInsets.all(12),
);
