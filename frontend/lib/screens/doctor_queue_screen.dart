import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';
import '../services/api_service.dart';

enum _Severity { urgent, moderate, routine }
enum _LabStatus { sent, resultsIn, completed }
enum _QueueTab  { active, completed }

class _QueuePatient {
  final String queueId;
  final int visitId;
  final String name;
  final String studentId;
  final String timeIn;
  final _Severity severity;
  final String symptoms;
  final String? aiNote;

  const _QueuePatient({
    required this.queueId,
    required this.visitId,
    required this.name,
    required this.studentId,
    required this.timeIn,
    required this.severity,
    required this.symptoms,
    this.aiNote,
  });
}

class _LabResult {
  final String testName;
  final String value;
  final bool flagged;
  final _LabStatus status;

  const _LabResult({
    required this.testName,
    required this.value,
    required this.flagged,
    required this.status,
  });
}

class _CompletedPatient {
  final _QueuePatient patient;
  final String consultNotes;
  final String prescriptionSummary;
  final List<_LabResult> labResults;

  const _CompletedPatient({
    required this.patient,
    required this.consultNotes,
    required this.prescriptionSummary,
    required this.labResults,
  });
}

class _DashStats {
  final int todayTotal;
  final int todayRemaining;
  final int inQueue;
  final int urgentCount;
  final int pendingLabs;
  final String avgConsultMin;

  const _DashStats({
    required this.todayTotal,
    required this.todayRemaining,
    required this.inQueue,
    required this.urgentCount,
    required this.pendingLabs,
    required this.avgConsultMin,
  });
}

final _mockLabResults = <String, List<_LabResult>>{};
//final _mockCompleted  = <_CompletedPatient>[];

class DoctorQueueScreen extends StatefulWidget {
  const DoctorQueueScreen({super.key});

  @override
  State<DoctorQueueScreen> createState() => _DoctorQueueScreenState();
}

class _DoctorQueueScreenState extends State<DoctorQueueScreen> {
  bool _isLoading = true;

  int    _todayTotal     = 0;
  int    _todayRemaining = 0;
  int    _pendingLabs    = 0;
  String _avgConsult     = '—';

  _DashStats get _stats => _DashStats(
    todayTotal:    _todayTotal,
    todayRemaining: _todayRemaining,
    inQueue:       _patients.length,
    urgentCount:   _patients.where((p) => p.severity == _Severity.urgent).length,
    pendingLabs:   _pendingLabs,
    avgConsultMin: _avgConsult,
  );

  List<_QueuePatient>     _patients  = [];
  List<_CompletedPatient> _completed = [];

  _QueueTab _activeTab = _QueueTab.active;

  final Set<String>                   _consultedIds      = {};
  final Set<String>                   _labSentIds        = {};
  final Map<String, List<_LabResult>> _patientLabResults = {};
  final Map<String, String>           _consultNotes      = {};

  @override
  void initState() {
    super.initState();
    _loadQueue();
    _loadDashboardStats();
  }

  Future<void> _loadQueue() async {
    try {
      final data  = await ApiService().getQueue();
      final List queue = data['queue'] ?? [];

      final patients = queue.map<_QueuePatient>((item) {
        final severityStr = (item['queue_category'] ?? 'MINOR').toString().toUpperCase();
        final severity = severityStr == 'SEVERE'
            ? _Severity.urgent
            : severityStr == 'MODERATE'
            ? _Severity.moderate
            : _Severity.routine;

        final symptomsList  = item['symptoms'] as List? ?? [];
        final otherSymptoms = (item['doctor_note'] ?? '').toString();
        final symptomsStr   = [
          if (symptomsList.isNotEmpty) symptomsList.join(', '),
          if (otherSymptoms.isNotEmpty) otherSymptoms,
        ].join(' · ');

        final createdAt = item['created_at'] ?? '';
        String timeIn = '';
        if (createdAt.isNotEmpty) {
          try {
            final dt     = DateTime.parse(createdAt).toLocal();
            final h      = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
            final m      = dt.minute.toString().padLeft(2, '0');
            final period = dt.hour >= 12 ? 'PM' : 'AM';
            timeIn = '$h:$m $period';
          } catch (_) { timeIn = createdAt; }
        }

        return _QueuePatient(
          queueId:   '#${item['queue_position'] ?? '?'}',
          visitId:   item['id'] ?? 0,
          name:      item['patient_name'] ?? 'Unknown',
          studentId: item['reg_no'] ?? '',
          timeIn:    timeIn,
          severity:  severity,
          symptoms:  symptomsStr,
          aiNote:    item['doctor_note']?.toString().isNotEmpty == true
                       ? item['doctor_note'].toString()
                       : null,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _patients  = patients;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final data = await ApiService().getDoctorDashboard();
      if (!mounted) return;
      setState(() {
        _todayTotal     = data['seen_today']   ?? 0;
        _todayRemaining = data['in_queue']     ?? 0;
        _avgConsult     = data['avg_consult']  ?? '—';
        _pendingLabs    = data['pending_labs'] ?? 0;
      });
    } catch (_) {}
  }

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
      _completed.insert(0, _CompletedPatient(
        patient:             patient,
        consultNotes:        _consultNotes[queueId] ?? '',
        prescriptionSummary: prescription,
        labResults:          _patientLabResults[queueId] ?? [],
      ));
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
        consultNotes: _consultNotes[patient.queueId] ?? '',
        onComplete: (prescription) => _completePatient(patient.queueId, prescription),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

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

class _StatsStrip extends StatelessWidget {
  final _DashStats stats;
  const _StatsStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 4),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: AppStatCard(label: 'Today',    value: '${stats.todayTotal}', sub: '${stats.todayRemaining} remaining', valueColor: AppColors.accent)),
                const SizedBox(width: 10),
                Expanded(child: AppStatCard(label: 'In Queue', value: '${stats.inQueue}',    sub: '${stats.urgentCount} urgent')),
              ],
            ),
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: AppStatCard(label: 'Pending Labs', value: '${stats.pendingLabs}', valueColor: AppColors.warn)),
                const SizedBox(width: 10),
                Expanded(child: AppStatCard(label: 'Avg. Consult', value: stats.avgConsultMin,    valueColor: AppColors.ok)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
        border: Border(top: BorderSide(color: AppColors.border), bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _TabPill(label: 'Active ($activeCount)',       active: activeTab == _QueueTab.active,    onTap: () => onTabChanged(_QueueTab.active)),
          _TabPill(label: 'Completed ($completedCount)', active: activeTab == _QueueTab.completed, onTap: () => onTabChanged(_QueueTab.completed)),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabPill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: active ? AppColors.accent : Colors.transparent, width: 2)),
          ),
          child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? AppColors.accent : AppColors.ink3)),
        ),
      ),
    );
  }
}

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
    _Severity.urgent   => const Color(0xFFFF4C4C),
    _Severity.moderate => AppColors.warn,
    _Severity.routine  => AppColors.ink3,
  };

  Color get _cardBg        => _isUrgent ? const Color(0xFF151E2B) : AppColors.surface;
  Color get _nameColor     => _isUrgent ? Colors.white : AppColors.ink;
  Color get _metaColor     => _isUrgent ? const Color(0xFF8A9BB0) : AppColors.ink3;
  Color get _symptomsColor => _isUrgent ? const Color(0xFFCFD8E3) : AppColors.ink2;

  AppStatus get _chipStatus => switch (patient.severity) {
    _Severity.urgent   => AppStatus.err,
    _Severity.moderate => AppStatus.warn,
    _Severity.routine  => AppStatus.neutral,
  };

  String get _chipLabel => switch (patient.severity) {
    _Severity.urgent   => 'Urgent',
    _Severity.moderate => 'Moderate',
    _Severity.routine  => 'Routine',
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 32, offset: const Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 48, height: 48,
                decoration: const BoxDecoration(color: AppColors.warnBg, shape: BoxShape.circle),
                child: const Icon(Icons.lock_outline_rounded, color: AppColors.warn, size: 24)),
              const SizedBox(height: 14),
              const Text('Consult first', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 6),
              Text('Complete the consultation before accessing $action.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: AppColors.ink2, height: 1.5)),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(50), border: Border.all(color: AppColors.border)),
                  child: const Text('Got it', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink2)),
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
        boxShadow: [BoxShadow(
          color: _isUrgent ? Colors.black.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.06),
          blurRadius: _isUrgent ? 16 : 8, offset: const Offset(0, 3),
        )],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _nameColor)),
                      const SizedBox(height: 1),
                      Text('${patient.studentId} · ${patient.queueId} · ${patient.timeIn}',
                        style: TextStyle(fontFamily: 'DMMono', fontSize: 10, color: _metaColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AppStatusChip(label: _chipLabel, status: _chipStatus),
              ],
            ),
            const SizedBox(height: 5),
            Text(patient.symptoms, style: TextStyle(fontSize: 11.5, color: _symptomsColor)),
            if (patient.aiNote != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D3A5C),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: const Color(0xFF2D5278), width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 13, color: Color(0xFF7ECFF5)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(patient.aiNote!, style: const TextStyle(fontSize: 11, color: Color(0xFFCFD8E3), height: 1.45))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _CardButton(
                    label: consultDone ? 'Consulted ✓' : 'Consult',
                    primary: !consultDone, done: consultDone, isUrgent: _isUrgent,
                    onTap: consultDone ? () {} : onConsult,
                  ),
                ),
                const SizedBox(width: 6),
                _CardButton(label: 'Lab',       isUrgent: _isUrgent, labPending: labSent, locked: !consultDone, onTap: consultDone ? onLab      : () => _showLockedNotice(context, 'Lab')),
                const SizedBox(width: 6),
                _CardButton(label: 'Prescribe', isUrgent: _isUrgent,                      locked: !consultDone, onTap: consultDone ? onPrescribe : () => _showLockedNotice(context, 'Prescribe')),
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
    Color bg, borderColor, textColor;

    if (primary) {
      bg = AppColors.accent; borderColor = AppColors.accent; textColor = Colors.white;
    } else if (done) {
      bg = AppColors.okBg; borderColor = AppColors.okBorder; textColor = AppColors.ok;
    } else if (labPending) {
      bg = AppColors.warnBg; borderColor = AppColors.warnBorder; textColor = AppColors.warn;
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
        decoration: BoxDecoration(color: bg, border: Border.all(color: borderColor, width: 1.5), borderRadius: BorderRadius.circular(50)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (locked)     Padding(padding: const EdgeInsets.only(right: 4), child: Icon(Icons.lock_outline_rounded,  size: 10, color: textColor)),
            if (labPending) Padding(padding: const EdgeInsets.only(right: 4), child: Icon(Icons.hourglass_top_rounded, size: 10, color: textColor)),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
          ],
        ),
      ),
    );
  }
}

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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
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
                        Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        const SizedBox(height: 1),
                        Text('${p.queueId} · ${p.timeIn}', style: const TextStyle(fontFamily: 'DMMono', fontSize: 10, color: AppColors.ink3)),
                      ],
                    ),
                  ),
                  AppStatusChip(label: 'Done', status: AppStatus.ok),
                  const SizedBox(width: 8),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 18, color: AppColors.ink3),
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
                    width: double.infinity, padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                    child: Text(widget.entry.consultNotes.isEmpty ? '—' : widget.entry.consultNotes,
                      style: const TextStyle(fontSize: 12, color: AppColors.ink2, height: 1.5)),
                  ),
                  const SizedBox(height: 10),
                  const _SheetLabel('Prescription'),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.accentMid)),
                    child: Text(widget.entry.prescriptionSummary.isEmpty ? 'No prescription' : widget.entry.prescriptionSummary,
                      style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600, height: 1.5)),
                  ),
                  if (widget.entry.labResults.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const _SheetLabel('Lab Results'),
                    const SizedBox(height: 6),
                    ...widget.entry.labResults.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          if (r.flagged) const Padding(padding: EdgeInsets.only(right: 5), child: Icon(Icons.flag_rounded, size: 11, color: AppColors.err)),
                          Expanded(child: Text(r.testName, style: const TextStyle(fontSize: 12, color: AppColors.ink2))),
                          Text(r.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: r.flagged ? AppColors.err : AppColors.ok)),
                        ],
                      ),
                    )),
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
          Icon(isActive ? Icons.check_circle_outline_rounded : Icons.history_rounded,
            size: 44, color: AppColors.ink3.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(isActive ? 'Queue is clear' : 'No completed consultations',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink3)),
          const SizedBox(height: 4),
          Text(isActive ? 'All patients have been seen.' : 'Completed patients will appear here.',
            style: const TextStyle(fontSize: 12, color: AppColors.ink3)),
        ],
      ),
    );
  }
}

class _ConsultationSheet extends StatefulWidget {
  final _QueuePatient patient;
  final ValueChanged<String> onConsultComplete;

  const _ConsultationSheet({required this.patient, required this.onConsultComplete});

  @override
  State<_ConsultationSheet> createState() => _ConsultationSheetState();
}

class _ConsultationSheetState extends State<_ConsultationSheet> {
  bool _calledIn = false;
  late List<String> _confirmedSymptoms;
  final _notesController     = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _bpSysController     = TextEditingController();
  final _bpDiaController     = TextEditingController();
  final _tempController      = TextEditingController();
  final _weightController    = TextEditingController();
  final _heightController    = TextEditingController();
  bool _isSubmitting = false;

  static const _kSymptoms = [
    'Fever', 'Cough', 'Headache', 'Nausea', 'Fatigue', 'Chills',
    'Body aches', 'Diarrhoea', 'Chest pain', 'Breathlessness',
    'Vomiting', 'Loss of appetite', 'Joint pain', 'Rash',
  ];

  @override
  void initState() {
    super.initState();
    _confirmedSymptoms = widget.patient.symptoms
        .split(RegExp(r'[,·\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) {
          final match = _kSymptoms.firstWhere(
            (k) => k.toLowerCase() == s.toLowerCase(),
            orElse: () => '',
          );
          return match;
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _diagnosisController.dispose();
    _bpSysController.dispose();
    _bpDiaController.dispose();
    _tempController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _toggleSymptom(String s) => setState(() {
    _confirmedSymptoms.contains(s) ? _confirmedSymptoms.remove(s) : _confirmedSymptoms.add(s);
  });

  Future<void> _complete() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add diagnostic notes before completing.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ApiService().submitConsultation(
        visitId:       widget.patient.visitId,
        doctorStaffId: ApiService.currentStaffId ?? '',
        clinicalNotes: _notesController.text.trim(),
        diagnosis:     _diagnosisController.text.trim().isEmpty
                         ? 'PENDING LAB RESULTS'
                         : _diagnosisController.text.trim(),
        bpSystolic:    int.tryParse(_bpSysController.text),
        bpDiastolic:   int.tryParse(_bpDiaController.text),
        temperature:   double.tryParse(_tempController.text),
        weight:        double.tryParse(_weightController.text),
        height:        double.tryParse(_heightController.text),
      );
      if (!mounted) return;
      widget.onConsultComplete(_notesController.text.trim());
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Consultation for ${widget.patient.name} completed.'),
        backgroundColor: AppColors.ok,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed: ${e.toString()}'),
        backgroundColor: AppColors.err,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
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
                    _SheetHeader(title: 'Consultation', patient: widget.patient),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 16),

                    if (!_calledIn) ...[
                      AppInfoBox(label: 'Ready to begin', body: 'Call the patient in before starting the consultation.', variant: AppInfoVariant.accent),
                      const SizedBox(height: 20),
                      _PrimaryButton(label: 'Call In Patient', icon: Icons.person_add_rounded, onTap: () => setState(() => _calledIn = true)),
                    ],

                    if (_calledIn) ...[
                      const _SheetLabel('Reported Symptoms'),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(color: AppColors.surface2, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(9)),
                        child: Text(widget.patient.symptoms, style: const TextStyle(fontSize: 12.5, color: AppColors.ink2, height: 1.5)),
                      ),
                      const SizedBox(height: 16),
                      const _SheetLabel('Confirm Symptoms'),
                      const SizedBox(height: 4),
                      const Text('Select all symptoms present after examination.', style: TextStyle(fontSize: 11.5, color: AppColors.ink3)),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6, runSpacing: 6,
                        children: _kSymptoms.map((s) {
                          final on = _confirmedSymptoms.contains(s);
                          return GestureDetector(
                            onTap: () => _toggleSymptom(s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: on ? AppColors.accentLight : AppColors.surface2,
                                border: Border.all(color: on ? AppColors.accent : AppColors.border, width: 1.5),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(s, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: on ? AppColors.accent : AppColors.ink2)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const _SheetLabel('Diagnostic Notes'),
                      const SizedBox(height: 6),
                      TextField(controller: _notesController, maxLines: 4, style: const TextStyle(fontSize: 13, color: AppColors.ink), decoration: _inputDecoration('Clinical findings, working diagnosis, reasoning…')),
                      const SizedBox(height: 16),
                      const _SheetLabel('Diagnosis'),
                      const SizedBox(height: 4),
                      const Text('Leave blank if awaiting lab results.', style: TextStyle(fontSize: 11.5, color: AppColors.ink3)),
                      const SizedBox(height: 6),
                      TextField(controller: _diagnosisController, maxLines: 2, style: const TextStyle(fontSize: 13, color: AppColors.ink), decoration: _inputDecoration('e.g. Malaria, Pending Lab Results...')),
                      const SizedBox(height: 16),
                      const _SheetLabel('Vitals'),
                      const SizedBox(height: 4),
                      const Text('Optional — record if measured during consultation.', style: TextStyle(fontSize: 11.5, color: AppColors.ink3)),
                      const SizedBox(height: 9),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _VitalsField(label: 'BP Systolic',  hint: '120', unit: 'mmHg', controller: _bpSysController,  keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(child: _VitalsField(label: 'BP Diastolic', hint: '80',  unit: 'mmHg', controller: _bpDiaController,  keyboardType: TextInputType.number)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _VitalsField(label: 'Temperature', hint: '36.5', unit: '°C', controller: _tempController,   keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(child: _VitalsField(label: 'Weight',      hint: '70',   unit: 'kg', controller: _weightController, keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(child: _VitalsField(label: 'Height',      hint: '170',  unit: 'cm', controller: _heightController, keyboardType: TextInputType.number)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _PrimaryButton(
                        label: _isSubmitting ? 'Saving…' : 'Complete Consultation',
                        icon: Icons.check_rounded, loading: _isSubmitting,
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
// LAB SHEET — now loads tests from API
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
  // ── loaded from GET /api/consultation/lab-tests/ ──
  List<Map<String, dynamic>> _availableTests = [];
  bool _testsLoading = true;
  final Set<String> _selected           = {};
  final _customTestController           = TextEditingController();
  bool _isSending = false;

  // ── hardcoded fallback if API fails ──
  static const _kFallbackTests = [
    {'name': 'Malaria RDT',     'input_type': 'BOOLEAN'},
    {'name': 'FBC',             'input_type': 'NUMBER',  'unit': 'cells/μL'},
    {'name': 'Typhoid (Widal)', 'input_type': 'BOOLEAN'},
    {'name': 'Haemoglobin',     'input_type': 'NUMBER',  'unit': 'g/dL'},
    {'name': 'Blood Glucose',   'input_type': 'NUMBER',  'unit': 'mmol/L'},
    {'name': 'Urine R/E',       'input_type': 'BOOLEAN'},
    {'name': 'Stool R/E',       'input_type': 'TEXT'},
    {'name': 'Liver Function',  'input_type': 'NUMBER',  'unit': 'U/L'},
  ];

  bool get _allCompleted =>
      widget.existingResults.isNotEmpty &&
      widget.existingResults.every((r) => r.status == _LabStatus.completed);

  @override
  void initState() {
    super.initState();
    _loadLabTests();
  }

  @override
  void dispose() {
    _customTestController.dispose();
    super.dispose();
  }

  // ── GET /api/consultation/lab-tests/ ──
  Future<void> _loadLabTests() async {
    try {
      final data = await ApiService().getLabTests();
      if (!mounted) return;
      setState(() {
        _availableTests = data.map<Map<String, dynamic>>((t) => {
          'name':            t['name'],
          'unit':            t['unit'],
          'reference_range': t['reference_range'],
          'input_type':      t['input_type'] ?? 'TEXT',
        }).toList();
        _testsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _availableTests = List<Map<String, dynamic>>.from(_kFallbackTests);
        _testsLoading   = false;
      });
    }
  }

  Future<void> _sendRequest() async {
    final customTests = _customTestController.text.trim();
    if (_selected.isEmpty && customTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select or type at least one test.')));
      return;
    }
    setState(() => _isSending = true);
    try {
      final allTests = [
        ..._selected,
        if (customTests.isNotEmpty) customTests,
      ].join(', ');

      await ApiService().sendLabRequest(
        visitId:        widget.patient.visitId,
        testsRequested: allTests,
      );
      if (!mounted) return;
      final results = [
        ..._selected,
        if (customTests.isNotEmpty) customTests,
      ].map((t) => _LabResult(testName: t, value: 'Pending...', flagged: false, status: _LabStatus.sent)).toList();
      widget.onLabSent(results);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lab request sent.'), backgroundColor: AppColors.ok));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${e.toString()}'), backgroundColor: AppColors.err));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: widget.labAlreadySent ? 0.75 : 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
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
                      const Text('Choose tests to request from the lab.', style: TextStyle(fontSize: 11.5, color: AppColors.ink3)),
                      const SizedBox(height: 10),

                      // ── dynamic chips from API ──
                      if (_testsLoading)
                        const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ))
                      else
                        Wrap(
                          spacing: 7, runSpacing: 7,
                          children: _availableTests.map((t) {
                            final name = t['name'] as String;
                            final on   = _selected.contains(name);
                            return GestureDetector(
                              onTap: () => setState(() => on ? _selected.remove(name) : _selected.add(name)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: on ? AppColors.accentLight : AppColors.surface2,
                                  border: Border.all(color: on ? AppColors.accent : AppColors.border, width: 1.5),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: on ? AppColors.accent : AppColors.ink2)),
                              ),
                            );
                          }).toList(),
                        ),

                      // ── free text field for custom tests ──
                      const SizedBox(height: 14),
                      const _SheetLabel('Other Tests (optional)'),
                      const SizedBox(height: 4),
                      const Text('Type any additional tests not in the list above.', style: TextStyle(fontSize: 11.5, color: AppColors.ink3)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _customTestController,
                        style: const TextStyle(fontSize: 13, color: AppColors.ink),
                        decoration: _inputDecoration('e.g. ECG, X-Ray, Blood Culture...'),
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
                      ...widget.existingResults.map((r) => _LabResultRow(result: r)),
                      if (_allCompleted) ...[
                        const SizedBox(height: 8),
                        AppInfoBox(label: 'All results in', body: 'All lab tests are complete. You can now prescribe.', variant: AppInfoVariant.accent),
                        const SizedBox(height: 16),
                        _PrimaryButton(label: 'Proceed to Prescribe', icon: Icons.medication_rounded, onTap: () { Navigator.pop(context); widget.onProceedToPrescribe(); }),
                        const SizedBox(height: 10),
                        const _CancelButton(),
                      ] else ...[
                        const SizedBox(height: 10),
                        AppInfoBox(label: 'Results pending', body: 'Some tests are still being processed by the lab.', variant: AppInfoVariant.warn),
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
    _LabStatus.sent      => 'Sent · Awaiting',
    _LabStatus.resultsIn => 'Results In',
    _LabStatus.completed => 'Completed',
  };

  AppStatus get _chipStatus => switch (result.status) {
    _LabStatus.sent      => AppStatus.neutral,
    _LabStatus.resultsIn => AppStatus.warn,
    _LabStatus.completed => AppStatus.ok,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.testName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(result.value, style: TextStyle(fontSize: 12, color: result.flagged ? AppColors.err : AppColors.ink2, fontWeight: result.flagged ? FontWeight.w600 : FontWeight.normal)),
                    if (result.flagged) ...[const SizedBox(width: 5), const Icon(Icons.flag_rounded, size: 12, color: AppColors.err)],
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

class _PrescribeSheet extends StatefulWidget {
  final _QueuePatient patient;
  final List<_LabResult> labResults;
  final ValueChanged<String> onComplete;
  final String consultNotes;

  const _PrescribeSheet({
    required this.patient,
    required this.labResults,
    required this.onComplete,
    required this.consultNotes,
  });

  @override
  State<_PrescribeSheet> createState() => _PrescribeSheetState();
}

class _PrescribeSheetState extends State<_PrescribeSheet> {
  final _medicineController     = TextEditingController();
  final _dosageController       = TextEditingController();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a medicine name.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ApiService().createPrescriptions(
        visitId: widget.patient.visitId,
        prescriptions: [
          {
            'medicine_name': _medicineController.text.trim(),
            'dosage':        _dosageController.text.trim(),
            'duration':      '',
            'instructions':  _instructionsController.text.trim(),
          }
        ],
      );
      if (!mounted) return;
      final summary = '${_medicineController.text.trim()} · ${_dosageController.text.trim()}';
      widget.onComplete(summary);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Prescription for ${widget.patient.name} saved.'),
        backgroundColor: AppColors.ok,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${e.toString()}'), backgroundColor: AppColors.err));
    }
  }

  @override
  Widget build(BuildContext context) {
    final relevantResults = widget.labResults.where((r) => r.status != _LabStatus.sent).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.88, minChildSize: 0.6, maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
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
                    const _SheetLabel('Lab Results'),
                    const SizedBox(height: 8),
                    if (relevantResults.isEmpty)
                      AppInfoBox(label: 'No lab results', body: 'No labs were requested or results are still pending.', variant: AppInfoVariant.warn)
                    else
                      Container(
                        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                        child: Column(
                          children: List.generate(relevantResults.length, (i) {
                            final r      = relevantResults[i];
                            final isLast = i == relevantResults.length - 1;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
                              child: Row(
                                children: [
                                  if (r.flagged) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.flag_rounded, size: 12, color: AppColors.err)),
                                  Expanded(child: Text(r.testName, style: const TextStyle(fontSize: 12, color: AppColors.ink2))),
                                  Text(r.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: r.flagged ? AppColors.err : AppColors.ok)),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const _SheetLabel('Prescription'),
                    const SizedBox(height: 10),
                    _SheetInput(controller: _medicineController, label: 'Medicine Name',       hint: 'e.g. Artemether-Lumefantrine 80/480mg'),
                    const SizedBox(height: 10),
                    _SheetInput(controller: _dosageController,   label: 'Dosage & Schedule',  hint: 'e.g. 4 tablets at 0h, 8h, 24h, 36h, 48h, 60h'),
                    const SizedBox(height: 10),
                    _SheetInput(controller: _instructionsController, label: "Doctor's Instructions", hint: 'e.g. Take with food. Complete full course.', maxLines: 3),
                    const SizedBox(height: 22),
                    _PrimaryButton(
                      label: _isSubmitting ? 'Saving…' : 'Save Prescription',
                      icon: Icons.save_rounded, loading: _isSubmitting,
                      onTap: _isSubmitting ? () {} : _submit,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        widget.onComplete(widget.consultNotes.isEmpty ? '' : widget.consultNotes);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${widget.patient.name} completed — no prescription.'),
                          backgroundColor: AppColors.ok,
                        ));
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(50), border: Border.all(color: AppColors.border)),
                        child: const Text('No Prescription Needed', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink2)),
                      ),
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

// ── Shared sheet components ──

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      width: 38, height: 4,
      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
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
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 2),
              Text('${patient.name} · ${patient.queueId}', style: const TextStyle(fontSize: 12, color: AppColors.ink3)),
            ],
          ),
        ),
        AppStatusChip(
          label: switch (patient.severity) {
            _Severity.urgent   => 'Urgent',
            _Severity.moderate => 'Moderate',
            _Severity.routine  => 'Routine',
          },
          status: switch (patient.severity) {
            _Severity.urgent   => AppStatus.err,
            _Severity.moderate => AppStatus.warn,
            _Severity.routine  => AppStatus.neutral,
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
    return Text(text.toUpperCase(), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.07 * 10.5));
  }
}

class _SheetInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  const _SheetInput({required this.controller, required this.label, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SheetLabel(label),
        const SizedBox(height: 6),
        TextField(controller: controller, maxLines: maxLines, style: const TextStyle(fontSize: 13, color: AppColors.ink), decoration: _inputDecoration(hint)),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.icon, required this.onTap, this.loading = false});

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
              colors: loading ? [AppColors.ink3, AppColors.ink3] : [AppColors.accent, AppColors.accentDark],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: loading ? [] : [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading) const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              else Icon(icon, color: Colors.white, size: 17),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9), side: const BorderSide(color: AppColors.border, width: 1.5)),
        ),
        child: const Text('Cancel', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink3)),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: AppColors.ink3, fontSize: 12.5),
  filled: true,
  fillColor: AppColors.surface2,
  border:        OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
  contentPadding: const EdgeInsets.all(12),
);

class _VitalsField extends StatelessWidget {
  final String label;
  final String hint;
  final String unit;
  final TextEditingController controller;
  final TextInputType keyboardType;
  const _VitalsField({required this.label, required this.hint, required this.unit, required this.controller, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.4)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint, suffixText: unit,
            suffixStyle: const TextStyle(fontSize: 11, color: AppColors.ink3, fontFamily: 'DMMono'),
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.ink3),
            filled: true, fillColor: AppColors.surface2,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border:        OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: AppColors.accent, width: 1.5)),
          ),
        ),
      ],
    );
  }
}