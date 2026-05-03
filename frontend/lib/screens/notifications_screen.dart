import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';

// =============================================================================
// MODELS
// =============================================================================

/// A single notification item.
/// Backend: GET /api/v1/notifications?patient_id={id}
class NotificationItem {
  final String title;
  final String body;
  final String time;
  final AppStatus status;
  final bool isRead;

  const NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.status,
    this.isRead = false,
  });
}

// =============================================================================
// MOCK DATA
// =============================================================================

// TODO: replace with GET /api/v1/notifications?patient_id={id}
const List<NotificationItem> _mockNotifications = [
  NotificationItem(
    title: 'Lab Results Ready',
    body: 'Your blood test results from March 10th are now available.',
    time: 'Today, 09:15',
    status: AppStatus.accent,
    isRead: false,
  ),
  NotificationItem(
    title: 'Prescription Reminder',
    body: 'Time to take your Artemether-Lumefantrine — 2 tablets with food.',
    time: 'Today, 08:00',
    status: AppStatus.warn,
    isRead: false,
  ),
  NotificationItem(
    title: 'Queue Update',
    body: 'You are now 3rd in the queue. Estimated wait: 6 minutes.',
    time: 'Yesterday, 14:32',
    status: AppStatus.ok,
    isRead: true,
  ),
  NotificationItem(
    title: 'Appointment Confirmed',
    body: 'Your visit on March 8th has been recorded in your health history.',
    time: 'Mar 8, 11:00',
    status: AppStatus.ok,
    isRead: true,
  ),
  NotificationItem(
    title: 'Clinic Closure Notice',
    body: 'The clinic will close early this Friday at 13:00.',
    time: 'Mar 6, 08:00',
    status: AppStatus.neutral,
    isRead: true,
  ),
];

// =============================================================================
// SCREEN
// =============================================================================

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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

            // ── List ──
            Expanded(
              child: _mockNotifications.isEmpty
                  ? const Center(
                      child: Text(
                        'No notifications yet.',
                        style: TextStyle(color: AppColors.ink3),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      itemCount: _mockNotifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final n = _mockNotifications[i];
                        return _NotificationCard(item: n);
                      },
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

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.isRead ? AppColors.surface : AppColors.accentLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isRead ? AppColors.border : AppColors.accentMid,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status dot
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.isRead
                  ? AppColors.border
                  : AppColors.statusFg(item.status),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    AppStatusChip(label: item.time, status: AppStatus.neutral),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.ink2,
                    height: 1.4,
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
