import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MOCK DATA — replace with API calls when backend is ready
// Backend: GET /api/v1/medicines          (inventory tab)
//          GET /api/v1/analytics/summary  (analytics tab)
// ─────────────────────────────────────────────────────────────────────────────

enum _StockStatus { ok, low, out }

class _Medicine {
  final String id; // Backend: medicine.id
  final String name; // Backend: medicine.name
  final int stockQuantity; // Backend: medicine.stock_quantity
  final int reorderLevel; // Backend: medicine.reorder_level
  final int
  maxQuantity; // Backend: used for progress bar scaling (set to initial/max stock)
  final _StockStatus
  status; // Backend: derived from stock_quantity vs reorder_level

  const _Medicine({
    required this.id,
    required this.name,
    required this.stockQuantity,
    required this.reorderLevel,
    required this.maxQuantity,
    required this.status,
  });
}

class _DiseaseBreakdown {
  final String name; // Backend: analytics.disease_name
  final int count; // Backend: analytics.visit_count
  final double percentage; // Backend: analytics.percentage
  final Color barColor; // Derived from disease type

  const _DiseaseBreakdown({
    required this.name,
    required this.count,
    required this.percentage,
    required this.barColor,
  });
}

class _MedicineUsage {
  final String name; // Backend: analytics.medicine_name
  final int dispensed; // Backend: analytics.dispensed_count
  final int maxDispensed; // Backend: used for bar scaling (max in list)

  const _MedicineUsage({
    required this.name,
    required this.dispensed,
    required this.maxDispensed,
  });
}

class _InventoryStats {
  final int totalItems; // Backend: analytics.total_medicines
  final int lowStock; // Backend: analytics.low_stock_count
  final int outOfStock; // Backend: analytics.out_of_stock_count
  final int dispensedToday; // Backend: analytics.dispensed_today

  const _InventoryStats({
    required this.totalItems,
    required this.lowStock,
    required this.outOfStock,
    required this.dispensedToday,
  });
}

class _AnalyticsSummary {
  final int totalVisits; // Backend: analytics.total_visits
  final int malariaCount; // Backend: analytics.malaria_count
  final double
  malariaDelta; // Backend: analytics.malaria_delta_percent (positive = up)
  final int typhoidCount; // Backend: analytics.typhoid_count
  final double typhoidDelta;
  final int uriCount; // Backend: analytics.uri_count
  final double uriDelta;
  final String period; // Backend: analytics.period label e.g. "March"

  const _AnalyticsSummary({
    required this.totalVisits,
    required this.malariaCount,
    required this.malariaDelta,
    required this.typhoidCount,
    required this.typhoidDelta,
    required this.uriCount,
    required this.uriDelta,
    required this.period,
  });
}

// ── Mock inventory ─────────────────────────────────────────────────────────
final _mockInventoryStats = const _InventoryStats(
  totalItems: 42,
  lowStock: 7,
  outOfStock: 2,
  dispensedToday: 38,
);

final List<_Medicine> _mockMedicines = [
  const _Medicine(
    id: 'MED-001',
    name: 'Paracetamol 500mg',
    stockQuantity: 340,
    reorderLevel: 50,
    maxQuantity: 400,
    status: _StockStatus.ok,
  ),
  const _Medicine(
    id: 'MED-002',
    name: 'Amoxicillin 500mg',
    stockQuantity: 28,
    reorderLevel: 60,
    maxQuantity: 200,
    status: _StockStatus.low,
  ),
  const _Medicine(
    id: 'MED-003',
    name: 'Ibuprofen 400mg',
    stockQuantity: 0,
    reorderLevel: 40,
    maxQuantity: 150,
    status: _StockStatus.out,
  ),
  const _Medicine(
    id: 'MED-004',
    name: 'Artemether-Lumefantrine',
    stockQuantity: 112,
    reorderLevel: 60,
    maxQuantity: 200,
    status: _StockStatus.ok,
  ),
  const _Medicine(
    id: 'MED-005',
    name: 'ORS Sachets',
    stockQuantity: 15,
    reorderLevel: 40,
    maxQuantity: 200,
    status: _StockStatus.low,
  ),
  const _Medicine(
    id: 'MED-006',
    name: 'Cetirizine 10mg',
    stockQuantity: 204,
    reorderLevel: 40,
    maxQuantity: 300,
    status: _StockStatus.ok,
  ),
  const _Medicine(
    id: 'MED-007',
    name: 'Metronidazole 400mg',
    stockQuantity: 88,
    reorderLevel: 40,
    maxQuantity: 200,
    status: _StockStatus.ok,
  ),
  const _Medicine(
    id: 'MED-008',
    name: 'Ciprofloxacin 500mg',
    stockQuantity: 22,
    reorderLevel: 40,
    maxQuantity: 150,
    status: _StockStatus.low,
  ),
];

// ── Mock analytics ─────────────────────────────────────────────────────────
final _mockAnalyticsSummary = const _AnalyticsSummary(
  totalVisits: 247,
  malariaCount: 94,
  malariaDelta: 18.0,
  typhoidCount: 31,
  typhoidDelta: 6.0,
  uriCount: 58,
  uriDelta: -4.0,
  period: 'March',
);

final List<_DiseaseBreakdown> _mockDiseaseBreakdown = const [
  _DiseaseBreakdown(
    name: 'Malaria',
    count: 94,
    percentage: 38.0,
    barColor: AppColors.warn,
  ),
  _DiseaseBreakdown(
    name: 'URI',
    count: 58,
    percentage: 23.0,
    barColor: AppColors.accent,
  ),
  _DiseaseBreakdown(
    name: 'Typhoid',
    count: 31,
    percentage: 13.0,
    barColor: AppColors.err,
  ),
  _DiseaseBreakdown(
    name: 'GI / Other',
    count: 64,
    percentage: 26.0,
    barColor: AppColors.ink3,
  ),
];

final List<_MedicineUsage> _mockMedicineUsage = const [
  _MedicineUsage(name: 'Paracetamol', dispensed: 248, maxDispensed: 248),
  _MedicineUsage(name: 'Artemether', dispensed: 190, maxDispensed: 248),
  _MedicineUsage(name: 'Amoxicillin', dispensed: 141, maxDispensed: 248),
  _MedicineUsage(name: 'ORS Sachets', dispensed: 98, maxDispensed: 248),
  _MedicineUsage(name: 'Metronidazole', dispensed: 76, maxDispensed: 248),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  int _tabIndex = 0; // 0 = Inventory, 1 = Analytics

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SubTabBar(
          tabIndex: _tabIndex,
          onTabChanged: (i) => setState(() => _tabIndex = i),
        ),
        Expanded(
          child: IndexedStack(
            index: _tabIndex,
            children: const [_InventoryTab(), _AnalyticsTab()],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-TAB BAR
// ─────────────────────────────────────────────────────────────────────────────

class _SubTabBar extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  const _SubTabBar({required this.tabIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          _TabPill(
            label: 'Inventory',
            active: tabIndex == 0,
            onTap: () => onTabChanged(0),
          ),
          _TabPill(
            label: 'Analytics',
            active: tabIndex == 1,
            onTap: () => onTabChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.accent : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.accent : AppColors.ink3,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INVENTORY TAB
// ─────────────────────────────────────────────────────────────────────────────

class _InventoryTab extends StatefulWidget {
  const _InventoryTab();

  @override
  State<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<_InventoryTab> {
  // Local list so Add/Edit actions can update UI
  // Backend: replace with real API state
  late List<_Medicine> _medicines;

  @override
  void initState() {
    super.initState();
    _medicines = List.from(_mockMedicines);
  }

  @override
  Widget build(BuildContext context) {
    // Stats — Backend: GET /api/v1/medicines (derive counts from list)
    final stats = _mockInventoryStats;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      children: [
        // Stats strip
        _StatsStrip(stats: stats),
        const SizedBox(height: 14),

        // Section header with Add button
        AppSectionHeader(
          title: 'Inventory',
          actionLabel: '+ Add',
          onAction: () => _showAddSheet(context),
        ),
        const SizedBox(height: 10),

        // Medicine list
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Medicine',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink3,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        'Units',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink3,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 64,
                      child: Text(
                        'Status',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink3,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Rows
              ..._medicines.asMap().entries.map((entry) {
                final i = entry.key;
                final med = entry.value;
                final isLast = i == _medicines.length - 1;
                return _MedicineRow(medicine: med, isLast: isLast);
              }),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ML restock recommendation
        const AppInfoBox(
          label: 'ML Restock Recommendation',
          body:
              'Malaria season approaching. Data predicts 40% case increase in April. Prioritise Artemether-Lumefantrine, RDT kits, and ORS before March 25.',
          variant: AppInfoVariant.accent,
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMedicineSheet(
        onAdded: (medicine) {
          setState(() => _medicines.insert(0, medicine));
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    // Backend: GET /api/v1/analytics/summary
    final summary = _mockAnalyticsSummary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      children: [
        // Visit summary stats
        _AnalyticsStatsStrip(summary: summary),
        const SizedBox(height: 14),

        // Disease distribution
        const AppSectionHeader(title: 'Disease Distribution'),
        const SizedBox(height: 10),
        _BarChartCard(
          items: _mockDiseaseBreakdown
              .map(
                (d) => _BarItem(
                  label: d.name,
                  value: '${d.percentage.toStringAsFixed(0)}%',
                  fraction: d.percentage / 100,
                  color: d.barColor,
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 14),

        // Top medicine usage
        const AppSectionHeader(title: 'Top Medicine Usage'),
        const SizedBox(height: 10),
        _BarChartCard(
          items: _mockMedicineUsage
              .map(
                (m) => _BarItem(
                  label: m.name,
                  value: m.dispensed.toString(),
                  fraction: m.dispensed / m.maxDispensed,
                  color: AppColors.accent,
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 14),

        // ML spike alert
        AppInfoBox(
          variant: AppInfoVariant.err,
          label: 'ML Spike Alert',
          body:
              'Malaria cases up ${summary.malariaDelta.toStringAsFixed(0)}% this week. Model predicts continued rise through April. Recommend restocking Artemether and alerting campus health officer immediately.',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATS STRIPS
// ─────────────────────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final _InventoryStats stats;

  const _StatsStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: AppStatCard(
                  label: 'Total Items',
                  value: stats.totalItems.toString(),
                  valueColor: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppStatCard(
                  label: 'Low Stock',
                  value: stats.lowStock.toString(),
                  valueColor: AppColors.warn,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: AppStatCard(
                  label: 'Out of Stock',
                  value: stats.outOfStock.toString(),
                  valueColor: AppColors.err,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppStatCard(
                  label: 'Dispensed Today',
                  value: stats.dispensedToday.toString(),
                  valueColor: AppColors.ok,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsStatsStrip extends StatelessWidget {
  final _AnalyticsSummary summary;

  const _AnalyticsStatsStrip({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: AppStatCard(
                  label: 'Total Visits',
                  value: summary.totalVisits.toString(),
                  sub: summary.period,
                  valueColor: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppStatCard(
                  label: 'Malaria',
                  value: summary.malariaCount.toString(),
                  sub: '↑${summary.malariaDelta.toStringAsFixed(0)}%',
                  valueColor: AppColors.warn,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: AppStatCard(
                  label: 'Typhoid',
                  value: summary.typhoidCount.toString(),
                  sub: '↑${summary.typhoidDelta.toStringAsFixed(0)}%',
                  valueColor: AppColors.err,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppStatCard(
                  label: 'URI',
                  value: summary.uriCount.toString(),
                  sub: '↓${summary.uriDelta.abs().toStringAsFixed(0)}%',
                  valueColor: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEDICINE ROW
// ─────────────────────────────────────────────────────────────────────────────

class _MedicineRow extends StatelessWidget {
  final _Medicine medicine;
  final bool isLast;

  const _MedicineRow({required this.medicine, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final (barColor, qtyColor) = switch (medicine.status) {
      _StockStatus.ok => (AppColors.ok, AppColors.ink),
      _StockStatus.low => (AppColors.warn, AppColors.warn),
      _StockStatus.out => (AppColors.err, AppColors.err),
    };

    final fillFraction = medicine.maxQuantity > 0
        ? (medicine.stockQuantity / medicine.maxQuantity).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
      child: Row(
        children: [
          // Name + progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 5),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: 5,
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: fillFraction,
                        child: Container(
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Quantity
          SizedBox(
            width: 44,
            child: Text(
              medicine.stockQuantity.toString(),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: qtyColor,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Status chip
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerRight,
              child: _StockChip(status: medicine.status),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD MEDICINE SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _AddMedicineSheet extends StatefulWidget {
  final ValueChanged<_Medicine> onAdded;

  const _AddMedicineSheet({required this.onAdded});

  @override
  State<_AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends State<_AddMedicineSheet> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _reorderController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _reorderController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _qtyController.text.trim().isNotEmpty &&
      _reorderController.text.trim().isNotEmpty;

  _StockStatus _deriveStatus(int qty, int reorder) {
    if (qty == 0) return _StockStatus.out;
    if (qty <= reorder) return _StockStatus.low;
    return _StockStatus.ok;
  }

  Future<void> _submit() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields.'),
          backgroundColor: AppColors.ink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    final reorder = int.tryParse(_reorderController.text.trim()) ?? 0;

    // Backend: POST /api/v1/medicines
    // Payload: { name, stock_quantity, reorder_level }
    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      final newMed = _Medicine(
        id: 'MED-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        stockQuantity: qty,
        reorderLevel: reorder,
        maxQuantity: qty,
        status: _deriveStatus(qty, reorder),
      );
      Navigator.pop(context);
      widget.onAdded(newMed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 18),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              'Add Medicine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'New item will be added to the clinic inventory.',
              style: TextStyle(fontSize: 12, color: AppColors.ink3),
            ),

            const SizedBox(height: 20),

            _SheetField(
              label: 'Medicine Name',
              controller: _nameController,
              placeholder: 'e.g. Amoxicillin 500mg',
              keyboardType: TextInputType.text,
            ),
            _SheetField(
              label: 'Current Stock (units)',
              controller: _qtyController,
              placeholder: 'e.g. 200',
              keyboardType: TextInputType.number,
            ),
            _SheetField(
              label: 'Reorder Level (units)',
              controller: _reorderController,
              placeholder: 'e.g. 40',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_rounded, size: 19),
                label: Text(_isSubmitting ? 'Adding…' : 'Add to Inventory'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  disabledBackgroundColor: AppColors.accent.withValues(
                    alpha: 0.6,
                  ),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.ink3,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                    side: BorderSide(color: AppColors.border),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PHARMACY-SPECIFIC WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _StockChip extends StatelessWidget {
  final _StockStatus status;

  const _StockChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, chipStatus) = switch (status) {
      _StockStatus.ok => ('OK', AppStatus.ok),
      _StockStatus.low => ('Low', AppStatus.warn),
      _StockStatus.out => ('Out', AppStatus.err),
    };

    return AppStatusChip(label: label, status: chipStatus);
  }
}

class _BarItem {
  final String label;
  final String value;
  final double fraction; // 0.0 – 1.0
  final Color color;

  const _BarItem({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });
}

class _BarChartCard extends StatelessWidget {
  final List<_BarItem> items;

  const _BarChartCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: item.fraction.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 34,
                      child: Text(
                        item.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink3,
                          fontFamily: 'monospace',
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

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType keyboardType;

  const _SheetField({
    required this.label,
    required this.controller,
    required this.placeholder,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: AppColors.ink3, fontSize: 12.5),
              filled: true,
              fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
