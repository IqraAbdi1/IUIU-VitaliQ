import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';
import 'patient_profile_screen.dart';

// =============================================================================
// MODELS
// =============================================================================

enum NotificationType { lab, queue, prescription, clinicAlert, general }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String time;
  final AppStatus status;
  final bool isRead;
  final NotificationType type;
  final String? patientName; // Backend: notification.patient.full_name
  final String? patientId; // Backend: notification.patient.username

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.status,
    required this.type,
    this.isRead = false,
    this.patientName,
    this.patientId,
  });
}

// =============================================================================
// MOCK DATA
// Backend: GET /api/v1/notifications
// =============================================================================

final _mockNotifications = <NotificationItem>[
  NotificationItem(
    id: 'n-001',
    title: 'Lab Results Ready',
    body:
        'Your blood test results from March 10th are now available. Malaria RDT: Positive. FBC: Hb 9.2 g/dL (flagged).',
    time: 'Today, 09:15',
    status: AppStatus.accent,
    type: NotificationType.lab,
    isRead: false,
    patientName: 'Khalid Abdelgadir',
    patientId: 'STU-2024-1092',
  ),
  NotificationItem(
    id: 'n-002',
    title: 'Prescription Reminder',
    body: 'Time to take your Artemether-Lumefantrine — 2 tablets with food.',
    time: 'Today, 08:00',
    status: AppStatus.warn,
    type: NotificationType.prescription,
    isRead: false,
    patientName: 'Khalid Abdelgadir',
    patientId: 'STU-2024-1092',
  ),
  NotificationItem(
    id: 'n-003',
    title: 'Queue Update',
    body: 'You are now 3rd in the queue. Estimated wait: 6 minutes.',
    time: 'Yesterday, 14:32',
    status: AppStatus.ok,
    type: NotificationType.queue,
    isRead: true,
    patientName: 'Fatima Osman',
    patientId: 'STU-2024-0901',
  ),
  NotificationItem(
    id: 'n-004',
    title: 'New Patient in Queue',
    body: 'Amina Nakato has joined the queue. Severity: Moderate.',
    time: 'Today, 09:30',
    status: AppStatus.warn,
    type: NotificationType.queue,
    isRead: false,
    patientName: 'Amina Nakato',
    patientId: 'STU-2024-0842',
  ),
  NotificationItem(
    id: 'n-005',
    title: 'Clinic Closure Notice',
    body:
        'The clinic will close early this Friday at 13:00 due to a staff meeting.',
    time: 'Mar 6, 08:00',
    status: AppStatus.neutral,
    type: NotificationType.clinicAlert,
    isRead: true,
  ),
  NotificationItem(
    id: 'n-006',
    title: 'Prescription Issued',
    body:
        'Dr. Magombe has issued a prescription for Amoxicillin 500mg · 3×/day for 7 days.',
    time: 'Mar 8, 11:00',
    status: AppStatus.ok,
    type: NotificationType.prescription,
    isRead: true,
    patientName: 'Ibrahim Hassan',
    patientId: 'STU-2024-1134',
  ),
];

// =============================================================================
// SCREEN
// =============================================================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationType? _activeFilter; // null = All

  List<NotificationItem> get _filtered => _activeFilter == null
      ? _mockNotifications
      : _mockNotifications.where((n) => n.type == _activeFilter).toList();

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
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            // ── Filter tabs ──
            Container(
              width: double.infinity,
              color: AppColors.surface,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      active: _activeFilter == null,
                      onTap: () => setState(() => _activeFilter = null),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Lab',
                      active: _activeFilter == NotificationType.lab,
                      onTap: () =>
                          setState(() => _activeFilter = NotificationType.lab),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Queue',
                      active: _activeFilter == NotificationType.queue,
                      onTap: () => setState(
                        () => _activeFilter = NotificationType.queue,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Prescriptions',
                      active: _activeFilter == NotificationType.prescription,
                      onTap: () => setState(
                        () => _activeFilter = NotificationType.prescription,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Clinic Alerts',
                      active: _activeFilter == NotificationType.clinicAlert,
                      onTap: () => setState(
                        () => _activeFilter = NotificationType.clinicAlert,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 1, color: AppColors.border),

            // ── List ──
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No notifications.',
                        style: TextStyle(color: AppColors.ink3),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) =>
                          _NotificationCard(item: _filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// FILTER CHIP
// =============================================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
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
          color: active ? AppColors.accentLight : AppColors.surface2,
          border: Border.all(
            color: active ? AppColors.accent : AppColors.border,
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

// =============================================================================
// NOTIFICATION CARD (expandable, email-style)
// =============================================================================

class _NotificationCard extends StatefulWidget {
  final NotificationItem item;
  const _NotificationCard({required this.item});

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _expanded = false;

  String get _typeLabel => switch (widget.item.type) {
    NotificationType.lab => 'Lab',
    NotificationType.queue => 'Queue',
    NotificationType.prescription => 'Prescription',
    NotificationType.clinicAlert => 'Clinic Alert',
    NotificationType.general => 'General',
  };

  AppStatus get _typeStatus => switch (widget.item.type) {
    NotificationType.lab => AppStatus.accent,
    NotificationType.queue => AppStatus.warn,
    NotificationType.prescription => AppStatus.ok,
    NotificationType.clinicAlert => AppStatus.neutral,
    NotificationType.general => AppStatus.neutral,
  };

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      decoration: BoxDecoration(
        color: item.isRead ? AppColors.surface : AppColors.accentLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isRead ? AppColors.border : AppColors.accentMid,
        ),
      ),
      child: Column(
        children: [
          // ── Collapsed header ──
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unread dot
                  Container(
                    margin: const EdgeInsets.only(top: 5, right: 10),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.isRead
                          ? Colors.transparent
                          : AppColors.statusFg(item.status),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppStatusChip(
                              label: _typeLabel,
                              status: _typeStatus,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.time,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.ink3,
                          ),
                        ),
                        if (!_expanded) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.ink3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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

          // ── Expanded body ──
          if (_expanded) ...[
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.ink2,
                      height: 1.5,
                    ),
                  ),

                  // Patient deep link
                  if (item.patientName != null) ...[
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: AppColors.ink3,
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          // TODO: navigate to patient profile when built
                          // Navigator.push to PatientProfileScreen(patientId)
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PatientProfileScreen(
                                  patientId: item.patientId,
                                  //viewerRole: ProfileViewerRole.doctor,   <<< use this line if you want to see the profile as a doctor or any other staff.
                                ),
                              ),
                            );
                          },
                          child: Text(
                            '${item.patientName} · ${item.patientId}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
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
