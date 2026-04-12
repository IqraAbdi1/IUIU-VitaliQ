import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border),
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _SubTab(
                  label: 'Queue Overview',
                  isActive: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
                const SizedBox(width: 7),
                _SubTab(
                  label: 'Analytics',
                  isActive: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _tabIndex == 0
              ? const _QueueOverviewTab()
              : const _AnalyticsTab(),
        ),
      ],
    );
  }
}

class _QueueOverviewTab extends StatelessWidget {
  const _QueueOverviewTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      children: [
        const AppSectionHeader(title: 'Queue Overview · Today'),
        const SizedBox(height: 10),
        const _EmptyCard(
          icon: Icons.format_list_bulleted_rounded,
          title: 'Queue stats unavailable',
          subtitle: 'Connect to GET /api/v1/queue/stats?role=admin',
        ),
        const SizedBox(height: 14),
        const AppSectionHeader(title: 'Visit Trend · This Week'),
        const SizedBox(height: 10),
        const _EmptyCard(
          icon: Icons.bar_chart_rounded,
          title: 'No visit data yet',
          subtitle: 'Connect to GET /api/v1/analytics/summary',
        ),
        const SizedBox(height: 14),
        const AppSectionHeader(title: 'Stock Alerts'),
        const SizedBox(height: 10),
        const _EmptyCard(
          icon: Icons.inventory_2_rounded,
          title: 'No stock alerts',
          subtitle: 'Connect to GET /api/v1/medicines',
        ),
        const SizedBox(height: 14),
        const AppSectionHeader(title: 'ML Alerts'),
        const SizedBox(height: 10),
        const _EmptyCard(
          icon: Icons.psychology_rounded,
          title: 'No ML alerts',
          subtitle: 'ML model not yet connected',
        ),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      children: [
        const AppSectionHeader(title: 'Monthly Summary'),
        const SizedBox(height: 10),
        const _EmptyCard(
          icon: Icons.bar_chart_rounded,
          title: 'No analytics data yet',
          subtitle: 'Connect to GET /api/v1/analytics/summary',
        ),
        const SizedBox(height: 14),
        const AppSectionHeader(title: 'Disease Distribution'),
        const SizedBox(height: 10),
        const _EmptyCard(
          icon: Icons.pie_chart_outline_rounded,
          title: 'No disease data yet',
          subtitle: 'Connect to GET /api/v1/analytics/summary',
        ),
        const SizedBox(height: 14),
        const AppSectionHeader(title: 'Top Medicine Usage'),
        const SizedBox(height: 10),
        const _EmptyCard(
          icon: Icons.medication_rounded,
          title: 'No usage data yet',
          subtitle: 'Connect to GET /api/v1/medicines',
        ),
      ],
    );
  }
}

class _SubTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SubTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentLight : AppColors.surface2,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.accent : AppColors.ink2,
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: AppColors.ink3),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.ink3,
              fontFamily: 'DMMono',
            ),
          ),
        ],
      ),
    );
  }
}
