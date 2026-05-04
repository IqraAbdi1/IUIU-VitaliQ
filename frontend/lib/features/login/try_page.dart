import 'package:flutter/material.dart';

// Prescriptions Section
class _PrescriptionsSection extends StatelessWidget {
  const _PrescriptionsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Prescriptions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F4E6E),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Refill',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _PrescriptionItem(
            name: 'Amoxicillin',
            dosage: '500mg • Twice daily',
            refills: '2 refills left',
          ),
          const Divider(height: 20),
          const _PrescriptionItem(
            name: 'Lisinopril',
            dosage: '10mg • Once daily',
            refills: '1 refill left',
          ),
          const Divider(height: 20),
          const _PrescriptionItem(
            name: 'Metformin',
            dosage: '850mg • With meals',
            refills: '3 refills left',
          ),
        ],
      ),
    );
  }
}

class _PrescriptionItem extends StatelessWidget {
  final String name;
  final String dosage;
  final String refills;

  const _PrescriptionItem({
    required this.name,
    required this.dosage,
    required this.refills,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.medication_outlined,
            color: Color(0xFF27AE60),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2F3A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dosage,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9E3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            refills,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFE67E22),
            ),
          ),
        ),
      ],
    );
  }
}

// Virtual Consultation Card
class _VirtualConsultationCard extends StatelessWidget {
  const _VirtualConsultationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C7DA0), Color(0xFF1F6390)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C7DA0).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Virtual Consultation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with a doctor from anywhere',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Start Now',
                    style: TextStyle(
                      color: Color(0xFF2C7DA0),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.videocam_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

// Queue Status Card
class _QueueStatusCard extends StatelessWidget {
  const _QueueStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.people_outline,
                color: Color(0xFF2C7DA0),
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Queue Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F4E6E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QueueInfoItem(
                label: 'Walk-in',
                value: '8',
                color: const Color(0xFFE67E22),
              ),
              _QueueInfoItem(
                label: 'Appointments',
                value: '12',
                color: const Color(0xFF2C7DA0),
              ),
              _QueueInfoItem(
                label: 'Est. Wait',
                value: '25 min',
                color: const Color(0xFF27AE60),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.45,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF2C7DA0),
            borderRadius: BorderRadius.circular(8),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your position: 5th',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Updated just now',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QueueInfoItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}



//the previous dashboard 
import 'package:flutter/material.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 App Bar
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Patient Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'About') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              } else if (value == 'Privacy Policy') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                );
              } else if (value == 'Clinic Map') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ClinicMapPage()),
                );
              } else if (value == 'Logout') {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'About', child: Text('About App')),
              const PopupMenuItem(value: 'Privacy Policy', child: Text('Privacy Policy')),
              const PopupMenuItem(value: 'Clinic Map', child: Text('Clinic Map')),
              const PopupMenuItem(value: 'Logout', child: Text('Logout')),
            ],
          ),
        ],
      ),

      // 🔹 Body
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // 🔹 Side bar suggestion placeholder
            // For now, we can leave it as empty or a small vertical menu
            // You might later add icons: Appointments, Lab Results, Profile, etc.

            // 🔹 Main card for "Got Symptoms? Get Tested"
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[900], // navy blue
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // Placeholder for symptom icon
                  const Icon(Icons.sick, size: 50, color: Colors.white),
                  const SizedBox(width: 20),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Got Symptoms?',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Get Tested',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 Dots for slideshow navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to Announcement page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnnouncementPage()),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            // 🔹 You can add more content below later (appointments, lab results, etc.)
          ],
        ),
      ),
    );
  }
}

// 🔹 Placeholder pages
class AboutPage extends StatelessWidget { const AboutPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('About App')), body: const Center(child: Text('App description here'))); }
class PrivacyPolicyPage extends StatelessWidget { const PrivacyPolicyPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Privacy Policy')), body: const Center(child: Text('Privacy policy content'))); }
class ClinicMapPage extends StatelessWidget { const ClinicMapPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Clinic Map')), body: const Center(child: Text('Map goes here'))); }
class AnnouncementPage extends StatelessWidget { const AnnouncementPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Announcements')), body: const Center(child: Text('Announcements content'))); } 