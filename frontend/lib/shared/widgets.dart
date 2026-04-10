import 'package:flutter/material.dart';
import '../theme.dart';

// ══════════════════════════════════════════════
// AppStatCard
// Used in: DoctorQueueScreen, PharmacyScreen, AdminScreen
// Backend: GET /api/v1/queue/stats or GET /api/v1/analytics/summary
// ══════════════════════════════════════════════

class AppStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color valueColor;

  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.valueColor = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.ink3,
              letterSpacing: 0.07 * 10,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor,
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

// ══════════════════════════════════════════════
// AppStatusChip
// Used in: every screen — visit history, queue cards, stock rows, lab results
// ══════════════════════════════════════════════

enum AppStatus { ok, warn, err, neutral, accent }

class AppStatusChip extends StatelessWidget {
  final String label;
  final AppStatus status;

  const AppStatusChip({super.key, required this.label, required this.status});

  Color get _bg => switch (status) {
    AppStatus.ok => AppColors.okBg,
    AppStatus.warn => AppColors.warnBg,
    AppStatus.err => AppColors.errBg,
    AppStatus.accent => AppColors.accentLight,
    AppStatus.neutral => AppColors.bg2,
  };

  Color get _fg => switch (status) {
    AppStatus.ok => AppColors.ok,
    AppStatus.warn => AppColors.warn,
    AppStatus.err => AppColors.err,
    AppStatus.accent => AppColors.accent,
    AppStatus.neutral => AppColors.ink2,
  };

  Color get _border => switch (status) {
    AppStatus.ok => AppColors.okBorder,
    AppStatus.warn => AppColors.warnBorder,
    AppStatus.err => AppColors.errBorder,
    AppStatus.accent => AppColors.accentMid,
    AppStatus.neutral => AppColors.border,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: _border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: _fg,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// AppInfoBox
// Used in: prescription instructions, doctor's monitoring note,
//          ML alerts, AI assessment boxes, restock recommendations
// ══════════════════════════════════════════════

enum AppInfoVariant { accent, warn, err }

class AppInfoBox extends StatelessWidget {
  final String label;
  final String body;
  final AppInfoVariant variant;

  const AppInfoBox({
    super.key,
    required this.label,
    required this.body,
    this.variant = AppInfoVariant.accent,
  });

  Color get _bg => switch (variant) {
    AppInfoVariant.accent => AppColors.accentLight,
    AppInfoVariant.warn => AppColors.warnBg,
    AppInfoVariant.err => AppColors.errBg,
  };

  Color get _border => switch (variant) {
    AppInfoVariant.accent => AppColors.accentMid,
    AppInfoVariant.warn => AppColors.warnBorder,
    AppInfoVariant.err => AppColors.errBorder,
  };

  Color get _labelColor => switch (variant) {
    AppInfoVariant.accent => AppColors.accent,
    AppInfoVariant.warn => AppColors.warn,
    AppInfoVariant.err => AppColors.err,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _labelColor,
              letterSpacing: 0.07 * 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.ink2,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// AppSectionHeader
// Used in: every scrollable page with a title + action link
// ══════════════════════════════════════════════

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.ink2,
            letterSpacing: 0.07 * 10,
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
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
