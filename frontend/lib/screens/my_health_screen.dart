import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// DATA MODELS
// ---------------------------------------------------------------------------

// ── Visit History ────────────────────────────────────────────────────────────
// Backend: GET /api/v1/visits?patient_id={id}

enum VisitStatus { complete, pending }

class LabResultRow {
  final String testName;
  final String result;
  final String reference;
  final bool isFlagged; // red
  final bool isWarning; // amber

  const LabResultRow({
    required this.testName,
    required this.result,
    required this.reference,
    this.isFlagged = false,
    this.isWarning = false,
  });
}

class VisitRecord {
  final String visitId; // visit.visit_id
  final String diagnosis; // consultation.confirmed_symptoms
  final String date; // visit.created_at (formatted)
  final String doctorName; // e.g. "Dr. Kato"
  final VisitStatus status; // visit.status
  final String? notes; // consultation.diagnostic_notes
  final List<LabResultRow> labResults;

  const VisitRecord({
    required this.visitId,
    required this.diagnosis,
    required this.date,
    required this.doctorName,
    required this.status,
    this.notes,
    this.labResults = const [],
  });
}

// ── Vitals ───────────────────────────────────────────────────────────────────
// Backend: GET /api/v1/vitals?patient_id={id}&visit_id={id}

class VitalReading {
  final String label; // e.g. "Temp"
  final String value; // e.g. "38.7"
  final String unit; // e.g. "°C"
  final bool isHigh;
  final bool isLow;

  const VitalReading({
    required this.label,
    required this.value,
    required this.unit,
    this.isHigh = false,
    this.isLow = false,
  });
}

class TempBarEntry {
  final String day; // e.g. "M"
  final double tempC; // raw value for bar height calculation
  final bool isNormal; // green
  final bool isHigh; // red

  const TempBarEntry({
    required this.day,
    required this.tempC,
    this.isNormal = false,
    this.isHigh = false,
  });
}

class VisitFrequencyEntry {
  final String period; // e.g. "Mar 2025"
  final int count;
  final double fraction; // 0.0–1.0 for bar width
  final Color barColor;

  const VisitFrequencyEntry({
    required this.period,
    required this.count,
    required this.fraction,
    required this.barColor,
  });
}

// ── Monitoring ───────────────────────────────────────────────────────────────
// Backend: GET /api/v1/conditions?patient_id={id}

enum ConditionFlag { monitor, seasonal, resolved }

class RecurringCondition {
  final String name;
  final String detail; // e.g. "3 confirmed episodes"
  final ConditionFlag flag;
  final IconData icon;

  const RecurringCondition({
    required this.name,
    required this.detail,
    required this.flag,
    required this.icon,
  });
}

// ---------------------------------------------------------------------------
// MOCK DATA
// ---------------------------------------------------------------------------

const _mockVisits = [
  VisitRecord(
    visitId: 'V-001',
    diagnosis: 'Malaria (Uncomplicated)',
    date: '08 Mar 2025',
    doctorName: 'Dr. Kato',
    status: VisitStatus.complete,
    notes:
        'RDT positive. Hb slightly below reference. 3-day artemether course prescribed. Return if fever persists.',
    labResults: [
      LabResultRow(
        testName: 'Malaria RDT',
        result: 'POS',
        reference: 'NEG',
        isFlagged: true,
      ),
      LabResultRow(
        testName: 'Haemoglobin',
        result: '10.8',
        reference: '12–16',
        isWarning: true,
      ),
      LabResultRow(
        testName: 'WBC',
        result: '12,400',
        reference: '4–11K',
        isFlagged: true,
      ),
    ],
  ),
  VisitRecord(
    visitId: 'V-002',
    diagnosis: 'Upper Respiratory Infection',
    date: '14 Jan 2025',
    doctorName: 'Dr. Ssali',
    status: VisitStatus.complete,
    notes:
        'Mild URI. Symptomatic treatment. No labs required. Follow-up not needed.',
  ),
  VisitRecord(
    visitId: 'V-003',
    diagnosis: 'Awaiting Lab Results',
    date: 'Today',
    doctorName: 'Dr. Kato',
    status: VisitStatus.pending,
    notes:
        'FBC + Typhoid test ordered. You will be notified when results are ready.',
  ),
];

const _mockVitals = [
  VitalReading(label: 'Temp', value: '38.7', unit: '°C', isHigh: true),
  VitalReading(label: 'Pulse', value: '96', unit: 'bpm'),
  VitalReading(label: 'Hb', value: '10.8', unit: 'g/dL', isLow: true),
];

final _mockTempBars = [
  const TempBarEntry(day: 'M', tempC: 36.5, isNormal: true),
  const TempBarEntry(day: 'T', tempC: 37.1, isNormal: true),
  const TempBarEntry(day: 'W', tempC: 37.9),
  const TempBarEntry(day: 'T', tempC: 38.9, isHigh: true),
  const TempBarEntry(day: 'F', tempC: 37.8),
  const TempBarEntry(day: 'S', tempC: 36.8, isNormal: true),
  const TempBarEntry(day: 'S', tempC: 36.4, isNormal: true),
];

final _mockFrequency = [
  VisitFrequencyEntry(
    period: 'Mar 2025',
    count: 1,
    fraction: 0.5,
    barColor: const Color(0xFFB81C24),
  ),
  VisitFrequencyEntry(
    period: 'Jan 2025',
    count: 1,
    fraction: 0.5,
    barColor: const Color(0xFF1A7FC1),
  ),
  VisitFrequencyEntry(
    period: 'Oct 2024',
    count: 1,
    fraction: 0.5,
    barColor: const Color(0xFF1A7FC1),
  ),
  VisitFrequencyEntry(
    period: 'Jun 2024',
    count: 2,
    fraction: 1.0,
    barColor: const Color(0xFFA05C00),
  ),
];

const _mockConditions = [
  RecurringCondition(
    name: 'Malaria',
    detail: '3 confirmed episodes',
    flag: ConditionFlag.monitor,
    icon: Icons.monitor_heart_outlined,
  ),
  RecurringCondition(
    name: 'Upper Respiratory',
    detail: '2 episodes · seasonal',
    flag: ConditionFlag.seasonal,
    icon: Icons.air_outlined,
  ),
];

const _mockMonitoringNote =
    'Given your recurring malaria history, report any fever above 38°C immediately. '
    'Haemoglobin levels are being monitored — follow up in 2 weeks.';

// ---------------------------------------------------------------------------
// SCREEN
// ---------------------------------------------------------------------------

class MyHealthScreen extends StatefulWidget {
  const MyHealthScreen({super.key});

  @override
  State<MyHealthScreen> createState() => _MyHealthScreenState();
}

class _MyHealthScreenState extends State<MyHealthScreen> {
  int _tabIndex = 0;

  static const _tabs = ['Visit History', 'Vitals & Trends', 'Monitoring'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Sub-tab bar (the .ftabs from prototype) ──────────────────────
        _SubTabBar(
          tabs: _tabs,
          selectedIndex: _tabIndex,
          onTap: (i) => setState(() => _tabIndex = i),
        ),

        // ── Tab content ──────────────────────────────────────────────────
        Expanded(
          child: IndexedStack(
            index: _tabIndex,
            children: const [
              _VisitHistoryTab(),
              _VitalsTab(),
              _MonitoringTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SUB-TAB BAR
// ---------------------------------------------------------------------------

class _SubTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final void Function(int) onTap;

  const _SubTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E4EB))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (i) {
            final isActive = i == selectedIndex;
            return Padding(
              padding: EdgeInsets.only(right: i < tabs.length - 1 ? 6 : 0),
              child: GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFE8F4FB)
                        : const Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF1A7FC1)
                          : const Color(0xFFE0E4EB),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? const Color(0xFF1A7FC1)
                          : const Color(0xFF44556A),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 1 — VISIT HISTORY
// ---------------------------------------------------------------------------

class _VisitHistoryTab extends StatelessWidget {
  const _VisitHistoryTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: _mockVisits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _VisitCard(visit: _mockVisits[i]),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final VisitRecord visit;
  const _VisitCard({required this.visit});

  Color get _accentColor {
    if (visit.status == VisitStatus.pending) return const Color(0xFFA05C00);
    if (visit.labResults.any((r) => r.isFlagged))
      return const Color(0xFF1A7FC1);
    return const Color(0xFF8A9BB0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: _accentColor, width: 3.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.diagnosis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF151E2B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${visit.date} · ${visit.doctorName}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFF8A9BB0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _StatusChip(status: visit.status),
              ],
            ),
          ),
          // Notes
          if (visit.notes != null) ...[
            const Divider(height: 1, color: Color(0xFFE0E4EB)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
              child: Text(
                visit.notes!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF44556A),
                  height: 1.6,
                ),
              ),
            ),
          ],
          // Lab table
          if (visit.labResults.isNotEmpty) ...[
            Container(
              color: const Color(0xFFF8F9FB),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: const Text(
                'LAB RESULTS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Color(0xFF8A9BB0),
                ),
              ),
            ),
            _LabTable(rows: visit.labResults),
          ],
        ],
      ),
    );
  }
}

class _LabTable extends StatelessWidget {
  final List<LabResultRow> rows;
  const _LabTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          // Headers
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: const [
                Expanded(child: _TH('Test')),
                SizedBox(width: 64, child: _TH('Result')),
                SizedBox(width: 56, child: _TH('Ref')),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E4EB)),
          ...List.generate(
            rows.length,
            (i) => _LabRow(row: rows[i], isLast: i == rows.length - 1),
          ),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: Color(0xFF8A9BB0),
    ),
  );
}

class _LabRow extends StatelessWidget {
  final LabResultRow row;
  final bool isLast;
  const _LabRow({required this.row, required this.isLast});

  Color get _resultColor {
    if (row.isFlagged) return const Color(0xFFB81C24);
    if (row.isWarning) return const Color(0xFFA05C00);
    return const Color(0xFF151E2B);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFE0E4EB))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              row.testName,
              style: const TextStyle(fontSize: 12, color: Color(0xFF151E2B)),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              row.result,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _resultColor,
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              row.reference,
              style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BB0)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final VisitStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPending = status == VisitStatus.pending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFF7EA) : const Color(0xFFEAFAF2),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isPending ? const Color(0xFFF5C97A) : const Color(0xFF96DEBB),
        ),
      ),
      child: Text(
        isPending ? 'Pending' : 'Complete',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: isPending ? const Color(0xFFA05C00) : const Color(0xFF16714A),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 2 — VITALS & TRENDS
// ---------------------------------------------------------------------------

class _VitalsTab extends StatelessWidget {
  const _VitalsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _SectionLabel('Current Vitals · Mar 8'),
        const SizedBox(height: 8),
        // Vitals grid
        Row(
          children: _mockVitals
              .map(
                (v) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: v == _mockVitals.last ? 0 : 10,
                    ),
                    child: _VitalCard(vital: v),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        _SectionLabel('Temperature This Week'),
        const SizedBox(height: 8),
        _TempChart(bars: _mockTempBars),
        const SizedBox(height: 18),
        _SectionLabel('Visit Frequency'),
        const SizedBox(height: 8),
        _FrequencyCard(entries: _mockFrequency),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _VitalCard extends StatelessWidget {
  final VitalReading vital;
  const _VitalCard({required this.vital});

  Color get _valueColor {
    if (vital.isHigh) return const Color(0xFFB81C24);
    if (vital.isLow) return const Color(0xFFA05C00);
    return const Color(0xFF151E2B);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            vital.label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.07 * 9.5,
              color: Color(0xFF8A9BB0),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            vital.value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            vital.unit,
            style: const TextStyle(fontSize: 9.5, color: Color(0xFF8A9BB0)),
          ),
        ],
      ),
    );
  }
}

class _TempChart extends StatelessWidget {
  final List<TempBarEntry> bars;
  const _TempChart({required this.bars});

  Color _barColor(TempBarEntry e) {
    if (e.isHigh) return const Color(0xFFB81C24);
    if (e.isNormal) return const Color(0xFF16714A);
    return const Color(0xFFF5A623);
  }

  // Normalise temp to bar height: range 36°–39° → 0–70px
  double _height(double temp) {
    const min = 36.0, max = 39.0, maxH = 70.0;
    return ((temp - min) / (max - min)).clamp(0.0, 1.0) * maxH;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars
                  .map(
                    (e) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: _height(e.tempC).clamp(8.0, 70.0),
                              decoration: BoxDecoration(
                                color: _barColor(e).withValues(alpha: 0.85),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(3),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              e.day,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 8.5,
                                color: Color(0xFF8A9BB0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '36.1°',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: Color(0xFF8A9BB0),
                ),
              ),
              Text(
                'Peak 38.9°',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB81C24),
                ),
              ),
              Text(
                '↓ Improving',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF16714A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FrequencyCard extends StatelessWidget {
  final List<VisitFrequencyEntry> entries;
  const _FrequencyCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        e.period,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF151E2B),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: e.fraction,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE6E9EE),
                          valueColor: AlwaysStoppedAnimation<Color>(e.barColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 14,
                      child: Text(
                        '${e.count}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8A9BB0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 3 — MONITORING
// ---------------------------------------------------------------------------

class _MonitoringTab extends StatelessWidget {
  const _MonitoringTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _SectionLabel('Recurring Conditions'),
        const SizedBox(height: 8),
        _ConditionsCard(conditions: _mockConditions),
        const SizedBox(height: 12),
        _DoctorNoteBox(note: _mockMonitoringNote),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ConditionsCard extends StatelessWidget {
  final List<RecurringCondition> conditions;
  const _ConditionsCard({required this.conditions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: List.generate(conditions.length, (i) {
          final c = conditions[i];
          final isLast = i == conditions.length - 1;
          return Container(
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(bottom: BorderSide(color: Color(0xFFE0E4EB))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E9EE),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(c.icon, size: 16, color: const Color(0xFF44556A)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF151E2B),
                        ),
                      ),
                      Text(
                        c.detail,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A9BB0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _ConditionChip(flag: c.flag),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  final ConditionFlag flag;
  const _ConditionChip({required this.flag});

  @override
  Widget build(BuildContext context) {
    final Color bg, fg, border;
    final String label;
    switch (flag) {
      case ConditionFlag.monitor:
        bg = const Color(0xFFFFF2F2);
        fg = const Color(0xFFB81C24);
        border = const Color(0xFFF5AAAA);
        label = 'Monitor';
      case ConditionFlag.seasonal:
        bg = const Color(0xFFFFF7EA);
        fg = const Color(0xFFA05C00);
        border = const Color(0xFFF5C97A);
        label = 'Seasonal';
      case ConditionFlag.resolved:
        bg = const Color(0xFFEAFAF2);
        fg = const Color(0xFF16714A);
        border = const Color(0xFF96DEBB);
        label = 'Resolved';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _DoctorNoteBox extends StatelessWidget {
  final String note;
  const _DoctorNoteBox({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA8D4ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DOCTOR'S MONITORING NOTE",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A7FC1),
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF44556A),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SHARED
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF44556A),
        letterSpacing: 0.07 * 11,
      ),
    );
  }
}
