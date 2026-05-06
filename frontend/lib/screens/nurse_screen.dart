// lib/screens/nurse_screen.dart
// Nurse Station — Queue · Follow-ups · Education
// Backend: GET /api/v1/queue?role=nurse, GET /api/v1/followups, POST /api/v1/nurse/notes

import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

enum _NurseTab { queue, followUps, education }

enum _Severity { urgent, moderate, routine }

class _QueuePatient {
  final String queueId;
  final String name;
  final String studentId;
  final String timeIn;
  final String symptoms;
  final _Severity severity;
  final String? aiNote;
  // Backend: GET /api/v1/queue?role=nurse

  const _QueuePatient({
    required this.queueId,
    required this.name,
    required this.studentId,
    required this.timeIn,
    required this.symptoms,
    required this.severity,
    this.aiNote,
  });
}

class _FollowUpPatient {
  final String name;
  final String studentId;
  final String dueDate;
  final String doctorNote;
  final bool completed;
  // Backend: GET /api/v1/followups

  const _FollowUpPatient({
    required this.name,
    required this.studentId,
    required this.dueDate,
    required this.doctorNote,
    required this.completed,
  });
}

class _EducationNote {
  final String patientName;
  final String studentId;
  final String topic;
  final String note;
  final String date;
  // Backend: GET /api/v1/nurse/education-notes

  const _EducationNote({
    required this.patientName,
    required this.studentId,
    required this.topic,
    required this.note,
    required this.date,
  });
}

class _NurseStats {
  final int inQueue;
  final int urgentCount;
  final int pendingFollowUps;
  final int roomsOccupied;
  // Backend: GET /api/v1/queue/stats?role=nurse

  const _NurseStats({
    required this.inQueue,
    required this.urgentCount,
    required this.pendingFollowUps,
    required this.roomsOccupied,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────

const _mockStats = _NurseStats(
  inQueue: 6,
  urgentCount: 1,
  pendingFollowUps: 3,
  roomsOccupied: 2,
);

const _mockQueue = [
  _QueuePatient(
    queueId: '014',
    name: 'Amina Nakato',
    studentId: 'STU-2024-0112',
    timeIn: '09:14',
    symptoms: 'Fever, sore throat, fatigue',
    severity: _Severity.urgent,
    aiNote: 'Possible tonsillitis. Flagged for doctor review.',
  ),
  _QueuePatient(
    queueId: '015',
    name: 'Ibrahim Ssekandi',
    studentId: 'STU-2024-0334',
    timeIn: '09:31',
    symptoms: 'Mild headache, nausea',
    severity: _Severity.moderate,
  ),
  _QueuePatient(
    queueId: '016',
    name: 'Fatuma Wanjiru',
    studentId: 'STU-2024-0521',
    timeIn: '09:45',
    symptoms: 'Routine checkup',
    severity: _Severity.routine,
  ),
];

const _mockFollowUps = [
  _FollowUpPatient(
    name: 'Omar Kato',
    studentId: 'STU-2024-0089',
    dueDate: 'Today',
    doctorNote: 'Check wound dressing on right arm. Re-bandage if needed.',
    completed: false,
  ),
  _FollowUpPatient(
    name: 'Halima Abubakar',
    studentId: 'STU-2024-0203',
    dueDate: 'Today',
    doctorNote: 'Confirm patient completed malaria medication course.',
    completed: false,
  ),
  _FollowUpPatient(
    name: 'Yusuf Mugisha',
    studentId: 'STU-2024-0418',
    dueDate: 'Yesterday',
    doctorNote: 'Blood pressure recheck after medication adjustment.',
    completed: true,
  ),
];

const _mockEducationNotes = [
  _EducationNote(
    patientName: 'Amina Nakato',
    studentId: 'STU-2024-0112',
    topic: 'Hydration & Rest',
    note: 'Advised patient to increase fluid intake and rest for 48 hours.',
    date: 'Today',
  ),
  _EducationNote(
    patientName: 'Ibrahim Ssekandi',
    studentId: 'STU-2024-0334',
    topic: 'Stress Management',
    note:
        'Discussed link between exam stress and recurring headaches. Referred to counselling.',
    date: 'Today',
  ),
];

const _roomOptions = ['Room 1', 'Room 2', 'Room 3', 'Waiting'];

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class NurseScreen extends StatefulWidget {
  const NurseScreen({super.key});

  @override
  State<NurseScreen> createState() => _NurseScreenState();
}

class _NurseScreenState extends State<NurseScreen> {
  _NurseTab _activeTab = _NurseTab.queue;
  final _NurseStats _stats = _mockStats;
  final List<_QueuePatient> _queue = List.of(_mockQueue);
  final List<_FollowUpPatient> _followUps = List.of(_mockFollowUps);
  final List<_EducationNote> _educationNotes = List.of(_mockEducationNotes);
  final Map<String, String> _roomAssignments = {};
  final Set<String> _triageNoted = {};

  void _assignRoom(String queueId, String room) =>
      setState(() => _roomAssignments[queueId] = room);

  void _markTriageNote(String queueId) =>
      setState(() => _triageNoted.add(queueId));

  void _toggleFollowUp(int index) {
    setState(() {
      final f = _followUps[index];
      _followUps[index] = _FollowUpPatient(
        name: f.name,
        studentId: f.studentId,
        dueDate: f.dueDate,
        doctorNote: f.doctorNote,
        completed: !f.completed,
      );
    });
  }

  void _showTriageSheet(BuildContext context, _QueuePatient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TriageSheet(
        patient: patient,
        assignedRoom: _roomAssignments[patient.queueId],
        onRoomSelected: (r) => _assignRoom(patient.queueId, r),
        onNoteSaved: () => _markTriageNote(patient.queueId),
      ),
    );
  }

  void _showAddEducationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEducationSheet(
        onSave: (note) => setState(() => _educationNotes.insert(0, note)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _NurseStatsStrip(stats: _stats),
          _NurseTabToggle(
            activeTab: _activeTab,
            queueCount: _queue.length,
            followUpCount: _followUps.where((f) => !f.completed).length,
            educationCount: _educationNotes.length,
            onTabChanged: (t) => setState(() => _activeTab = t),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() => switch (_activeTab) {
    _NurseTab.queue => _QueueList(
      patients: _queue,
      roomAssignments: _roomAssignments,
      triageNoted: _triageNoted,
      onTriage: (p) => _showTriageSheet(context, p),
    ),
    _NurseTab.followUps => _FollowUpList(
      followUps: _followUps,
      onToggle: _toggleFollowUp,
    ),
    _NurseTab.education => _EducationList(
      notes: _educationNotes,
      onAdd: () => _showAddEducationSheet(context),
    ),
  };
}

// ─────────────────────────────────────────────
// STATS STRIP
// ─────────────────────────────────────────────

class _NurseStatsStrip extends StatelessWidget {
  final _NurseStats stats;
  const _NurseStatsStrip({required this.stats});

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
                    label: 'In Queue',
                    value: '${stats.inQueue}',
                    sub: '${stats.urgentCount} urgent',
                    valueColor: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppStatCard(
                    label: 'Follow-ups',
                    value: '${stats.pendingFollowUps}',
                    sub: 'pending today',
                    valueColor: AppColors.warn,
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
                    label: 'Rooms Occupied',
                    value: '${stats.roomsOccupied}',
                    valueColor: AppColors.ok,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppStatCard(
                    label: 'Ed. Notes Today',
                    value: '${stats.pendingFollowUps}',
                    valueColor: AppColors.ink2,
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
// TAB TOGGLE
// ─────────────────────────────────────────────

class _NurseTabToggle extends StatelessWidget {
  final _NurseTab activeTab;
  final int queueCount;
  final int followUpCount;
  final int educationCount;
  final ValueChanged<_NurseTab> onTabChanged;

  const _NurseTabToggle({
    required this.activeTab,
    required this.queueCount,
    required this.followUpCount,
    required this.educationCount,
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
            label: 'Queue ($queueCount)',
            active: activeTab == _NurseTab.queue,
            onTap: () => onTabChanged(_NurseTab.queue),
          ),
          _TabPill(
            label: 'Follow-ups ($followUpCount)',
            active: activeTab == _NurseTab.followUps,
            onTap: () => onTabChanged(_NurseTab.followUps),
          ),
          _TabPill(
            label: 'Education ($educationCount)',
            active: activeTab == _NurseTab.education,
            onTap: () => onTabChanged(_NurseTab.education),
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
              fontSize: 11,
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
// QUEUE LIST
// ─────────────────────────────────────────────

class _QueueList extends StatelessWidget {
  final List<_QueuePatient> patients;
  final Map<String, String> roomAssignments;
  final Set<String> triageNoted;
  final ValueChanged<_QueuePatient> onTriage;

  const _QueueList({
    required this.patients,
    required this.roomAssignments,
    required this.triageNoted,
    required this.onTriage,
  });

  @override
  Widget build(BuildContext context) {
    if (patients.isEmpty) {
      return const _EmptyState(
        icon: Icons.check_circle_outline_rounded,
        message: 'Queue is clear',
        sub: 'All patients have been seen.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      itemCount: patients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _NursePatientCard(
        patient: patients[i],
        assignedRoom: roomAssignments[patients[i].queueId],
        triageDone: triageNoted.contains(patients[i].queueId),
        onTriage: () => onTriage(patients[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NURSE PATIENT CARD
// ─────────────────────────────────────────────

class _NursePatientCard extends StatelessWidget {
  final _QueuePatient patient;
  final String? assignedRoom;
  final bool triageDone;
  final VoidCallback onTriage;

  const _NursePatientCard({
    required this.patient,
    required this.assignedRoom,
    required this.triageDone,
    required this.onTriage,
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
            const SizedBox(height: 5),
            Text(
              patient.symptoms,
              style: TextStyle(
                fontSize: 11.5,
                color: _isUrgent ? const Color(0xFFCFD8E3) : AppColors.ink2,
              ),
            ),
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
            const SizedBox(height: 10),
            Row(
              children: [
                if (assignedRoom != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.okBg,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppColors.okBorder),
                    ),
                    child: Text(
                      assignedRoom!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ok,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: GestureDetector(
                    onTap: onTriage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: triageDone ? AppColors.okBg : AppColors.accent,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: triageDone
                              ? AppColors.okBorder
                              : AppColors.accent,
                        ),
                      ),
                      child: Text(
                        triageDone ? 'Note Added ✓' : 'Add Triage Note',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: triageDone ? AppColors.ok : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TRIAGE SHEET
// ─────────────────────────────────────────────

class _TriageSheet extends StatefulWidget {
  final _QueuePatient patient;
  final String? assignedRoom;
  final ValueChanged<String> onRoomSelected;
  final VoidCallback onNoteSaved;

  const _TriageSheet({
    required this.patient,
    required this.assignedRoom,
    required this.onRoomSelected,
    required this.onNoteSaved,
  });

  @override
  State<_TriageSheet> createState() => _TriageSheetState();
}

class _TriageSheetState extends State<_TriageSheet> {
  late String? _selectedRoom;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.assignedRoom;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.patient.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            Text(
              '${widget.patient.studentId} · #${widget.patient.queueId}',
              style: const TextStyle(
                fontFamily: 'DMMono',
                fontSize: 10,
                color: AppColors.ink3,
              ),
            ),
            const SizedBox(height: 18),
            const _SheetLabel('Assign Room'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _roomOptions.map((room) {
                final selected = _selectedRoom == room;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedRoom = room);
                    widget.onRoomSelected(room);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : AppColors.surface2,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: selected ? AppColors.accent : AppColors.border,
                      ),
                    ),
                    child: Text(
                      room,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.ink2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            const _SheetLabel('Triage Note'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 4,
              style: const TextStyle(fontSize: 13, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'e.g. Patient appears distressed, advised rest...',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.ink3),
                filled: true,
                fillColor: AppColors.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () {
                widget.onNoteSaved();
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Save Note',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FOLLOW-UP LIST
// ─────────────────────────────────────────────

class _FollowUpList extends StatelessWidget {
  final List<_FollowUpPatient> followUps;
  final ValueChanged<int> onToggle;

  const _FollowUpList({required this.followUps, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    if (followUps.isEmpty) {
      return const _EmptyState(
        icon: Icons.task_alt_rounded,
        message: 'No follow-ups',
        sub: 'Doctor-flagged patients will appear here.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      itemCount: followUps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) =>
          _FollowUpCard(followUp: followUps[i], onToggle: () => onToggle(i)),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  final _FollowUpPatient followUp;
  final VoidCallback onToggle;

  const _FollowUpCard({required this.followUp, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: followUp.completed ? AppColors.ok : AppColors.warn,
            width: 3.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      followUp.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${followUp.studentId} · Due: ${followUp.dueDate}',
                      style: const TextStyle(
                        fontFamily: 'DMMono',
                        fontSize: 10,
                        color: AppColors.ink3,
                      ),
                    ),
                  ],
                ),
              ),
              AppStatusChip(
                label: followUp.completed ? 'Done' : 'Pending',
                status: followUp.completed ? AppStatus.ok : AppStatus.warn,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              followUp.doctorNote,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.ink2,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: followUp.completed ? AppColors.surface2 : AppColors.okBg,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: followUp.completed
                      ? AppColors.border
                      : AppColors.okBorder,
                ),
              ),
              child: Text(
                followUp.completed ? 'Mark Incomplete' : 'Mark Complete',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: followUp.completed ? AppColors.ink3 : AppColors.ok,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EDUCATION LIST
// ─────────────────────────────────────────────

class _EducationList extends StatelessWidget {
  final List<_EducationNote> notes;
  final VoidCallback onAdd;

  const _EducationList({required this.notes, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: AppSectionHeader(
            title: 'Health Education Notes',
            actionLabel: '+ Add Note',
            onAction: onAdd,
          ),
        ),
        Expanded(
          child: notes.isEmpty
              ? const _EmptyState(
                  icon: Icons.menu_book_rounded,
                  message: 'No education notes yet',
                  sub: 'Tap "+ Add Note" to record a health promotion note.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _EducationCard(note: notes[i]),
                ),
        ),
      ],
    );
  }
}

class _EducationCard extends StatelessWidget {
  final _EducationNote note;
  const _EducationCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppColors.accent, width: 3.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.patientName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppColors.accentMid),
                ),
                child: Text(
                  note.topic,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            '${note.studentId} · ${note.date}',
            style: const TextStyle(
              fontFamily: 'DMMono',
              fontSize: 10,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note.note,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.ink2,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADD EDUCATION SHEET
// ─────────────────────────────────────────────

class _AddEducationSheet extends StatefulWidget {
  final ValueChanged<_EducationNote> onSave;
  const _AddEducationSheet({required this.onSave});

  @override
  State<_AddEducationSheet> createState() => _AddEducationSheetState();
}

class _AddEducationSheetState extends State<_AddEducationSheet> {
  final _patientController = TextEditingController();
  final _idController = TextEditingController();
  final _topicController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _patientController.dispose();
    _idController.dispose();
    _topicController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Education Note',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 18),
            _SheetField(label: 'Patient Name', controller: _patientController),
            const SizedBox(height: 12),
            _SheetField(label: 'Student ID', controller: _idController),
            const SizedBox(height: 12),
            _SheetField(
              label: 'Topic',
              controller: _topicController,
              hint: 'e.g. Hydration, Stress Management',
            ),
            const SizedBox(height: 12),
            _SheetField(
              label: 'Note',
              controller: _noteController,
              maxLines: 4,
              hint: 'What was discussed or advised...',
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () {
                if (_patientController.text.isEmpty) return;
                widget.onSave(
                  _EducationNote(
                    patientName: _patientController.text,
                    studentId: _idController.text,
                    topic: _topicController.text.isEmpty
                        ? 'General'
                        : _topicController.text,
                    note: _noteController.text,
                    date: 'Today',
                  ),
                );
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Save Note',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.ink3,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  const _SheetField({
    required this.label,
    required this.controller,
    this.hint,
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
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.ink3),
            filled: true,
            fillColor: AppColors.surface2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: AppColors.ink3.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(fontSize: 12, color: AppColors.ink3),
          ),
        ],
      ),
    );
  }
}
