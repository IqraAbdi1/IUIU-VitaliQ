import 'package:flutter/material.dart';
import '../theme.dart';

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
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE0E4EB)),
              bottom: BorderSide(color: Color(0xFFE0E4EB)),
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
      children: const [
        _SectionLabel(label: 'Queue Overview · Today'),
        SizedBox(height: 10),
        _EmptyCard(
          icon: Icons.format_list_bulleted_rounded,
          title: 'Queue stats unavailable',
          subtitle: 'Connect to GET /api/v1/queue/stats?role=admin',
        ),
        SizedBox(height: 14),
        _SectionLabel(label: 'Visit Trend · This Week'),
        SizedBox(height: 10),
        _EmptyCard(
          icon: Icons.bar_chart_rounded,
          title: 'No visit data yet',
          subtitle: 'Connect to GET /api/v1/analytics/summary',
        ),
        SizedBox(height: 14),
        _SectionLabel(label: 'Stock Alerts'),
        SizedBox(height: 10),
        _EmptyCard(
          icon: Icons.inventory_2_rounded,
          title: 'No stock alerts',
          subtitle: 'Connect to GET /api/v1/medicines',
        ),
        SizedBox(height: 14),
        _SectionLabel(label: 'ML Alerts'),
        SizedBox(height: 10),
        _EmptyCard(
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
      children: const [
        _SectionLabel(label: 'Monthly Summary'),
        SizedBox(height: 10),
        _EmptyCard(
          icon: Icons.bar_chart_rounded,
          title: 'No analytics data yet',
          subtitle: 'Connect to GET /api/v1/analytics/summary',
        ),
        SizedBox(height: 14),
        _SectionLabel(label: 'Disease Distribution'),
        SizedBox(height: 10),
        _EmptyCard(
          icon: Icons.pie_chart_outline_rounded,
          title: 'No disease data yet',
          subtitle: 'Connect to GET /api/v1/analytics/summary',
        ),
        SizedBox(height: 14),
        _SectionLabel(label: 'Top Medicine Usage'),
        SizedBox(height: 10),
        _EmptyCard(
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
          color: isActive ? const Color(0xFFE8F4FB) : const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isActive ? const Color(0xFF1A7FC1) : const Color(0xFFE0E4EB),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isActive ? const Color(0xFF1A7FC1) : const Color(0xFF44556A),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E4EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: const Color(0xFF8A9BB0)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF44556A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8A9BB0),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF44556A),
        letterSpacing: 0.7,
      ),
    );
  }
}
