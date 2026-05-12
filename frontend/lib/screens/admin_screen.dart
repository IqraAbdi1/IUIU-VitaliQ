import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';
import '../services/api_service.dart';

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
                _SubTab(label: 'Queue Overview', isActive: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
                const SizedBox(width: 7),
                _SubTab(label: 'Analytics',      isActive: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
                const SizedBox(width: 7),
                _SubTab(label: 'Pharmacy',       isActive: _tabIndex == 2, onTap: () => setState(() => _tabIndex = 2)),
              ],
            ),
          ),
        ),
        Expanded(
          child: switch (_tabIndex) {
            1 => const _AnalyticsTab(),
            2 => const _PharmacyTab(),
            _ => const _QueueOverviewTab(),
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// QUEUE OVERVIEW TAB
// ─────────────────────────────────────────────
class _QueueOverviewTab extends StatefulWidget {
  const _QueueOverviewTab();

  @override
  State<_QueueOverviewTab> createState() => _QueueOverviewTabState();
}

class _QueueOverviewTabState extends State<_QueueOverviewTab> {
  bool _isLoading = true;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService().getAdminDashboard();
      if (!mounted) return;
      setState(() { _data = data; _isLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final dailyVisits = (_data['daily_visits'] as List? ?? []);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      children: [
        // ── Stats strip ──
        const AppSectionHeader(title: 'Clinic Overview · Today'),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: AppStatCard(label: 'Visits Today',  value: '${_data['total_visits_today'] ?? 0}', valueColor: AppColors.accent)),
              const SizedBox(width: 10),
              Expanded(child: AppStatCard(label: 'This Week',     value: '${_data['total_visits_week']  ?? 0}', valueColor: AppColors.ok)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: AppStatCard(label: 'Staff On Shift', value: '${_data['staff_on_shift'] ?? 0}')),
              const SizedBox(width: 10),
              Expanded(child: AppStatCard(label: 'Low Stock Alerts', value: '${_data['low_stock_items'] ?? 0}', valueColor: AppColors.warn)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Daily visits this week ──
        const AppSectionHeader(title: 'Daily Visits · This Week'),
        const SizedBox(height: 10),
        if (dailyVisits.isEmpty)
          const _EmptyCard(icon: Icons.bar_chart_rounded, title: 'No visit data', subtitle: 'No visits recorded this week')
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Column(
              children: dailyVisits.map<Widget>((d) {
                final count   = d['count'] as int? ?? 0;
                final maxCount = dailyVisits.map((x) => x['count'] as int? ?? 0).reduce((a, b) => a > b ? a : b);
                final ratio   = maxCount > 0 ? count / maxCount : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(width: 80, child: Text(d['date'] ?? '', style: const TextStyle(fontSize: 10, color: AppColors.ink3, fontFamily: 'DMMono'))),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio.toDouble(),
                            minHeight: 14,
                            backgroundColor: AppColors.surface2,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink, fontFamily: 'DMMono')),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

        // ── ML Alerts ──
        const SizedBox(height: 16),
        const AppSectionHeader(title: 'ML Alerts'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: (_data['ml_alerts'] ?? 0) > 0 ? AppColors.warn : AppColors.ok, width: 3.5)),
          ),
          child: Row(
            children: [
              Icon((_data['ml_alerts'] ?? 0) > 0 ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                color: (_data['ml_alerts'] ?? 0) > 0 ? AppColors.warn : AppColors.ok, size: 20),
              const SizedBox(width: 10),
              Text(
                (_data['ml_alerts'] ?? 0) > 0
                  ? '${_data['ml_alerts']} medicine(s) below reorder threshold'
                  : 'All stock levels healthy',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// ─────────────────────────────────────────────
// ANALYTICS TAB
// ─────────────────────────────────────────────
class _AnalyticsTab extends StatefulWidget {
  const _AnalyticsTab();

  @override
  State<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<_AnalyticsTab> {
  bool _isLoading = true;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService().getAdminDashboard();
      if (!mounted) return;
      setState(() { _data = data; _isLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final topDiagnoses = (_data['top_diagnoses'] as List? ?? [])
        .where((d) => d['diagnosis'] != 'PENDING LAB RESULTS')
        .toList();
    final topMedicines = _data['top_medicines'] as List? ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      children: [
        // ── Top Diagnoses ──
        const AppSectionHeader(title: 'Top Diagnoses · This Week'),
        const SizedBox(height: 10),
        if (topDiagnoses.isEmpty)
          const _EmptyCard(icon: Icons.pie_chart_outline_rounded, title: 'No diagnosis data', subtitle: 'Diagnoses will appear after consultations')
        else
          Container(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Column(
              children: topDiagnoses.asMap().entries.map<Widget>((entry) {
                final i    = entry.key;
                final d    = entry.value;
                final isLast = i == topDiagnoses.length - 1;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(6)),
                        child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accent))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(d['diagnosis'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink))),
                      Text('${d['count']} cases', style: const TextStyle(fontSize: 11, color: AppColors.ink3, fontFamily: 'DMMono')),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 16),

        // ── Top Medicines ──
        const AppSectionHeader(title: 'Top Medicines Prescribed · This Week'),
        const SizedBox(height: 10),
        if (topMedicines.isEmpty)
          const _EmptyCard(icon: Icons.medication_rounded, title: 'No prescription data', subtitle: 'Prescriptions will appear here')
        else
          Container(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Column(
              children: topMedicines.asMap().entries.map<Widget>((entry) {
                final i    = entry.key;
                final m    = entry.value;
                final isLast = i == topMedicines.length - 1;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(color: AppColors.okBg, borderRadius: BorderRadius.circular(6)),
                        child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ok))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(m['medicine_name'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink))),
                      Text('${m['count']} rx', style: const TextStyle(fontSize: 11, color: AppColors.ink3, fontFamily: 'DMMono')),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PHARMACY TAB — real API
// ─────────────────────────────────────────────
class _PharmacyTab extends StatefulWidget {
  const _PharmacyTab();

  @override
  State<_PharmacyTab> createState() => _PharmacyTabState();
}

class _PharmacyTabState extends State<_PharmacyTab> {
  int _subIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                _SubTab(label: 'Inventory',        isActive: _subIndex == 0, onTap: () => setState(() => _subIndex = 0)),
                const SizedBox(width: 7),
                _SubTab(label: 'AI Restock',       isActive: _subIndex == 1, onTap: () => setState(() => _subIndex = 1)),
                const SizedBox(width: 7),
                _SubTab(label: 'Disease Forecast', isActive: _subIndex == 2, onTap: () => setState(() => _subIndex = 2)),
              ],
            ),
          ),
        ),
        Expanded(
          child: switch (_subIndex) {
            1 => const _AIRestockTab(),
            2 => const _DiseaseForecastTab(),
            _ => const _InventoryTab(),
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// INVENTORY TAB
// GET /api/pharmacy/stock/
// ─────────────────────────────────────────────
class _InventoryTab extends StatefulWidget {
  const _InventoryTab();

  @override
  State<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<_InventoryTab> {
  bool _isLoading = true;
  List<dynamic> _stock = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService().getStockList();
      if (!mounted) return;
      setState(() { _stock = data; _isLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_stock.isEmpty) return const _EmptyCard(icon: Icons.inventory_2_rounded, title: 'No stock data', subtitle: 'Add medicines in admin panel');

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      itemCount: _stock.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final m = _stock[i];
        final isLow = m['is_low_stock'] as bool? ?? false;
        final isOut = m['is_out_of_stock'] as bool? ?? false;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(
              color: isOut ? AppColors.err : isLow ? AppColors.warn : AppColors.ok,
              width: 3.5,
            )),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m['medicine_name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    const SizedBox(height: 2),
                    Text(m['medical_condition'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.ink3)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${m['quantity']} ${m['unit']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  AppStatusChip(
                    label: isOut ? 'Out of Stock' : isLow ? 'Low Stock' : 'In Stock',
                    status: isOut ? AppStatus.err : isLow ? AppStatus.warn : AppStatus.ok,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// AI RESTOCK TAB
// GET /api/pharmacy/recommendations/
// ─────────────────────────────────────────────
class _AIRestockTab extends StatefulWidget {
  const _AIRestockTab();

  @override
  State<_AIRestockTab> createState() => _AIRestockTabState();
}

class _AIRestockTabState extends State<_AIRestockTab> {
  bool _isLoading = true;
  List<dynamic> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService().getRestockRecommendations();
      if (!mounted) return;
      setState(() {
        _recommendations = data['recommendations'] ?? [];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Color _urgencyColor(String urgency) => switch (urgency) {
    'CRITICAL' => AppColors.err,
    'HIGH'     => AppColors.warn,
    'MEDIUM'   => AppColors.accent,
    _          => AppColors.ok,
  };

  AppStatus _urgencyStatus(String urgency) => switch (urgency) {
    'CRITICAL' => AppStatus.err,
    'HIGH'     => AppStatus.warn,
    'MEDIUM'   => AppStatus.neutral,
    _          => AppStatus.ok,
  };

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_recommendations.isEmpty) return const _EmptyCard(icon: Icons.psychology_rounded, title: 'No recommendations', subtitle: 'All stock levels are healthy');

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      children: [
        AppInfoBox(
          label: 'AI Restock Recommendations',
          body: 'Powered by Random Forest + Disease Trend model. Updated in real time.',
          variant: AppInfoVariant.accent,
        ),
        const SizedBox(height: 12),
        ..._recommendations.map((r) {
          final urgency = r['urgency'] as String? ?? 'OK';
          final days    = r['days_to_stockout'] as num? ?? 999;
          final pressure = r['demand_pressure'] as num? ?? 1.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: _urgencyColor(urgency), width: 3.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(r['medicine_name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink))),
                    AppStatusChip(label: urgency, status: _urgencyStatus(urgency)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${r['current_stock']} ${r['unit']} remaining · ${days.toStringAsFixed(1)} days to stockout',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.ink2)),
                const SizedBox(height: 4),
                Text('Daily use: ${(r['daily_consumption'] as num).toStringAsFixed(1)} units · Demand pressure: ${pressure.toStringAsFixed(2)}x',
                  style: const TextStyle(fontSize: 11, color: AppColors.ink3, fontFamily: 'DMMono')),
                if ((r['reorder_flag'] as bool? ?? false)) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, size: 13, color: AppColors.warn),
                      SizedBox(width: 4),
                      Text('Reorder recommended', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warn)),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// DISEASE FORECAST TAB
// GET /api/pharmacy/recommendations/ (disease_forecasts field)
// ─────────────────────────────────────────────
class _DiseaseForecastTab extends StatefulWidget {
  const _DiseaseForecastTab();

  @override
  State<_DiseaseForecastTab> createState() => _DiseaseForecastTabState();
}

class _DiseaseForecastTabState extends State<_DiseaseForecastTab> {
  bool _isLoading = true;
  Map<String, dynamic> _forecasts = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService().getRestockRecommendations();
      if (!mounted) return;
      setState(() {
        _forecasts  = Map<String, dynamic>.from(data['disease_forecasts'] ?? {});
        _isLoading  = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_forecasts.isEmpty) return const _EmptyCard(icon: Icons.show_chart_rounded, title: 'No forecast data', subtitle: 'Trend model returned no results');

    final months = ['Month 1', 'Month 2', 'Month 3'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      children: [
        AppInfoBox(
          label: 'Disease Spike Forecast',
          body: 'Exponential Smoothing model predicting case counts for next 3 months.',
          variant: AppInfoVariant.accent,
        ),
        const SizedBox(height: 12),
        ..._forecasts.entries.map((entry) {
          final disease  = entry.key;
          final forecast = entry.value as Map<String, dynamic>;
          final values   = (forecast['values'] as List?)?.map((v) => (v as num).toDouble()).toList() ?? [];
          final trend    = forecast['trend'] as String? ?? 'stable';
          final isUp     = trend == 'up';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(disease, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink))),
                    Row(
                      children: [
                        Icon(isUp ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
                          size: 16, color: isUp ? AppColors.err : AppColors.ok),
                        const SizedBox(width: 4),
                        Text(isUp ? 'Spike expected' : 'Stable',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: isUp ? AppColors.err : AppColors.ok)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(values.length, (i) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < values.length - 1 ? 6 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(months[i], style: const TextStyle(fontSize: 9.5, color: AppColors.ink3, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(values[i].toStringAsFixed(0),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink, fontFamily: 'DMMono')),
                          const Text('cases', style: TextStyle(fontSize: 9, color: AppColors.ink3)),
                        ],
                      ),
                    ),
                  )),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────

class _SubTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SubTab({required this.label, required this.isActive, required this.onTap});

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
          border: Border.all(color: isActive ? AppColors.accent : AppColors.border, width: 1.5),
        ),
        child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700,
          color: isActive ? AppColors.accent : AppColors.ink2)),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: AppColors.ink3),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink2)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.ink3, fontFamily: 'DMMono')),
        ],
      ),
    );
  }
}
