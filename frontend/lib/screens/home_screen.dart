import 'package:flutter/material.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- DYNAMIC DATA ---
  // We use variables here so the UI can update automatically when data changes.
  // In the future, these will be fetched from an API.
  String userName = "Khalid Gurashi";
  int queuePosition = 7; // Note: removed leading zero to avoid octal errors
  int estimatedWaitMinutes = 13;
  bool isDoctorAvailable = false;
  bool hasNewNotifications = false;
  bool isPatientInQueue = false;

  // Mock data for the daily schedule. 'done' tracks the checkbox state.
  final List<Map<String, dynamic>> todayReminders = [
    {
      "time": "08:00",
      "med": "Artemether-Lumefantrine",
      "dose": "2 tablets · with food",
      "done": true,
    },
    {
      "time": "14:00",
      "med": "Paracetamol 500mg",
      "dose": "1 tablet · if fever",
      "done": false,
    },
    {
      "time": "20:00",
      "med": "Artemether-Lumefantrine",
      "dose": "2 tablets · with food",
      "done": false,
    },
  ];

  final List<Map<String, dynamic>> medicines = [
    {"name": "Paracetamol 500mg", "status": "Available"},
    {"name": "Amoxicillin 500mg", "status": "Limited"},
    {"name": "Cetirizine 10mg", "status": "Available"},
    {"name": "Ibuprofen 400mg", "status": "Out of Stock"},
  ];

  String healthAdvisoryTitle = "Rainy Season Health Advisory";
  bool showHealthAdvisory = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Using CustomScrollView so the header and body scroll together naturally
          CustomScrollView(
            slivers: [
              // --- HERO HEADER ---
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.hero,
                        AppColors.hero2,
                        AppColors.hero3,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
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
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          _NotificationBell(hasUpdate: hasNewNotifications),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _DoctorAvailabilityChip(isAvailable: isDoctorAvailable),
                      const SizedBox(height: 24),
                      // These cards show the current queue status
                      Row(
                        children: [
                          Expanded(
                            child: _HStatCard(
                              label: "Queue Now",
                              value: queuePosition.toString(),
                              sub: "patients ahead",
                              color: const Color(0xFF7ECFF5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _HStatCard(
                              label: "Est. Time",
                              value: "~${estimatedWaitMinutes}m",
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
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // --- REMINDERS SECTION ---
              _buildSectionTitle("Today's Reminders"),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    color: AppColors.surface,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      // Map the list into interactive tiles
                      children: todayReminders.asMap().entries.map((entry) {
                        int index = entry.key;
                        var reminder = entry.value;
                        return _buildReminderTile(index, reminder);
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // --- CLINIC UPDATES ---
              _buildSectionTitle("Clinic Updates"),
              if (showHealthAdvisory)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: AdvisoryCard(title: healthAdvisoryTitle),
                  ),
                ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: UpdateCard(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // --- MEDICINE AVAILABILITY ---
              _buildSectionTitle("Medicine Availability"),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: MedicineCard(medicines: medicines),
                ),
              ),

              // Empty space at the bottom so the FAB doesn't cover the last card
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // --- DYNAMIC CTA BUTTON ---
          // This stays fixed at the bottom. It changes based on whether user has checked in.
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: isPatientInQueue
                ? _buildActiveQueueCta()
                : _buildCheckInCta(),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildSectionTitle(String title, {VoidCallback? onViewAll}) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title
                  .toUpperCase(), // Using .toUpperCase() here is cleaner than CSS-style textTransform
              style: TextStyle(
                color: AppColors.ink2,
                fontSize: 12,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  "View all →",
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTile(int index, Map<String, dynamic> reminder) {
    bool isDone = reminder["done"];
    return ListTile(
      leading: Text(
        reminder["time"],
        style: TextStyle(
          color: AppColors.ink3,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      title: Text(
        reminder["med"],
        style: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.bold,
          decoration: isDone
              ? TextDecoration.lineThrough
              : null, // Visual feedback for completed meds
        ),
      ),
      subtitle: Text(reminder["dose"], style: TextStyle(color: AppColors.ink2)),
      trailing: Checkbox(
        value: isDone,
        onChanged: (bool? value) {
          // Tell Flutter to repaint because data changed
          setState(() {
            todayReminders[index]["done"] = value!;
          });
        },
      ),
    );
  }

  Widget _buildCheckInCta() {
    return ElevatedButton.icon(
      onPressed: () {
        // Toggle the queue status and simulate a wait-time increase
        setState(() {
          isPatientInQueue = true;
          estimatedWaitMinutes = estimatedWaitMinutes + 10;
        });
      },
      icon: const Icon(Icons.sick_outlined, color: Colors.white),
      label: const Text("I'm feeling sick! Check-in"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildActiveQueueCta() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                "You're in the queue",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Shows the user their specific spot in the sequence
          Text(
            "#Q-${queuePosition + 1}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// --- SUB-WIDGET COMPONENTS ---
// These are extracted into separate classes to keep the main state class readable.

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'DM Mono',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorAvailabilityChip extends StatelessWidget {
  final bool isAvailable;
  const _DoctorAvailabilityChip({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final statusColor = isAvailable ? const Color(0xFF34D48A) : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: statusColor),
          const SizedBox(width: 10),
          Text(
            isAvailable ? "Dr. Available" : "Dr. On Break",
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final bool hasUpdate;
  const _NotificationBell({required this.hasUpdate});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            color: Colors.white.withValues(alpha: 0.1),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        if (hasUpdate)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class AdvisoryCard extends StatelessWidget {
  final String title;
  const AdvisoryCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2035),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "⚠ Health Advisory",
            style: TextStyle(
              color: Colors.red[300],
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Stay safe and follow clinic guidelines.",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class UpdateCard extends StatelessWidget {
  const UpdateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.ink.withValues(alpha: 0.05),
          child: Icon(Icons.info_outline, color: AppColors.ink2),
        ),
        title: Text(
          "Clinic closing early Friday",
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
        ),
        subtitle: const Text("March 12th"),
      ),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final List<Map<String, dynamic>> medicines;
  const MedicineCard({super.key, required this.medicines});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: medicines.map((med) {
          bool available = med["status"] == "Available";
          return ListTile(
            leading: Icon(
              Icons.medication_liquid_outlined,
              color: available ? Colors.green : Colors.orange,
            ),
            title: Text(med["name"]),
            trailing: Text(
              med["status"],
              style: TextStyle(
                color: available ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
