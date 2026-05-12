import 'package:flutter/material.dart';
import '../theme.dart';
import '../shared/widgets.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

enum _LabRequestStatus { urgent, pending, completed }

class _LabTest {
  final String name;
  final String? unit;
  final String? referenceRange;
  final String inputType; // BOOLEAN, NUMBER, TEXT

  const _LabTest({
    required this.name,
    this.unit,
    this.referenceRange,
    this.inputType = 'TEXT',
  });
}

class _LabRequest {
  final int visitId;
  final String requestId;
  final String patientName;
  final String patientId;
  final String doctorName;
  final String requestedAt;
  final _LabRequestStatus status;
  final List<_LabTest> tests;

  const _LabRequest({
    required this.visitId,
    required this.requestId,
    required this.patientName,
    required this.patientId,
    required this.doctorName,
    required this.requestedAt,
    required this.status,
    required this.tests,
  });
}

class _LabResult {
  final String testName;
  final String value;
  final String? unit;
  final String? referenceRange;
  final String? flag;

  const _LabResult({
    required this.testName,
    required this.value,
    this.unit,
    this.referenceRange,
    this.flag,
  });
}

class _CompletedRequest {
  final String requestId;
  final String patientName;
  final String patientId;
  final String techName;
  final String completedAt;
  final List<_LabResult> results;
  final bool notified;

  const _CompletedRequest({
    required this.requestId,
    required this.patientName,
    required this.patientId,
    required this.techName,
    required this.completedAt,
    required this.results,
    required this.notified,
  });
}

// ─────────────────────────────────────────────
// ONE MOCK — fallback only if API completely fails
// ─────────────────────────────────────────────
const _mockFallbackRequest = _LabRequest(
  visitId:     0,
  requestId:   'LR-000',
  patientName: 'No connection',
  patientId:   '—',
  doctorName:  '—',
  requestedAt: '—',
  status:      _LabRequestStatus.pending,
  tests:       [_LabTest(name: 'Check connection', inputType: 'TEXT')],
);

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class LabTechScreen extends StatefulWidget {
  const LabTechScreen({super.key});

  @override
  State<LabTechScreen> createState() => _LabTechScreenState();
}

class _LabTechScreenState extends State<LabTechScreen> {
  int  _tabIndex  = 0;
  bool _isLoading = true;

  List<_LabRequest>       _pendingRequests   = [];
  List<_CompletedRequest> _completedRequests = [];

  // lookup map built from GET /api/consultation/lab-tests/
  Map<String, _LabTest> _testMeta = {};

  @override
  void initState() {
    super.initState();
    _loadLabData();
  }

  // ── fetch lab dashboard + lab test metadata in parallel ──
  // GET /api/lab/dashboard/         → pending requests
  // GET /api/consultation/lab-tests/ → test metadata (unit, reference, inputType)
  Future<void> _loadLabData() async {
  // ── PART 1: pending requests + test metadata ──
  try {
    final results = await Future.wait([
      ApiService().getLabDashboard(),
      ApiService().getLabTests(),
      ApiService().getNotifications(),
      

    ]);

    final data     = results[0] as Map<String, dynamic>;
    final labTests = results[1] as List<dynamic>;

    _testMeta = {
      for (final t in labTests)
        (t['name'] as String): _LabTest(
          name:           t['name'],
          unit:           t['unit'],
          referenceRange: t['reference_range'],
          inputType:      t['input_type'] ?? 'TEXT',
        )
    };

    final List rawPending = data['pending_requests'] ?? [];
    final pending = rawPending.map<_LabRequest>((item) {
      final testsStr = item['tests_requested'] ?? '';
      final tests    = testsStr
          .toString()
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .map((name) => _testMeta[name] ?? _LabTest(name: name, inputType: 'TEXT'))
          .toList();

      final requestedAt = item['requested_at'] ?? '';
      String timeStr = '';
      if (requestedAt.isNotEmpty) {
        try {
          final dt     = DateTime.parse(requestedAt).toLocal();
          final h      = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
          final m      = dt.minute.toString().padLeft(2, '0');
          final period = dt.hour >= 12 ? 'PM' : 'AM';
          timeStr = '$h:$m $period';
        } catch (_) { timeStr = requestedAt; }
      }

      return _LabRequest(
        visitId:     item['visit_id']       ?? 0,
        requestId:   'LR-${item['lab_request_id'] ?? '?'}',
        patientName: item['patient_name']   ?? 'Unknown',
        patientId:   item['reg_no']         ?? '',
        doctorName:  'Doctor',
        requestedAt: timeStr,
        status:      _LabRequestStatus.pending,
        tests:       tests,
      );
    }).toList();

    if (!mounted) return;
    setState(() {
      _pendingRequests = pending;
      _isLoading       = false;
    });
  } catch (e) {
    print('PENDING ERROR: $e');
    if (!mounted) return;
    setState(() {
      _pendingRequests = [_mockFallbackRequest];
      _isLoading       = false;
    });
  }

  // ── PART 2: completed results — separate so failure doesn't affect pending ──
  try {
    final completed = await ApiService().getCompletedLabResults();
    print('COMPLETED COUNT: ${completed.length}');

    final completedList = completed.map<_CompletedRequest>((item) {
      final resultText = item['result'] as String? ?? '';
      final resultRows = resultText
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .map((line) {
            final parts    = line.split(':');
            final testName = parts.first.trim();
            final value    = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
            return _LabResult(
              testName: testName,
              value:    value,
              flag:     value.toLowerCase().contains('positive') ? 'H' : null,
            );
          })
          .toList();

      final uploadedAt = item['uploaded_at'] ?? '';
      String timeStr = '';
      if (uploadedAt.isNotEmpty) {
        try {
          final dt     = DateTime.parse(uploadedAt).toLocal();
          final h      = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
          final m      = dt.minute.toString().padLeft(2, '0');
          final period = dt.hour >= 12 ? 'PM' : 'AM';
          timeStr      = '$h:$m $period';
        } catch (_) { timeStr = uploadedAt; }
      }

      return _CompletedRequest(
        requestId:   'LR-${item['lab_request_id'] ?? '?'}',
        patientName: item['patient_name'] ?? 'Unknown',
        patientId:   item['reg_no']       ?? '',
        techName:    item['tech_name']    ?? 'Lab Tech',
        completedAt: timeStr,
        results:     resultRows,
        notified:    true,
      );
    }).toList();

    if (!mounted) return;
    setState(() => _completedRequests = completedList);
  } catch (e) {
    print('COMPLETED ERROR: $e');
  }
}

  void _onUploaded(int visitId) {
  // find the request before removing
  final uploaded = _pendingRequests.firstWhere((r) => r.visitId == visitId);
  setState(() {
    _pendingRequests.removeWhere((r) => r.visitId == visitId);
    // add to completed locally
    _completedRequests.insert(0, _CompletedRequest(
      requestId:   uploaded.requestId,
      patientName: uploaded.patientName,
      patientId:   uploaded.patientId,
      techName:    ApiService.currentUsername ?? 'Lab Tech',
      completedAt: _formatTime(DateTime.now()),
      results:     [], // results text was sent to backend, not stored locally
      notified:    true,
    ));
  });
}

String _formatTime(DateTime dt) {
  final h      = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
  final m      = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $period';
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        _SubTabBar(
          tabIndex:       _tabIndex,
          pendingCount:   _pendingRequests.length,
          completedCount: _completedRequests.length,
          onTabChanged:   (i) => setState(() => _tabIndex = i),
        ),
        Expanded(
          child: IndexedStack(
            index: _tabIndex,
            children: [
              _PendingTab(requests: _pendingRequests, onUploaded: _onUploaded),
              _CompletedTab(requests: _completedRequests),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SUB-TAB BAR
// ─────────────────────────────────────────────

class _SubTabBar extends StatelessWidget {
  final int tabIndex;
  final int pendingCount;
  final int completedCount;
  final ValueChanged<int> onTabChanged;

  const _SubTabBar({
    required this.tabIndex,
    required this.pendingCount,
    required this.completedCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top:    BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          _TabPill(label: 'Pending ($pendingCount)',   active: tabIndex == 0, onTap: () => onTabChanged(0)),
          _TabPill(label: 'Completed ($completedCount)', active: tabIndex == 1, onTap: () => onTabChanged(1)),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabPill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: active ? AppColors.accent : Colors.transparent, width: 2.5)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? AppColors.accent : AppColors.ink3)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PENDING TAB
// ─────────────────────────────────────────────

class _PendingTab extends StatelessWidget {
  final List<_LabRequest> requests;
  final ValueChanged<int> onUploaded;

  const _PendingTab({required this.requests, required this.onUploaded});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.ink3),
            const SizedBox(height: 12),
            const Text('All caught up!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
            const SizedBox(height: 4),
            const Text('No pending lab requests.', style: TextStyle(fontSize: 13, color: AppColors.ink3)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final req = requests[index];
        return _PendingCard(
          request:  req,
          onUpload: () => _showUploadSheet(context, req),
        );
      },
    );
  }

  void _showUploadSheet(BuildContext context, _LabRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadSheet(
        request:     request,
        onSubmitted: () => onUploaded(request.visitId),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final _LabRequest request;
  final VoidCallback onUpload;

  const _PendingCard({required this.request, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final isUrgent    = request.status == _LabRequestStatus.urgent;
    final accentColor = isUrgent ? AppColors.err : AppColors.warn;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: accentColor, width: 3.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.tests.map((t) => t.name).join(' + '),
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                      const SizedBox(height: 3),
                      Text('${request.patientName} · ${request.requestedAt}',
                        style: const TextStyle(fontSize: 11, color: AppColors.ink3, fontFamily: 'DMMono')),
                      const SizedBox(height: 3),
                      Text(request.patientId,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.ink3, fontFamily: 'DMMono')),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AppStatusChip(label: isUrgent ? 'Urgent' : 'Pending', status: isUrgent ? AppStatus.err : AppStatus.warn),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Wrap(
              spacing: 7, runSpacing: 7,
              children: request.tests.map((t) => _TestChip(name: t.name)).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_rounded, size: 17),
                label: const Text('Upload Results'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COMPLETED TAB
// ─────────────────────────────────────────────

class _CompletedTab extends StatelessWidget {
  final List<_CompletedRequest> requests;
  const _CompletedTab({required this.requests});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 48, color: AppColors.ink3.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            const Text('No completed results yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink3)),
            const SizedBox(height: 4),
            const Text('Completed lab results will appear here.', style: TextStyle(fontSize: 12, color: AppColors.ink3)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _CompletedCard(request: requests[index]),
    );
  }
}

class _CompletedCard extends StatefulWidget {
  final _CompletedRequest request;
  const _CompletedCard({required this.request});

  @override
  State<_CompletedCard> createState() => _CompletedCardState();
}

class _CompletedCardState extends State<_CompletedCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.request.patientName, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        const SizedBox(height: 3),
                        Text('${widget.request.patientId} · ${widget.request.requestId}', style: const TextStyle(fontSize: 10.5, color: AppColors.ink3, fontFamily: 'DMMono')),
                        const SizedBox(height: 3),
                        Text('${widget.request.techName} · ${widget.request.completedAt}', style: const TextStyle(fontSize: 11, color: AppColors.ink3)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const AppStatusChip(label: 'Done', status: AppStatus.ok),
                      const SizedBox(height: 6),
                      Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AppColors.ink3, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.border),
            _ResultsTable(results: widget.request.results),
            if (widget.request.notified)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.ok),
                    const SizedBox(width: 5),
                    Text('Doctor and patient notified · ${widget.request.completedAt}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ok)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UPLOAD SHEET
// API: POST /api/consultation/lab-result/
// ─────────────────────────────────────────────

class _UploadSheet extends StatefulWidget {
  final _LabRequest request;
  final VoidCallback onSubmitted;

  const _UploadSheet({required this.request, required this.onSubmitted});

  @override
  State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  late Map<String, TextEditingController> _controllers;
  late Map<String, bool?> _boolValues;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  // ── dynamic check using inputType from model ──
  bool _isBoolTest(_LabTest test) => test.inputType == 'BOOLEAN';

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final t in widget.request.tests)
        if (!_isBoolTest(t)) t.name: TextEditingController(),
    };
    _boolValues = {
      for (final t in widget.request.tests)
        if (_isBoolTest(t)) t.name: null,
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isValid {
    for (final v in _boolValues.values)  { if (v == null)             return false; }
    for (final c in _controllers.values) { if (c.text.trim().isEmpty) return false; }
    return true;
  }

  // ── build result string from all inputs ──
  String _buildResultString() {
    final parts = <String>[];
    for (final t in widget.request.tests) {
      if (_isBoolTest(t)) {
        final val = _boolValues[t.name] == true ? 'Positive' : 'Negative';
        parts.add('${t.name}: $val');
      } else {
        parts.add('${t.name}: ${_controllers[t.name]?.text.trim() ?? ''}');
      }
    }
    if (_notesController.text.trim().isNotEmpty) {
      parts.add('Notes: ${_notesController.text.trim()}');
    }
    return parts.join('\n');
  }

  // ── POST /api/consultation/lab-result/ ──
  Future<void> _submit() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all test results before submitting.'),
        backgroundColor: AppColors.ink,
      ));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ApiService().uploadLabResult(
        visitId:    widget.request.visitId,
        labStaffId: ApiService.currentStaffId ?? '',
        result:     _buildResultString(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSubmitted();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Results uploaded. Doctor notified.'),
        backgroundColor: AppColors.ok,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed: ${e.toString()}'),
        backgroundColor: AppColors.err,
      ));
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
            Center(child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 18),
              width: 38, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            )),
            const Text('Upload Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 3),
            Text('${widget.request.tests.map((t) => t.name).join(' + ')} · ${widget.request.patientName}',
              style: const TextStyle(fontSize: 12, color: AppColors.ink3, height: 1.5)),
            const SizedBox(height: 6),
            Text('Requested at ${widget.request.requestedAt}',
              style: const TextStyle(fontSize: 11.5, color: AppColors.ink3)),
            const SizedBox(height: 20),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 20),

            // ── dynamic test fields based on inputType ──
            ...widget.request.tests.map((test) {
              if (_isBoolTest(test)) {
                return _BoolTestField(
                  testName: test.name,
                  value: _boolValues[test.name],
                  onChanged: (v) => setState(() => _boolValues[test.name] = v),
                );
              }
              return _TextTestField(
                test: test,
                controller: _controllers[test.name]!,
              );
            }),

            const SizedBox(height: 4),
            _FieldLabel(label: 'Additional Observations'),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Any additional observations or flags...',
                hintStyle: const TextStyle(color: AppColors.ink3, fontSize: 12.5),
                filled: true, fillColor: AppColors.bg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                border:        OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded, size: 19),
                label: Text(_isSubmitting ? 'Submitting…' : 'Submit & Notify Doctor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9), side: BorderSide(color: AppColors.border)),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOCAL WIDGETS
// ─────────────────────────────────────────────

class _TestChip extends StatelessWidget {
  final String name;
  const _TestChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(50), border: Border.all(color: AppColors.border)),
      child: Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink2)),
    );
  }
}

class _ResultsTable extends StatelessWidget {
  final List<_LabResult> results;
  const _ResultsTable({required this.results});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Container(
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: _TableHeaderCell('Test')),
                  Expanded(flex: 2, child: _TableHeaderCell('Result')),
                  Expanded(flex: 2, child: _TableHeaderCell('Ref')),
                ],
              ),
            ),
            ...results.asMap().entries.map((entry) {
              final i      = entry.key;
              final r      = entry.value;
              final isLast = i == results.length - 1;
              final resultColor = r.flag == 'H' ? AppColors.err : r.flag == 'L' ? AppColors.warn : AppColors.ink;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: isLast ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(r.testName, style: const TextStyle(fontSize: 12, color: AppColors.ink))),
                    Expanded(flex: 2, child: Text(r.unit != null ? '${r.value} ${r.unit}' : r.value,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: resultColor, fontFamily: 'DMMono'))),
                    Expanded(flex: 2, child: Text(r.referenceRange ?? '—', style: const TextStyle(fontSize: 10.5, color: AppColors.ink3, fontFamily: 'DMMono'))),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.5));
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.7, color: AppColors.ink3));
  }
}

class _TextTestField extends StatelessWidget {
  final _LabTest test;
  final TextEditingController controller;
  const _TextTestField({required this.test, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label: test.name),
          if (test.referenceRange != null) ...[
            const SizedBox(height: 2),
            Text('Reference: ${test.referenceRange}${test.unit != null ? ' ${test.unit}' : ''}',
              style: const TextStyle(fontSize: 10, color: AppColors.ink3)),
          ],
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: test.inputType == 'NUMBER'
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            style: const TextStyle(fontSize: 13, color: AppColors.ink),
            decoration: InputDecoration(
              hintText:    test.inputType == 'NUMBER' ? 'Enter value' : 'Enter result',
              suffixText:  test.unit,
              suffixStyle: const TextStyle(color: AppColors.ink3, fontSize: 12),
              hintStyle:   const TextStyle(color: AppColors.ink3, fontSize: 12.5),
              filled: true, fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              border:        OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoolTestField extends StatelessWidget {
  final String testName;
  final bool? value;
  final ValueChanged<bool> onChanged;

  const _BoolTestField({required this.testName, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label: testName),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _BoolOption(label: 'Negative', selected: value == false, isPositive: false, onTap: () => onChanged(false))),
              const SizedBox(width: 8),
              Expanded(child: _BoolOption(label: 'Positive', selected: value == true,  isPositive: true,  onTap: () => onChanged(true))),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoolOption extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isPositive;
  final VoidCallback onTap;

  const _BoolOption({required this.label, required this.selected, required this.isPositive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final activeColor  = isPositive ? AppColors.err : AppColors.ok;
    final activeBg     = isPositive ? AppColors.errBg : AppColors.okBg;
    final activeBorder = isPositive ? AppColors.errBorder : AppColors.okBorder;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? activeBg : AppColors.bg,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: selected ? activeBorder : AppColors.border, width: selected ? 1.5 : 1),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? activeColor : AppColors.ink2))),
      ),
    );
  }
}
