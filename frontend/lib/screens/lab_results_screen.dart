import 'package:flutter/material.dart';
import '../theme.dart';

// ─────────────────────────────────────────────
// MOCK DATA  — Backend: GET /api/v1/lab-results?patient_id={id}
// ─────────────────────────────────────────────

enum _ResultStatus { ready, pending }

enum _FlagStatus { normal, flagHigh, flagLow, flagPositive, flagNegative }

class _LabResult {
  final String id;
  final String testGroupName; // Backend: lab_results.test_group_name
  final String visitDate; // Backend: visits.created_at
  final String requestedBy; // Backend: users.full_name (doctor)
  final String uploadedAt; // Backend: lab_results.uploaded_at
  final _ResultStatus status; // Backend: lab_results.status
  final List<_LabRow> rows; // Backend: lab_results.result_data (JSON)
  final String? notes; // Backend: lab_results.notes

  const _LabResult({
    required this.id,
    required this.testGroupName,
    required this.visitDate,
    required this.requestedBy,
    required this.uploadedAt,
    required this.status,
    required this.rows,
    this.notes,
  });
}

class _LabRow {
  final String test; // Backend: result_data[].test_name
  final String result; // Backend: result_data[].value
  final String reference; // Backend: result_data[].reference_range
  final _FlagStatus flag; // Backend: result_data[].flag

  const _LabRow({
    required this.test,
    required this.result,
    required this.reference,
    required this.flag,
  });
}

const _mockResults = [
  _LabResult(
    id: 'lr-001',
    testGroupName: 'FBC + Malaria RDT',
    visitDate: '08 Mar 2025',
    requestedBy: 'Dr. Kato',
    uploadedAt: '08 Mar 2025 · 09:48',
    status: _ResultStatus.ready,
    notes:
        'RDT positive. Hb slightly below reference. Monitor closely during treatment.',
    rows: [
      _LabRow(
        test: 'Malaria RDT',
        result: 'POSITIVE',
        reference: 'Negative',
        flag: _FlagStatus.flagPositive,
      ),
      _LabRow(
        test: 'Haemoglobin',
        result: '10.8 g/dL',
        reference: '12.0 – 16.0',
        flag: _FlagStatus.flagLow,
      ),
      _LabRow(
        test: 'WBC',
        result: '12,400 /μL',
        reference: '4,000 – 11,000',
        flag: _FlagStatus.flagHigh,
      ),
      _LabRow(
        test: 'Platelets',
        result: '210,000 /μL',
        reference: '150,000 – 400,000',
        flag: _FlagStatus.normal,
      ),
    ],
  ),
  _LabResult(
    id: 'lr-002',
    testGroupName: 'FBC + Typhoid Test',
    visitDate: 'Today',
    requestedBy: 'Dr. Kato',
    uploadedAt: '',
    status: _ResultStatus.pending,
    rows: [],
  ),
  _LabResult(
    id: 'lr-003',
    testGroupName: 'Urine Analysis',
    visitDate: '14 Jan 2025',
    requestedBy: 'Dr. Ssali',
    uploadedAt: '14 Jan 2025 · 11:20',
    status: _ResultStatus.ready,
    notes: 'Mild leukocyturia. No casts. Treated empirically for UTI.',
    rows: [
      _LabRow(
        test: 'Leukocytes',
        result: '2+',
        reference: 'Negative',
        flag: _FlagStatus.flagHigh,
      ),
      _LabRow(
        test: 'Nitrites',
        result: 'Negative',
        reference: 'Negative',
        flag: _FlagStatus.normal,
      ),
      _LabRow(
        test: 'Protein',
        result: 'Trace',
        reference: 'Negative',
        flag: _FlagStatus.flagHigh,
      ),
      _LabRow(
        test: 'Blood',
        result: 'Negative',
        reference: 'Negative',
        flag: _FlagStatus.normal,
      ),
    ],
  ),
];

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  // Tracks which result cards are expanded
  final Set<String> _expanded = {'lr-001'};

  void _toggleExpand(String id) {
    setState(() {
      if (_expanded.contains(id)) {
        _expanded.remove(id);
      } else {
        _expanded.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ready = _mockResults
        .where((r) => r.status == _ResultStatus.ready)
        .toList();
    final pending = _mockResults
        .where((r) => r.status == _ResultStatus.pending)
        .toList();

    return CustomScrollView(
      slivers: [
        // ── Summary strip ──────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                _SummaryChip(
                  label: 'Results Ready',
                  value: '${ready.length}',
                  color: AppColors.accent,
                ),
                const SizedBox(width: 10),
                _SummaryChip(
                  label: 'Awaiting',
                  value: '${pending.length}',
                  color: const Color(0xFFA05C00),
                ),
              ],
            ),
          ),
        ),

        // ── Pending ────────────────────────────────────────
        if (pending.isNotEmpty) ...[
          const _SliverSectionLabel(label: 'Awaiting Results'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PendingCard(result: pending[i]),
                ),
                childCount: pending.length,
              ),
            ),
          ),
        ],

        // ── Ready ──────────────────────────────────────────
        if (ready.isNotEmpty) ...[
          const _SliverSectionLabel(label: 'Results Ready'),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 30),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                final r = ready[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ResultCard(
                    result: r,
                    isExpanded: _expanded.contains(r.id),
                    onToggle: () => _toggleExpand(r.id),
                  ),
                );
              }, childCount: ready.length),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────

class _SliverSectionLabel extends StatelessWidget {
  final String label;
  const _SliverSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.ink2,
            letterSpacing: 0.07 * 11,
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.ink3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pending card ───────────────────────────────────────

class _PendingCard extends StatelessWidget {
  final _LabResult result;
  const _PendingCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: Color(0xFFF5C97A), width: 3.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flask icon
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7EA),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.science_outlined,
                size: 16,
                color: Color(0xFFA05C00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.testGroupName,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${result.visitDate} · ${result.requestedBy}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.ink3,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7EA),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: const Color(0xFFF5C97A)),
                    ),
                    child: const Text(
                      'Awaiting Results',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA05C00),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ready / expandable result card ────────────────────

class _ResultCard extends StatelessWidget {
  final _LabResult result;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ResultCard({
    required this.result,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Does this result have any flagged rows?
    final hasCritical = result.rows.any(
      (r) => r.flag == _FlagStatus.flagPositive,
    );
    final hasAbnormal = result.rows.any((r) => r.flag != _FlagStatus.normal);

    final borderColor = hasCritical
        ? const Color(0xFFF5AAAA)
        : hasAbnormal
        ? const Color(0xFFF5C97A)
        : AppColors.ink3;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: borderColor, width: 3.5)),
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
          // ── Header (always visible) ──────────────────
          InkWell(
            borderRadius: isExpanded
                ? const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  )
                : BorderRadius.circular(14),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.testGroupName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${result.visitDate} · ${result.requestedBy}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.ink3,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 6),
                        _ResultReadyChip(
                          hasCritical: hasCritical,
                          hasAbnormal: hasAbnormal,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.ink3,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded content ─────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Divider
                Container(height: 1, color: const Color(0xFFE0E4EB)),

                // Lab table header
                Container(
                  color: const Color(0xFFF8F9FB),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  child: Row(
                    children: const [
                      Expanded(flex: 4, child: _TableHeader('Test')),
                      Expanded(flex: 3, child: _TableHeader('Result')),
                      Expanded(flex: 3, child: _TableHeader('Ref. Range')),
                    ],
                  ),
                ),

                // Lab rows
                ...result.rows.asMap().entries.map((entry) {
                  final isLast = entry.key == result.rows.length - 1;
                  return _LabTableRow(row: entry.value, isLast: isLast);
                }),

                // Notes box
                if (result.notes != null) ...[
                  const Divider(height: 1, color: Color(0xFFE0E4EB)),
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4FB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA8D4ED)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "DOCTOR'S NOTES",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            letterSpacing: 0.07 * 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.notes!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.ink2,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Upload time footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    'Uploaded: ${result.uploadedAt}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.ink3,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultReadyChip extends StatelessWidget {
  final bool hasCritical;
  final bool hasAbnormal;
  const _ResultReadyChip({
    required this.hasCritical,
    required this.hasAbnormal,
  });

  @override
  Widget build(BuildContext context) {
    if (hasCritical) {
      return _chip(
        'Abnormal Result',
        const Color(0xFFB81C24),
        const Color(0xFFFFF2F2),
        const Color(0xFFF5AAAA),
      );
    } else if (hasAbnormal) {
      return _chip(
        'Out of Range',
        const Color(0xFFA05C00),
        const Color(0xFFFFF7EA),
        const Color(0xFFF5C97A),
      );
    } else {
      return _chip(
        'All Normal',
        const Color(0xFF16714A),
        const Color(0xFFEAFAF2),
        const Color(0xFF96DEBB),
      );
    }
  }

  Widget _chip(String label, Color fg, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        color: AppColors.ink3,
        letterSpacing: 0.07 * 9.5,
      ),
    );
  }
}

class _LabTableRow extends StatelessWidget {
  final _LabRow row;
  final bool isLast;
  const _LabTableRow({required this.row, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final resultStyle = _resultTextStyle(row.flag);

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFE0E4EB))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              row.test,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
          Expanded(flex: 3, child: Text(row.result, style: resultStyle)),
          Expanded(
            flex: 3,
            child: Text(
              row.reference,
              style: const TextStyle(fontSize: 11, color: AppColors.ink3),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _resultTextStyle(_FlagStatus flag) {
    switch (flag) {
      case _FlagStatus.flagPositive:
      case _FlagStatus.flagHigh:
        return const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFFB81C24),
          fontFamily: 'monospace',
        );
      case _FlagStatus.flagLow:
        return const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFFA05C00),
          fontFamily: 'monospace',
        );
      case _FlagStatus.flagNegative:
      case _FlagStatus.normal:
        return const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          fontFamily: 'monospace',
        );
    }
  }
}
