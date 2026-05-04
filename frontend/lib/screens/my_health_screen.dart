import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

// ── Visit History ────────────────────────────────────────────────────────────
// Backend: GET /api/v1/visits?patient_id={id}

enum VisitStatus { complete, pending }

class LabResultRow {
  final String testName; // Backend: lab_result.test_name
  final String result; // Backend: lab_result.result_value
  final String reference; // Backend: lab_result.reference_range
  final bool isFlagged; // Backend: lab_result.flag == 'H' or positive
  final bool isWarning; // Backend: lab_result.flag == 'L'

  const LabResultRow({
    required this.testName,
    required this.result,
    required this.reference,
    this.isFlagged = false,
    this.isWarning = false,
  });
}

class VisitRecord {
  final String visitId; // Backend: visit.visit_id
  final String diagnosis; // Backend: consultation.confirmed_symptoms
  final String date; // Backend: visit.created_at (formatted)
  final String doctorName; // Backend: doctor.full_name
  final VisitStatus status; // Backend: visit.status
  final String? notes; // Backend: consultation.diagnostic_notes
  final List<LabResultRow> labResults; // Backend: lab_result.result_data[]

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
  final String label; // Backend: vital.label
  final String value; // Backend: vital.value
  final String unit; // Backend: vital.unit
  final bool isHigh; // Backend: derived from vital.flag
  final bool isLow; // Backend: derived from vital.flag

  const VitalReading({
    required this.label,
    required this.value,
    required this.unit,
    this.isHigh = false,
    this.isLow = false,
  });
}

class TempBarEntry {
  final String day; // Backend: derived from vital.recorded_at
  final double tempC; // Backend: vital.value (temperature)
  final bool isNormal; // Backend: derived from vital.flag
  final bool isHigh; // Backend: derived from vital.flag

  const TempBarEntry({
    required this.day,
    required this.tempC,
    this.isNormal = false,
    this.isHigh = false,
  });
}

class VisitFrequencyEntry {
  final String period; // Backend: derived from visit.created_at
  final int count; // Backend: count of visits in period
  final double fraction; // Backend: derived — count / max count
  final Color barColor; // Backend: derived from visit severity

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
  final String name; // Backend: condition.name
  final String detail; // Backend: derived — episode count + type
  final ConditionFlag flag; // Backend: condition.flag
  final IconData icon; // Backend: derived from condition.type

  const RecurringCondition({
    required this.name,
    required this.detail,
    required this.flag,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────────────────────────────────────

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
    barColor: AppColors.err,
  ),
  VisitFrequencyEntry(
    period: 'Jan 2025',
    count: 1,
    fraction: 0.5,
    barColor: AppColors.accent,
  ),
  VisitFrequencyEntry(
    period: 'Oct 2024',
    count: 1,
    fraction: 0.5,
    barColor: AppColors.accent,
  ),
  VisitFrequencyEntry(
    period: 'Jun 2024',
    count: 2,
    fraction: 1.0,
    barColor: AppColors.warn,
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

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SubTabBar(
          tabs: _tabs,
          selectedIndex: _tabIndex,
          onTap: (i) => setState(() => _tabIndex = i),
        ),
        Expanded(
          child: IndexedStack(
            index: _tabIndex,
            sizing: StackFit.expand,
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

// ─────────────────────────────────────────────────────────────────────────────
// SUB-TAB BAR
// Fix: width: double.infinity + no horizontal margin so background reaches edges
// ─────────────────────────────────────────────────────────────────────────────

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
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        ? AppColors.accentLight
                        : AppColors.surface2,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isActive ? AppColors.accent : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.accent : AppColors.ink2,
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

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — VISIT HISTORY
// ─────────────────────────────────────────────────────────────────────────────

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
    if (visit.status == VisitStatus.pending) return AppColors.warn;
    if (visit.labResults.any((r) => r.isFlagged)) return AppColors.accent;
    return AppColors.ink3;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${visit.date} · ${visit.doctorName}',
                        style: const TextStyle(
                          fontFamily: 'DMMono',
                          fontSize: 11,
                          color: AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // ── Uses shared AppStatusChip ──
                AppStatusChip(
                  label: visit.status == VisitStatus.pending
                      ? 'Pending'
                      : 'Complete',
                  status: visit.status == VisitStatus.pending
                      ? AppStatus.warn
                      : AppStatus.ok,
                ),
              ],
            ),
          ),
          // Notes
          if (visit.notes != null) ...[
            Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
              child: Text(
                visit.notes!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.ink2,
                  height: 1.6,
                ),
              ),
            ),
          ],
          // Lab table
          if (visit.labResults.isNotEmpty) ...[
            Container(
              color: AppColors.surface2,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: const Text(
                'LAB RESULTS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.ink3,
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
      color: AppColors.surface2,
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
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
          Divider(height: 1, color: AppColors.border),
          ...List.generate(
            rows.length,
            (i) => _LabRowWidget(row: rows[i], isLast: i == rows.length - 1),
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
      color: AppColors.ink3,
    ),
  );
}

class _LabRowWidget extends StatelessWidget {
  final LabResultRow row;
  final bool isLast;
  const _LabRowWidget({required this.row, required this.isLast});

  Color get _resultColor {
    if (row.isFlagged) return AppColors.err;
    if (row.isWarning) return AppColors.warn;
    return AppColors.ink;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              row.testName,
              style: const TextStyle(fontSize: 12, color: AppColors.ink),
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
                fontFamily: 'DMMono',
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              row.reference,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.ink3,
                fontFamily: 'DMMono',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — VITALS & TRENDS
// ─────────────────────────────────────────────────────────────────────────────

class _VitalsTab extends StatelessWidget {
  const _VitalsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // ── Uses shared AppSectionHeader ──
        const AppSectionHeader(title: 'Current Vitals · Mar 8'),
        const SizedBox(height: 8),
        Row(
          children: _mockVitals.asMap().entries.map((e) {
            final isLast = e.key == _mockVitals.length - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 10),
                child: _VitalCard(vital: e.value),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        const AppSectionHeader(title: 'Temperature This Week'),
        const SizedBox(height: 8),
        _TempChart(bars: _mockTempBars),
        const SizedBox(height: 18),
        const AppSectionHeader(title: 'Visit Frequency'),
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
    if (vital.isHigh) return AppColors.err;
    if (vital.isLow) return AppColors.warn;
    return AppColors.ink;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            vital.value,
            style: TextStyle(
              fontFamily: 'DMMono',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            vital.unit,
            style: const TextStyle(fontSize: 9.5, color: AppColors.ink3),
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
    if (e.isHigh) return AppColors.err;
    if (e.isNormal) return AppColors.ok;
    return const Color(0xFFF5A623); // amber mid — not a status token, kept raw
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
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((e) {
                return Expanded(
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
                            fontFamily: 'DMMono',
                            fontSize: 8.5,
                            color: AppColors.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '36.1°',
                style: TextStyle(
                  fontFamily: 'DMMono',
                  fontSize: 10,
                  color: AppColors.ink3,
                ),
              ),
              Text(
                'Peak 38.9°',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.err,
                ),
              ),
              Text(
                '↓ Improving',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ok,
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
        children: entries.map((e) {
          return Padding(
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
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: e.fraction,
                      minHeight: 6,
                      backgroundColor: AppColors.bg2,
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
                      fontFamily: 'DMMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink3,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — MONITORING
// ─────────────────────────────────────────────────────────────────────────────

class _MonitoringTab extends StatelessWidget {
  const _MonitoringTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // ── Uses shared AppSectionHeader ──
        const AppSectionHeader(title: 'Recurring Conditions'),
        const SizedBox(height: 8),
        _ConditionsCard(conditions: _mockConditions),
        const SizedBox(height: 12),
        // ── Uses shared AppInfoBox ──
        const AppInfoBox(
          label: "Doctor's Monitoring Note",
          body: _mockMonitoringNote,
          variant: AppInfoVariant.accent,
        ),
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
        children: List.generate(conditions.length, (i) {
          final c = conditions[i];
          final isLast = i == conditions.length - 1;
          return Container(
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(bottom: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(c.icon, size: 16, color: AppColors.ink2),
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
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        c.detail,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // ── Uses shared AppStatusChip ──
                AppStatusChip(
                  label: switch (c.flag) {
                    ConditionFlag.monitor => 'Monitor',
                    ConditionFlag.seasonal => 'Seasonal',
                    ConditionFlag.resolved => 'Resolved',
                  },
                  status: switch (c.flag) {
                    ConditionFlag.monitor => AppStatus.err,
                    ConditionFlag.seasonal => AppStatus.warn,
                    ConditionFlag.resolved => AppStatus.ok,
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
