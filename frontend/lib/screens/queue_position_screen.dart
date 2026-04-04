import 'package:flutter/material.dart';
import '../theme.dart';

class QueuePositionScreen extends StatefulWidget {
  const QueuePositionScreen({super.key});

  @override
  State<QueuePositionScreen> createState() => _QueuePositionScreenState();
}

class _QueuePositionScreenState extends State<QueuePositionScreen> {
  // --- MOCK DATA ---
  // In the future, these will come from GET /visits/{visit_id}
  // and update in real-time via websocket or polling
  final String queueId = 'Q-047';
  final int queuePosition = 5;
  final int estimatedMinutes = 20;
  final String status = 'Waiting'; // Waiting | Called | Done
  final String mlSeverity = 'Moderate'; // Severe | Moderate | Minor

  // Step tracker — maps to visit workflow stages
  // 0=Submitted, 1=Assessed, 2=In Queue, 3=Your Turn, 4=Doctor
  final int currentStep = 2;

  final List<String> _steps = [
    'Submitted',
    'Assessed',
    'In Queue',
    'Your Turn',
    'Doctor',
  ];

  // --- CANCEL SLOT ---
  // TODO: Wire to DELETE /visits/{visit_id} or PATCH status=cancelled
  void _handleCancelSlot() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel your slot?',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        content: Text(
          'You will lose your current queue position. You can re-submit symptoms to re-join.',
          style: TextStyle(color: AppColors.ink2, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep my slot'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: call API, then navigate back to home
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Slot cancelled'),
                  backgroundColor: AppColors.err,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.err),
            child: const Text(
              'Cancel slot',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // --- TOPBAR ---
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 14,
                right: 14,
                bottom: 12,
              ),
              child: Row(
                children: [
                  _TopbarButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Queue Status',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  // Bell placeholder to balance the row
                  _TopbarButton(
                    icon: Icons.notifications_outlined,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // --- SEVERITY BADGE + QUEUE ID ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SeverityBadge(severity: mlSeverity),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '#$queueId',
                      style: const TextStyle(
                        fontFamily: 'DMMono',
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // --- QUEUE TRACKER CARD ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Queue Position',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34D48A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 1,
                      color: AppColors.ink3.withValues(alpha: 0.12),
                    ),

                    // Step tracker
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                      child: _StepTracker(
                        steps: _steps,
                        currentStep: currentStep,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Divider(
                        height: 1,
                        color: AppColors.ink3.withValues(alpha: 0.12),
                      ),
                    ),

                    // Stats row: Position / ETA / Status
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatMini(
                              label: 'Position',
                              value: '#$queuePosition',
                              isMono: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatMini(
                              label: 'ETA',
                              value: '~${estimatedMinutes}m',
                              isMono: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatMini(
                              label: 'Status',
                              value: status,
                              valueColor: AppColors.ok,
                              isMono: false,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cancel button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _handleCancelSlot,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.err,
                            side: BorderSide(
                              color: AppColors.err.withValues(alpha: 0.35),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            'Cancel my slot',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // --- SECTION LABEL ---
          _buildSectionLabel('What happens next'),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // --- NEXT STEPS INFO CARD ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.25),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STAY NEARBY',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'You will be notified when it\'s your turn. Please remain on or near campus.',
                      style: TextStyle(
                        color: AppColors.ink2,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '⚠  If you don\'t check in within the time window, your slot will expire automatically.',
                      style: TextStyle(
                        color: AppColors.ink2,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSectionLabel(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: AppColors.ink2,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

// --- SUB-WIDGETS ---

class _TopbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopbarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.ink3.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: AppColors.ink2, size: 17),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;
  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    Color bg, textColor, borderColor;

    switch (severity) {
      case 'Severe':
        bg = const Color(0xFFFFF2F2);
        textColor = AppColors.err;
        borderColor = const Color(0xFFF5AAAA);
        break;
      case 'Moderate':
        bg = const Color(0xFFFFF7EA);
        textColor = AppColors.warn;
        borderColor = const Color(0xFFF5C97A);
        break;
      default: // Minor
        bg = const Color(0xFFEAFAF2);
        textColor = AppColors.ok;
        borderColor = const Color(0xFF96DEBB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$severity Priority',
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTracker extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  const _StepTracker({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        // Even indices = step nodes, odd = connectors
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final isDone = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isDone
                  ? AppColors.accent
                  : AppColors.ink3.withValues(alpha: 0.2),
            ),
          );
        }

        final stepIndex = i ~/ 2;
        final isDone = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;

        return Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.accent
                    : isCurrent
                    ? AppColors.accentLight
                    : AppColors.surface,
                border: Border.all(
                  color: isDone || isCurrent
                      ? AppColors.accent
                      : AppColors.ink3.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? AppColors.accent : AppColors.ink3,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[stepIndex],
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: isDone || isCurrent ? AppColors.accent : AppColors.ink3,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isMono;

  const _StatMini({
    required this.label,
    required this.value,
    this.valueColor,
    required this.isMono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppColors.ink3,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: isMono ? 'DMMono' : null,
              color: valueColor ?? AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
