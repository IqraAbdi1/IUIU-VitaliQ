// lib/screens/staff_home_screen.dart
// Shared Staff Home — Announcements · Shift Info · Quick Stats · Notifications
// Backend: GET /api/v1/announcements, GET /api/v1/shift, GET /api/v1/notifications

import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

class _Announcement {
  final String id;
  final String title;
  final String body;
  final String postedBy;
  final String timeAgo;
  final bool isPinned;
  // Backend: GET /api/v1/announcements

  const _Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.postedBy,
    required this.timeAgo,
    this.isPinned = false,
  });
}

class _ShiftInfo {
  final String shiftLabel;
  final String startTime;
  final String endTime;
  final String supervisorName;
  // Backend: GET /api/v1/shift?staff_id={id}

  const _ShiftInfo({
    required this.shiftLabel,
    required this.startTime,
    required this.endTime,
    required this.supervisorName,
  });
}

class _QuickStat {
  final String label;
  final String value;
  final String? sub;
  final Color valueColor;

  const _QuickStat({
    required this.label,
    required this.value,
    this.sub,
    this.valueColor = AppColors.ink,
  });
}

class _NotificationPreview {
  final String title;
  final String sub;
  final bool unread;
  // Backend: GET /api/v1/notifications?staff_id={id}&limit=3

  const _NotificationPreview({
    required this.title,
    required this.sub,
    required this.unread,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────

const _mockAnnouncements = [
  _Announcement(
    id: 'ann-001',
    title: 'Clinic closed Saturday',
    body:
        'The clinic will be closed this Saturday 10th May for maintenance. Emergency cases should be referred to Mulago Hospital.',
    postedBy: 'Dr. Magombe',
    timeAgo: '2h ago',
    isPinned: true,
  ),
  _Announcement(
    id: 'ann-002',
    title: 'New malaria RDT kits available',
    body:
        'A new batch of RDT kits has arrived. Please update inventory records accordingly.',
    postedBy: 'Admin',
    timeAgo: '1d ago',
  ),
  _Announcement(
    id: 'ann-003',
    title: 'Reminder: patient data privacy',
    body:
        'All staff are reminded not to share patient records outside the system. Report any breaches immediately.',
    postedBy: 'Admin',
    timeAgo: '3d ago',
  ),
];

const _mockShift = _ShiftInfo(
  shiftLabel: 'Morning Shift',
  startTime: '08:00',
  endTime: '14:00',
  supervisorName: 'Dr. Yasin Magombe',
);

const _mockNotifications = [
  _NotificationPreview(
    title: 'Lab result uploaded',
    sub: 'STU-2024-0112 · Malaria RDT',
    unread: true,
  ),
  _NotificationPreview(
    title: 'New patient in queue',
    sub: 'Urgent · #014 Amina Nakato',
    unread: true,
  ),
  _NotificationPreview(
    title: 'Prescription dispensed',
    sub: 'STU-2024-0334 · Paracetamol',
    unread: false,
  ),
];

List<_QuickStat> _mockQuickStats(String role) {
  final Map<String, List<_QuickStat>> stats = {
    'doctor': [
      _QuickStat(
        label: 'In Queue',
        value: '6',
        sub: '1 urgent',
        valueColor: AppColors.accent,
      ),
      _QuickStat(label: 'Seen Today', value: '11', valueColor: AppColors.ok),
      _QuickStat(label: 'Pending Labs', value: '3', valueColor: AppColors.warn),
      _QuickStat(label: 'Avg. Consult', value: '8m'),
    ],
    'nurse': [
      _QuickStat(
        label: 'In Queue',
        value: '6',
        sub: '1 urgent',
        valueColor: AppColors.accent,
      ),
      _QuickStat(
        label: 'Follow-ups',
        value: '3',
        sub: 'due today',
        valueColor: AppColors.warn,
      ),
      _QuickStat(label: 'Rooms Occupied', value: '2', valueColor: AppColors.ok),
      _QuickStat(label: 'Ed. Notes', value: '2'),
    ],
    'lab': [
      _QuickStat(
        label: 'Pending Tests',
        value: '4',
        valueColor: AppColors.warn,
      ),
      _QuickStat(
        label: 'Completed Today',
        value: '9',
        valueColor: AppColors.ok,
      ),
      _QuickStat(
        label: 'Flagged Results',
        value: '1',
        valueColor: AppColors.err,
      ),
      _QuickStat(label: 'Avg. Turnaround', value: '22m'),
    ],
    'admin': [
      _QuickStat(
        label: 'Total Visits',
        value: '47',
        sub: 'this week',
        valueColor: AppColors.accent,
      ),
      _QuickStat(
        label: 'Low Stock Items',
        value: '2',
        valueColor: AppColors.warn,
      ),
      _QuickStat(label: 'ML Alerts', value: '1', valueColor: AppColors.err),
      _QuickStat(label: 'Staff On Shift', value: '5'),
    ],
  };
  return stats[role] ?? [];
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class StaffHomeScreen extends StatefulWidget {
  final String role;
  final String staffName;
  // Backend: decoded from JWT claims 'role', 'name'

  const StaffHomeScreen({
    super.key,
    required this.role,
    this.staffName = 'Staff',
  });

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  final List<_Announcement> _announcements = List.of(_mockAnnouncements);

  bool get _isAdmin => widget.role == 'admin';

  void _showPostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostAnnouncementSheet(
        onPost: (a) => setState(() => _announcements.insert(0, a)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _mockQuickStats(widget.role);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 30),
        children: [
          // ── Greeting ──
          _GreetingHeader(role: widget.role, staffName: widget.staffName),
          const SizedBox(height: 16),

          // ── Shift Info ──
          _ShiftCard(shift: _mockShift),
          const SizedBox(height: 16),

          // ── Quick Stats ──
          AppSectionHeader(title: 'Quick Stats'),
          const SizedBox(height: 10),
          _QuickStatsGrid(stats: stats),
          const SizedBox(height: 16),

          // ── Notifications Preview ──
          AppSectionHeader(
            title: 'Recent Notifications',
            actionLabel: 'See all',
            onAction: () {}, // TODO: navigate to NotificationsScreen
          ),
          const SizedBox(height: 10),
          _NotificationsPreview(notifications: _mockNotifications),
          const SizedBox(height: 16),

          // ── Announcements ──
          AppSectionHeader(
            title: 'Clinic Announcements',
            actionLabel: _isAdmin ? '+ Post' : null,
            onAction: _isAdmin ? () => _showPostSheet(context) : null,
          ),
          const SizedBox(height: 10),
          ..._announcements.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AnnouncementCard(announcement: a),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GREETING HEADER
// ─────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final String role;
  final String staffName;

  const _GreetingHeader({required this.role, required this.staffName});

  String get _roleLabel => switch (role) {
    'doctor' => 'Doctor',
    'nurse' => 'Nurse',
    'lab' => 'Lab Technician',
    'admin' => 'Administrator',
    _ => 'Staff',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: const TextStyle(fontSize: 12, color: AppColors.ink3),
              ),
              Text(
                staffName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.accentMid),
          ),
          child: Text(
            _roleLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SHIFT CARD
// ─────────────────────────────────────────────

class _ShiftCard extends StatelessWidget {
  final _ShiftInfo shift;
  const _ShiftCard({required this.shift});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: AppColors.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift.shiftLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${shift.startTime} – ${shift.endTime}',
                  style: const TextStyle(
                    fontFamily: 'DMMono',
                    fontSize: 11,
                    color: AppColors.ink2,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Supervisor',
                style: TextStyle(fontSize: 9.5, color: AppColors.ink3),
              ),
              const SizedBox(height: 2),
              Text(
                shift.supervisorName,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QUICK STATS GRID
// ─────────────────────────────────────────────

class _QuickStatsGrid extends StatelessWidget {
  final List<_QuickStat> stats;
  const _QuickStatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AppStatCard(
                  label: stats[0].label,
                  value: stats[0].value,
                  sub: stats[0].sub,
                  valueColor: stats[0].valueColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppStatCard(
                  label: stats[1].label,
                  value: stats[1].value,
                  sub: stats[1].sub,
                  valueColor: stats[1].valueColor,
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
                  label: stats[2].label,
                  value: stats[2].value,
                  sub: stats[2].sub,
                  valueColor: stats[2].valueColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppStatCard(
                  label: stats[3].label,
                  value: stats[3].value,
                  sub: stats[3].sub,
                  valueColor: stats[3].valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// NOTIFICATIONS PREVIEW
// ─────────────────────────────────────────────

class _NotificationsPreview extends StatelessWidget {
  final List<_NotificationPreview> notifications;
  const _NotificationsPreview({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: notifications.asMap().entries.map((entry) {
          final i = entry.key;
          final n = entry.value;
          final isLast = i == notifications.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: n.unread ? AppColors.accent : Colors.transparent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: n.unread
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        n.sub,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ink3,
                          fontFamily: 'DMMono',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ANNOUNCEMENT CARD
// ─────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  final _Announcement announcement;
  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: announcement.isPinned ? AppColors.accent : AppColors.border,
            width: announcement.isPinned ? 3.5 : 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              if (announcement.isPinned) ...[
                const Icon(
                  Icons.push_pin_rounded,
                  size: 12,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  announcement.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                announcement.timeAgo,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.ink3,
                  fontFamily: 'DMMono',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            announcement.body,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.ink2,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Posted by ${announcement.postedBy}',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.ink3,
              fontFamily: 'DMMono',
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// POST ANNOUNCEMENT SHEET (admin only)
// ─────────────────────────────────────────────

class _PostAnnouncementSheet extends StatefulWidget {
  final ValueChanged<_Announcement> onPost;
  const _PostAnnouncementSheet({required this.onPost});

  @override
  State<_PostAnnouncementSheet> createState() => _PostAnnouncementSheetState();
}

class _PostAnnouncementSheetState extends State<_PostAnnouncementSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _pinned = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
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
              'Post Announcement',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 18),
            _SheetLabel('Title'),
            const SizedBox(height: 6),
            _SheetField(
              controller: _titleController,
              hint: 'e.g. Clinic closed Saturday',
            ),
            const SizedBox(height: 12),
            _SheetLabel('Message'),
            const SizedBox(height: 6),
            _SheetField(
              controller: _bodyController,
              hint: 'Write your announcement...',
              maxLines: 4,
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => setState(() => _pinned = !_pinned),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _pinned ? AppColors.accent : AppColors.surface2,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: _pinned ? AppColors.accent : AppColors.border,
                      ),
                    ),
                    child: _pinned
                        ? const Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pin this announcement',
                    style: TextStyle(fontSize: 13, color: AppColors.ink2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () {
                if (_titleController.text.isEmpty) return;
                widget.onPost(
                  _Announcement(
                    id: 'ann-${DateTime.now().millisecondsSinceEpoch}',
                    title: _titleController.text,
                    body: _bodyController.text,
                    postedBy: 'Admin',
                    timeAgo: 'Just now',
                    isPinned: _pinned,
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
                  'Post Announcement',
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
  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  const _SheetField({required this.controller, this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
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
    );
  }
}
