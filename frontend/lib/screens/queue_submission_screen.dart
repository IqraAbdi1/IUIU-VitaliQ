import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../shared/widgets.dart';
import 'symptom_submission_sheet.dart';

// ─────────────────────────────────────────────
// Queue Submission Detail Screen
//
// Shown when the patient taps the green "You're in the queue" pill.
// Displays submission details, a countdown timer, and allows
// editing or cancelling within the edit window.
//
// Backend (future):
//   GET  /api/v1/visits/submit        → load current submission
//   POST /api/v1/visits/submit        → re-submit edited version
//   DELETE /api/v1/queue/{visit_id}   → cancel and leave queue
// ─────────────────────────────────────────────

// Edit window duration — patient can edit/cancel within this time
const _kEditWindowMinutes = 30;

// ── Mock submission data ─────────────────────────────────
// Backend: GET /api/v1/visits/active?patient_id={id}
class _Submission {
  final int queueNumber; // Backend: visits.queue_position
  final String visitId; // Backend: visits.visit_id
  final String submittedAt; // Backend: visits.created_at
  final String duration; // Backend: symptom.duration
  final List<String> symptoms; // Backend: symptom.name[]
  final String? temperature; // Backend: visits.temperature
  final String? notes; // Backend: symptom.notes
  final String mlSeverity; // Backend: visits.ml_severity
  final int queueTotal; // Backend: queue/stats

  const _Submission({
    required this.queueNumber,
    required this.visitId,
    required this.submittedAt,
    required this.duration,
    required this.symptoms,
    this.temperature,
    this.notes,
    required this.mlSeverity,
    required this.queueTotal,
  });
}

final _mockSubmission = _Submission(
  queueNumber: 8,
  visitId: 'Q-047',
  submittedAt: '10:32 AM',
  duration: '1–3 days',
  symptoms: ['Fever', 'Cough', 'Headache', 'Chills'],
  temperature: '38.4',
  notes: 'Paracetamol not helping the fever.',
  mlSeverity: 'Moderate',
  queueTotal: 15,
);

// ── Screen ───────────────────────────────────────────────

class QueueSubmissionScreen extends StatefulWidget {
  final int queueNumber;
  final VoidCallback onCancelled;

  const QueueSubmissionScreen({
    super.key,
    required this.queueNumber,
    required this.onCancelled,
  });

  @override
  State<QueueSubmissionScreen> createState() => _QueueSubmissionScreenState();
}

class _QueueSubmissionScreenState extends State<QueueSubmissionScreen> {
  late Timer _timer;
  late Duration _remaining;
  bool _editWindowOpen = true;

  // We use the mock submission as the live data source
  _Submission _submission = _mockSubmission;

  @override
  void initState() {
    super.initState();
    // Start the countdown from full edit window
    _remaining = const Duration(minutes: _kEditWindowMinutes);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        } else {
          _editWindowOpen = false;
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _countdownLabel {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Countdown color: green → amber → red
  Color get _countdownColor {
    if (_remaining.inMinutes >= 15) return AppColors.ok;
    if (_remaining.inMinutes >= 5) return AppColors.warn;
    return AppColors.err;
  }

  void _handleCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel your slot?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        content: const Text(
          'You will be removed from the queue. You can re-submit at any time.',
          style: TextStyle(fontSize: 13, color: AppColors.ink2, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Keep my slot',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              widget.onCancelled();
            },
            child: const Text(
              'Yes, cancel',
              style: TextStyle(
                color: AppColors.err,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEdit() {
    showSymptomSubmissionSheet(
      context,
      existing: SymptomSubmissionData(
        duration: _submission.duration,
        symptoms: _submission.symptoms,
        temperature: _submission.temperature,
        notes: _submission.notes,
      ),
      isEdit: true,
      onSubmitted: (data) {
        // Reflect updated data in the detail screen immediately
        setState(() {
          _submission = _Submission(
            queueNumber: _submission.queueNumber,
            visitId: _submission.visitId,
            submittedAt: _submission.submittedAt,
            mlSeverity: _submission.mlSeverity,
            queueTotal: _submission.queueTotal,
            duration: data.duration,
            symptoms: data.symptoms,
            temperature: data.temperature,
            notes: data.notes,
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // ── Custom top bar ──────────────────────────────
          _TopBar(onBack: () => Navigator.of(context).pop()),

          // ── Scrollable body ─────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status hero card ─────────────────────
                  _StatusHeroCard(
                    queueNumber: _submission.queueNumber,
                    visitId: _submission.visitId,
                    mlSeverity: _submission.mlSeverity,
                    submittedAt: _submission.submittedAt,
                    queueTotal: _submission.queueTotal,
                  ),
                  const SizedBox(height: 14),

                  // ── Edit window countdown ─────────────────
                  _EditWindowBanner(
                    editWindowOpen: _editWindowOpen,
                    countdownLabel: _countdownLabel,
                    countdownColor: _countdownColor,
                  ),
                  const SizedBox(height: 14),

                  // ── Submission details card ───────────────
                  AppSectionHeader(title: 'Your Submission'),
                  const SizedBox(height: 8),
                  _SubmissionDetailsCard(submission: _submission),
                  const SizedBox(height: 20),

                  // ── Queue progress steps ──────────────────
                  AppSectionHeader(title: 'Your Progress'),
                  const SizedBox(height: 8),
                  const _QueueStepsCard(),
                  const SizedBox(height: 28),

                  // ── Action buttons ────────────────────────
                  if (_editWindowOpen) ...[
                    _ActionButton(
                      label: 'Edit Submission',
                      icon: Icons.edit_outlined,
                      color: AppColors.accent,
                      onTap: _handleEdit,
                    ),
                    const SizedBox(height: 10),
                  ],
                  _ActionButton(
                    label: 'Cancel My Slot',
                    icon: Icons.close_rounded,
                    color: AppColors.err,
                    outlined: true,
                    onTap: _editWindowOpen ? _handleCancel : null,
                    disabledReason: _editWindowOpen
                        ? null
                        : 'Edit window has closed. Contact the clinic to cancel.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8,
        right: 16,
        bottom: 0,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.ink2,
            ),
            onPressed: onBack,
          ),
          const Expanded(
            child: Text(
              'My Queue Status',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
          // Spacer to balance the back button
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

// ── Status hero card ─────────────────────────────────────

class _StatusHeroCard extends StatelessWidget {
  final int queueNumber;
  final String visitId;
  final String mlSeverity;
  final String submittedAt;
  final int queueTotal;

  const _StatusHeroCard({
    required this.queueNumber,
    required this.visitId,
    required this.mlSeverity,
    required this.submittedAt,
    required this.queueTotal,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = mlSeverity == 'Severe'
        ? AppColors.err
        : mlSeverity == 'Moderate'
        ? AppColors.warn
        : AppColors.ok;
    final severityBg = mlSeverity == 'Severe'
        ? AppColors.errBg
        : mlSeverity == 'Moderate'
        ? AppColors.warnBg
        : AppColors.okBg;
    final severityBorder = mlSeverity == 'Severe'
        ? AppColors.errBorder
        : mlSeverity == 'Moderate'
        ? AppColors.warnBorder
        : AppColors.okBorder;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.hero, AppColors.hero2, AppColors.hero3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.hero.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Queue number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Queue Position',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 0.06 * 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#$visitId',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'DMMono',
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              // ML severity chip — uses AppStatusChip from shared/widgets.dart
              AppStatusChip(
                label: mlSeverity,
                status: mlSeverity == 'Severe'
                    ? AppStatus.err
                    : mlSeverity == 'Moderate'
                    ? AppStatus.warn
                    : AppStatus.ok,
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Stats row
          Row(
            children: [
              _HeroStat(
                label: 'Position',
                value: '#$queueNumber',
                color: const Color(
                  0xFF7ECFF5,
                ), // heroStatBlue — AppColors.heroStatBlue
              ),
              const SizedBox(width: 10),
              _HeroStat(
                label: 'Ahead of you',
                value: '${queueNumber - 1}',
                color: const Color(
                  0xFFFFBE50,
                ), // heroStatAmber — AppColors.heroStatAmber
              ),
              const SizedBox(width: 10),
              _HeroStat(
                label: 'Submitted',
                value: submittedAt,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HeroStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.45),
                letterSpacing: 0.07 * 8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'DMMono',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit window countdown banner ─────────────────────────

class _EditWindowBanner extends StatelessWidget {
  final bool editWindowOpen;
  final String countdownLabel;
  final Color countdownColor;

  const _EditWindowBanner({
    required this.editWindowOpen,
    required this.countdownLabel,
    required this.countdownColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!editWindowOpen) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.errBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.errBorder),
        ),
        child: Row(
          children: const [
            Icon(Icons.lock_clock_outlined, size: 16, color: AppColors.err),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Edit window has closed. Contact the clinic to make changes.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.err,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accentMid),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_outlined, size: 16, color: AppColors.accent),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'You can edit or cancel your submission for:',
              style: TextStyle(fontSize: 12, color: AppColors.ink2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            countdownLabel,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: countdownColor,
              fontFamily: 'DMMono',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Submission details card ───────────────────────────────

class _SubmissionDetailsCard extends StatelessWidget {
  final _Submission submission;
  const _SubmissionDetailsCard({required this.submission});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
        children: [
          _DetailRow(
            label: 'Duration',
            value: submission.duration,
            isFirst: true,
          ),
          _DetailRow(label: 'Symptoms', value: submission.symptoms.join(', ')),
          if (submission.temperature != null)
            _DetailRow(
              label: 'Temperature',
              value: '${submission.temperature} °C',
            ),
          if (submission.notes != null && submission.notes!.isNotEmpty)
            _DetailRow(label: 'Notes', value: submission.notes!, isLast: true)
          else
            _DetailRow(label: 'Notes', value: '—', isLast: true, muted: true),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;
  final bool muted;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.ink3,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: muted ? AppColors.ink3 : AppColors.ink,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Queue progress steps ─────────────────────────────────

class _QueueStepsCard extends StatelessWidget {
  const _QueueStepsCard();

  @override
  Widget build(BuildContext context) {
    // Step 3 (In Queue) is current
    const steps = ['Submitted', 'Assessed', 'In Queue', 'Your Turn', 'Doctor'];
    const currentStep = 2; // 0-indexed

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIndex = i ~/ 2;
            final isDone = stepIndex < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: isDone ? AppColors.accent : AppColors.border,
              ),
            );
          }

          final stepIndex = i ~/ 2;
          final isDone = stepIndex < currentStep;
          final isCurrent = stepIndex == currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
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
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: Colors.white,
                        )
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: isCurrent
                                ? AppColors.accent
                                : AppColors.ink3,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: isDone || isCurrent
                      ? AppColors.accent
                      : AppColors.ink3,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback? onTap;
  final String? disabledReason;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.outlined = false,
    this.onTap,
    this.disabledReason,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: disabled
                  ? AppColors.border
                  : outlined
                  ? Colors.transparent
                  : color,
              borderRadius: BorderRadius.circular(12),
              border: outlined
                  ? Border.all(
                      color: disabled ? AppColors.border : color,
                      width: 1.5,
                    )
                  : null,
              boxShadow: (!outlined && !disabled)
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: disabled
                      ? AppColors.ink3
                      : outlined
                      ? color
                      : Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: disabled
                        ? AppColors.ink3
                        : outlined
                        ? color
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (disabledReason != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              disabledReason!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.ink3,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}
