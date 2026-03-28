import 'package:flutter/material.dart';
import '../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.hero, AppColors.hero2, AppColors.hero3],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good afternoon",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          "Khalid Gurashi",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    _NotificationBell(),
                  ],
                ),
                const SizedBox(height: 16),
                _DoctorAvailabilityChip(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _HStatCard(
                        label: "Queue Now",
                        value: "15",
                        sub: "patients ahead",
                        color: const Color(0xFF7ECFF5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HStatCard(
                        label: "Est. Time",
                        value: "~35m",
                        sub: "before your turn",
                        color: const Color(0xFFFFBE50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Additional content goes here (Cards, Sections, etc.)
      ],
    );
  }
}

class _HStatCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _HStatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'DM Mono',
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorAvailabilityChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x4716714A),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0x8016714A)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: Color(0xFF34D48A)),
          SizedBox(width: 8),
          Text(
            "Dr. Available",
            style: TextStyle(
              color: Color(0xFF34D48A),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
            color: Colors.white.withOpacity(0.1),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
        ),
      ],
    );
  }
}
