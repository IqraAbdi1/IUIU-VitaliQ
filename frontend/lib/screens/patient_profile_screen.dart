import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';

// =============================================================================
// ENUMS
// =============================================================================

/// Who is viewing this profile — drives which sections and actions are shown.
enum ProfileViewerRole { patient, doctor, nurse, admin }

// =============================================================================
// MODELS
// =============================================================================

class _PatientProfile {
  final String fullName; // Backend: patient.full_name
  final String registrationNo; // Backend: patient.username
  final String studentId; // Backend: patient.student_id
  final String dateOfBirth; // Backend: patient.dob
  final String gender; // Backend: patient.gender
  final String faculty; // Backend: patient.faculty
  final String bloodType; // Backend: patient.blood_type
  final String allergies; // Backend: patient.allergies
  final String emergencyContact; // Backend: patient.emergency_contact

  const _PatientProfile({
    required this.fullName,
    required this.registrationNo,
    required this.studentId,
    required this.dateOfBirth,
    required this.gender,
    required this.faculty,
    required this.bloodType,
    required this.allergies,
    required this.emergencyContact,
  });
}

class _VitalsEntry {
  final String date; // Backend: vitals.recorded_at
  final String bp; // Backend: vitals.blood_pressure
  final String temp; // Backend: vitals.temperature
  final String weight; // Backend: vitals.weight_kg
  final String pulse; // Backend: vitals.pulse_bpm

  const _VitalsEntry({
    required this.date,
    required this.bp,
    required this.temp,
    required this.weight,
    required this.pulse,
  });
}

class _VisitSummary {
  final String date; // Backend: visit.created_at
  final String diagnosis; // Backend: consultation.diagnostic_notes
  final String prescription; // Backend: prescription.medicine_name
  final bool hasLabs; // Backend: visit.has_lab_results

  const _VisitSummary({
    required this.date,
    required this.diagnosis,
    required this.prescription,
    required this.hasLabs,
  });
}

class _StaffNote {
  final String authorName; // Backend: note.author.full_name
  final String authorRole; // Backend: note.author.role
  final String content; // Backend: note.content
  final String time; // Backend: note.created_at
  final List<String> mentions; // Backend: note.mentioned_usernames

  const _StaffNote({
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.time,
    this.mentions = const [],
  });
}

// =============================================================================
// MOCK DATA
// =============================================================================

// Backend: GET /api/v1/patients/{id}/profile
const _mockProfile = _PatientProfile(
  fullName: 'Khalid Gurashi Abdelgadir',
  registrationNo: 'STU-2024-1092',
  studentId: '123-063061-30940',
  dateOfBirth: '12 March 2002',
  gender: 'Male',
  faculty: 'Faculty of Science — Computer Science',
  bloodType: 'O+',
  allergies: 'Penicillin',
  emergencyContact: '+256 700 123 456',
);

// Backend: GET /api/v1/vitals?patient_id={id}
const _mockVitals = <_VitalsEntry>[
  _VitalsEntry(
    date: 'Today, 09:15',
    bp: '118/76 mmHg',
    temp: '37.8 °C',
    weight: '68 kg',
    pulse: '92 bpm',
  ),
  _VitalsEntry(
    date: 'Mar 8, 11:00',
    bp: '120/80 mmHg',
    temp: '36.6 °C',
    weight: '68 kg',
    pulse: '78 bpm',
  ),
  _VitalsEntry(
    date: 'Feb 14, 14:30',
    bp: '115/74 mmHg',
    temp: '36.5 °C',
    weight: '67 kg',
    pulse: '74 bpm',
  ),
];

// Backend: GET /api/v1/visits?patient_id={id}
const _mockVisits = <_VisitSummary>[
  _VisitSummary(
    date: 'Today, 09:00',
    diagnosis: 'Malaria — P. falciparum confirmed. Anaemia noted.',
    prescription: 'Artemether-Lumefantrine 80/480mg',
    hasLabs: true,
  ),
  _VisitSummary(
    date: 'Mar 8, 10:45',
    diagnosis: 'Viral upper respiratory infection. No bacterial signs.',
    prescription: 'Paracetamol 500mg · 3×/day',
    hasLabs: false,
  ),
  _VisitSummary(
    date: 'Feb 14, 14:00',
    diagnosis: 'Tension headache. No neurological signs.',
    prescription: 'Ibuprofen 400mg · as needed',
    hasLabs: false,
  ),
];

// Backend: GET /api/v1/patients/{id}/staff-notes
final _mockStaffNotes = <_StaffNote>[
  _StaffNote(
    authorName: 'Dr. Magombe',
    authorRole: 'Doctor',
    content:
        'Patient has recurring malaria. Consider prophylaxis discussion on next visit. @Nurse Amina please monitor temp every 4h.',
    time: 'Today, 09:45',
    mentions: ['Nurse Amina'],
  ),
  _StaffNote(
    authorName: 'Nurse Amina',
    authorRole: 'Nurse',
    content: 'Temp checked at 13:00 — 37.2°C. Patient resting well.',
    time: 'Today, 13:05',
    mentions: [],
  ),
];

// =============================================================================
// SCREEN
// =============================================================================

class PatientProfileScreen extends StatefulWidget {
  final String? patientId; // Backend: patient.username passed from navigation
  final ProfileViewerRole viewerRole;

  const PatientProfileScreen({
    super.key,
    this.patientId,
    this.viewerRole = ProfileViewerRole.patient,
  });

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  bool get _isPatient => widget.viewerRole == ProfileViewerRole.patient;
  bool get _isDoctor => widget.viewerRole == ProfileViewerRole.doctor;
  bool get _isStaff => !_isPatient;

  // Staff note input
  final _noteController = TextEditingController();
  final List<_StaffNote> _notes = List.from(_mockStaffNotes);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitNote() {
    if (_noteController.text.trim().isEmpty) return;
    // Backend: POST /api/v1/patients/{id}/staff-notes
    // Body: { content, mentioned_usernames[] }
    setState(() {
      _notes.insert(
        0,
        _StaffNote(
          authorName: _isDoctor ? 'Dr. (You)' : 'Staff (You)',
          authorRole: _isDoctor ? 'Doctor' : widget.viewerRole.name,
          content: _noteController.text.trim(),
          time: 'Just now',
        ),
      );
      _noteController.clear();
    });
  }

  void _showUpdateVitalsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UpdateVitalsSheet(),
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareProfileSheet(patient: _mockProfile),
    );
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Topbar ──
            Container(
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: AppColors.ink2,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  // Share button — doctor only
                  if (_isDoctor)
                    GestureDetector(
                      onTap: _showShareSheet,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          size: 18,
                          color: AppColors.ink2,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 38),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 30),
                children: [
                  // ── Avatar + name + reg ──
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accentLight,
                                border: Border.all(
                                  color: AppColors.accentMid,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 38,
                                color: AppColors.accent,
                              ),
                            ),
                            // Edit avatar — patient only
                            if (_isPatient)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: image picker
                                    // Backend: POST /api/v1/patients/{id}/avatar
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _mockProfile.fullName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _mockProfile.registrationNo,
                          style: const TextStyle(
                            fontFamily: 'DMMono',
                            fontSize: 11,
                            color: AppColors.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── PATIENT ACTION BUTTONS ──
                  if (_isPatient) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.lock_outline_rounded,
                            label: 'Change Password',
                            color: AppColors.accent,
                            onTap: _showChangePasswordSheet,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.edit_note_rounded,
                            label: 'Request Correction',
                            color: AppColors.warn,
                            onTap: () {
                              // Backend: POST /api/v1/patients/{id}/correction-request
                              // Sends request to admin
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── STAFF ACTION BUTTONS ──
                  if (_isStaff) ...[
                    Row(
                      children: [
                        // Call to Clinic — doctor, nurse, admin
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.campaign_rounded,
                            label: 'Call to Clinic',
                            color: AppColors.err,
                            onTap: () {
                              // Backend: POST /api/v1/notifications/call-to-clinic
                              // Body: { patient_id }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Update Vitals — doctor and nurse
                        if (widget.viewerRole == ProfileViewerRole.doctor ||
                            widget.viewerRole == ProfileViewerRole.nurse)
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.monitor_heart_rounded,
                              label: 'Update Vitals',
                              color: AppColors.accent,
                              onTap: _showUpdateVitalsSheet,
                            ),
                          ),
                        if (widget.viewerRole == ProfileViewerRole.doctor ||
                            widget.viewerRole == ProfileViewerRole.nurse)
                          const SizedBox(width: 10),
                        // Admin: edit info instead of vitals
                        if (widget.viewerRole == ProfileViewerRole.admin)
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.edit_rounded,
                              label: 'Edit Info',
                              color: AppColors.accent,
                              onTap: () {
                                // TODO: admin edit patient info sheet
                                // Backend: PATCH /api/v1/patients/{id}
                              },
                            ),
                          ),
                        if (widget.viewerRole == ProfileViewerRole.admin)
                          const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Patient info ──
                  _SectionLabel('Patient Info'),
                  const SizedBox(height: 8),
                  _InfoCard(
                    rows: [
                      _InfoRow('Date of Birth', _mockProfile.dateOfBirth),
                      _InfoRow('Gender', _mockProfile.gender),
                      _InfoRow('Student ID', _mockProfile.studentId),
                      _InfoRow('Faculty', _mockProfile.faculty),
                      _InfoRow('Blood Type', _mockProfile.bloodType),
                      _InfoRow('Allergies', _mockProfile.allergies),
                      _InfoRow(
                        'Emergency Contact',
                        _mockProfile.emergencyContact,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Vitals History ──
                  _SectionLabel('Vitals History'),
                  const SizedBox(height: 8),
                  ..._mockVitals.map((v) => _VitalsCard(entry: v)),

                  const SizedBox(height: 20),

                  // ── Visit History ──
                  // Patient: brief preview (last 2) + link to MyHealthScreen
                  // Staff: full expandable list
                  AppSectionHeader(
                    title: 'Visit History',
                    actionLabel: _isPatient ? 'See all' : null,
                    onAction: _isPatient
                        ? () {
                            // TODO: Navigator.pop then switch to MyHealth tab
                          }
                        : null,
                  ),
                  const SizedBox(height: 8),
                  ...(_isPatient ? _mockVisits.take(2).toList() : _mockVisits)
                      .map((v) => _VisitCard(visit: v)),

                  const SizedBox(height: 20),

                  // ── Staff Notes (staff only) ──
                  if (_isStaff) ...[
                    _SectionLabel('Staff Notes'),
                    const SizedBox(height: 4),
                    const Text(
                      'Only visible to clinic staff. Use @name to mention.',
                      style: TextStyle(fontSize: 11, color: AppColors.ink3),
                    ),
                    const SizedBox(height: 10),

                    // Note input
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _noteController,
                            maxLines: 3,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.ink,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Add a note… use @name to mention staff',
                              hintStyle: const TextStyle(
                                color: AppColors.ink3,
                                fontSize: 12.5,
                              ),
                              filled: true,
                              fillColor: AppColors.surface2,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
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
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _submitNote,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Text(
                                  'Post Note',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Notes list
                    ..._notes.map((n) => _StaffNoteCard(note: n)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHARE PROFILE SHEET (doctor only)
// =============================================================================

class _ShareProfileSheet extends StatefulWidget {
  final _PatientProfile patient;
  const _ShareProfileSheet({required this.patient});

  @override
  State<_ShareProfileSheet> createState() => _ShareProfileSheetState();
}

class _ShareProfileSheetState extends State<_ShareProfileSheet> {
  // Backend: GET /api/v1/staff — list of staff to share with
  static const _kStaff = [
    'Dr. Amina Hassan',
    'Dr. Omar Diallo',
    'Nurse Fatima',
    'Admin Yusuf',
  ];

  final _messageController = TextEditingController();
  String? _selectedStaff;
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_selectedStaff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a staff member to share with.')),
      );
      return;
    }
    setState(() => _isSending = true);
    // Backend: POST /api/v1/profile-share
    // Body: { patient_id, recipient_id, message }
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile shared with $_selectedStaff.'),
        backgroundColor: AppColors.ok,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.85,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            _SheetHandle(),
            Expanded(
              child: SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Profile',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.patient.fullName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.ink3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 16),

                    const _SectionLabel('Share With'),
                    const SizedBox(height: 8),
                    ..._kStaff.map((s) {
                      final selected = _selectedStaff == s;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedStaff = s),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accentLight
                                : AppColors.surface2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? AppColors.accent
                                        : AppColors.ink,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 14),
                    const _SectionLabel('Note (optional)'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add a message to accompany the profile…',
                        hintStyle: const TextStyle(
                          color: AppColors.ink3,
                          fontSize: 12.5,
                        ),
                        filled: true,
                        fillColor: AppColors.surface2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: AppColors.border,
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
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),

                    const SizedBox(height: 20),
                    _PrimaryButton(
                      label: _isSending ? 'Sending…' : 'Send Profile',
                      icon: Icons.send_rounded,
                      loading: _isSending,
                      onTap: _isSending ? () {} : _send,
                    ),
                    const SizedBox(height: 10),
                    _CancelButton(),
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

// =============================================================================
// CHANGE PASSWORD SHEET (patient only)
// =============================================================================

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  // Backend: POST /api/v1/auth/change-password
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password changed successfully.'),
        backgroundColor: AppColors.ok,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.85,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            _SheetHandle(),
            Expanded(
              child: SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 16),
                    _PasswordInput(
                      controller: _currentController,
                      label: 'Current Password',
                    ),
                    const SizedBox(height: 12),
                    _PasswordInput(
                      controller: _newController,
                      label: 'New Password',
                    ),
                    const SizedBox(height: 12),
                    _PasswordInput(
                      controller: _confirmController,
                      label: 'Confirm New Password',
                    ),
                    const SizedBox(height: 22),
                    _PrimaryButton(
                      label: _isSubmitting ? 'Saving…' : 'Change Password',
                      icon: Icons.lock_rounded,
                      loading: _isSubmitting,
                      onTap: _isSubmitting ? () {} : _submit,
                    ),
                    const SizedBox(height: 10),
                    _CancelButton(),
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

// =============================================================================
// UPDATE VITALS SHEET (doctor + nurse only)
// =============================================================================

class _UpdateVitalsSheet extends StatefulWidget {
  const _UpdateVitalsSheet();

  @override
  State<_UpdateVitalsSheet> createState() => _UpdateVitalsSheetState();
}

class _UpdateVitalsSheetState extends State<_UpdateVitalsSheet> {
  // Backend: POST /api/v1/vitals
  // Body: { patient_id, bp, temp, weight, pulse, recorded_at }
  final _bpController = TextEditingController();
  final _tempController = TextEditingController();
  final _weightController = TextEditingController();
  final _pulseController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bpController.dispose();
    _tempController.dispose();
    _weightController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vitals updated.'),
        backgroundColor: AppColors.ok,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            _SheetHandle(),
            Expanded(
              child: SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Update Vitals',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            'Now · ${TimeOfDay.now().format(context)}',
                            style: const TextStyle(
                              fontFamily: 'DMMono',
                              fontSize: 10.5,
                              color: AppColors.ink3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Readings will be timestamped and saved to patient record.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.ink3),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 16),
                    _VitalsInput(
                      controller: _bpController,
                      label: 'Blood Pressure',
                      hint: 'e.g. 120/80',
                      unit: 'mmHg',
                    ),
                    const SizedBox(height: 12),
                    _VitalsInput(
                      controller: _tempController,
                      label: 'Temperature',
                      hint: 'e.g. 37.2',
                      unit: '°C',
                    ),
                    const SizedBox(height: 12),
                    _VitalsInput(
                      controller: _weightController,
                      label: 'Weight',
                      hint: 'e.g. 68',
                      unit: 'kg',
                    ),
                    const SizedBox(height: 12),
                    _VitalsInput(
                      controller: _pulseController,
                      label: 'Pulse',
                      hint: 'e.g. 78',
                      unit: 'bpm',
                    ),
                    const SizedBox(height: 22),
                    _PrimaryButton(
                      label: _isSubmitting ? 'Saving…' : 'Save Vitals',
                      icon: Icons.save_rounded,
                      loading: _isSubmitting,
                      onTap: _isSubmitting ? () {} : _submit,
                    ),
                    const SizedBox(height: 10),
                    _CancelButton(),
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

// =============================================================================
// PRIVATE WIDGETS
// =============================================================================

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final isLast = i == rows.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    rows[i].label,
                    style: const TextStyle(fontSize: 12, color: AppColors.ink3),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    rows[i].value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _VitalsCard extends StatelessWidget {
  final _VitalsEntry entry;
  const _VitalsCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.date,
            style: const TextStyle(
              fontFamily: 'DMMono',
              fontSize: 10.5,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _VitalPill(label: 'BP', value: entry.bp),
              const SizedBox(width: 6),
              _VitalPill(label: 'Temp', value: entry.temp),
              const SizedBox(width: 6),
              _VitalPill(label: 'Pulse', value: entry.pulse),
              const SizedBox(width: 6),
              _VitalPill(label: 'Wt', value: entry.weight),
            ],
          ),
        ],
      ),
    );
  }
}

class _VitalPill extends StatelessWidget {
  final String label;
  final String value;
  const _VitalPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.ink3),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitCard extends StatefulWidget {
  final _VisitSummary visit;
  const _VisitCard({required this.visit});

  @override
  State<_VisitCard> createState() => _VisitCardState();
}

class _VisitCardState extends State<_VisitCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
                    child: Text(
                      widget.visit.date,
                      style: const TextStyle(
                        fontFamily: 'DMMono',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  if (widget.visit.hasLabs)
                    AppStatusChip(label: 'Labs', status: AppStatus.accent),
                  const SizedBox(width: 6),
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
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DIAGNOSIS',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink3,
                      letterSpacing: 0.07 * 9.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.visit.diagnosis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink2,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'PRESCRIPTION',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink3,
                      letterSpacing: 0.07 * 9.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.visit.prescription,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StaffNoteCard extends StatelessWidget {
  final _StaffNote note;
  const _StaffNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    // Parse @mentions and highlight them
    final parts = note.content.split(RegExp(r'(@\w[\w\s]*\w)'));
    final spans = <TextSpan>[];
    for (final part in parts) {
      if (part.startsWith('@')) {
        spans.add(
          TextSpan(
            text: part,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: part,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.ink2,
              height: 1.5,
            ),
          ),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                note.authorName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 6),
              AppStatusChip(label: note.authorRole, status: AppStatus.neutral),
              const Spacer(),
              Text(
                note.time,
                style: const TextStyle(fontSize: 10.5, color: AppColors.ink3),
              ),
            ],
          ),
          const SizedBox(height: 6),
          RichText(text: TextSpan(children: spans)),
        ],
      ),
    );
  }
}

class _VitalsInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String unit;

  const _VitalsInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.ink3,
            letterSpacing: 0.07 * 10.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 13, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.ink3, fontSize: 12.5),
            suffixText: unit,
            suffixStyle: const TextStyle(
              color: AppColors.ink3,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
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
          ),
        ),
      ],
    );
  }
}

class _PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  const _PasswordInput({required this.controller, required this.label});

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.ink3,
            letterSpacing: 0.07 * 10.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          style: const TextStyle(fontSize: 13, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: AppColors.ink3, fontSize: 12.5),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.ink3,
              ),
            ),
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
          ),
        ),
      ],
    );
  }
}

// Shared sheet helpers
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
