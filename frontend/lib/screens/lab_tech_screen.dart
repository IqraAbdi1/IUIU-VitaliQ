import 'package:flutter/material.dart';
import '../theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MOCK DATA — replace with API call when backend is ready
// Backend: GET /api/v1/lab-requests?status=pending   (pending tab)
//          GET /api/v1/lab-requests?status=completed  (completed tab)
// ─────────────────────────────────────────────────────────────────────────────

enum _LabRequestStatus { urgent, pending, completed }

class _LabTest {
  final String name;
  final String? unit; // Backend: lab_test.unit
  final String? referenceRange; // Backend: lab_test.reference_range
  final String? placeholder;

  const _LabTest({
    required this.name,
    this.unit,
    this.referenceRange,
    this.placeholder,
  });
}

class _LabRequest {
  final String requestId; // Backend: lab_request.id
  final String patientName; // Backend: patient.full_name
  final String patientId; // Backend: patient.username
  final String doctorName; // Backend: doctor.full_name
  final String requestedAt; // Backend: lab_request.requested_at
  final _LabRequestStatus status; // Backend: lab_request.status
  final List<_LabTest> tests; // Backend: lab_request.tests[]

  const _LabRequest({
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
  final String testName; // Backend: lab_result.test_name
  final String value; // Backend: lab_result.result_value
  final String? unit; // Backend: lab_result.unit
  final String? referenceRange; // Backend: lab_result.reference_range
  final String? flag; // Backend: lab_result.flag (H / L / null)

  const _LabResult({
    required this.testName,
    required this.value,
    this.unit,
    this.referenceRange,
    this.flag,
  });
}

class _CompletedRequest {
  final String requestId; // Backend: lab_request.id
  final String patientName; // Backend: patient.full_name
  final String patientId; // Backend: patient.username
  final String techName; // Backend: lab_tech.full_name
  final String completedAt; // Backend: lab_result.uploaded_at
  final List<_LabResult> results; // Backend: lab_result.result_data[]
  final bool notified; // Backend: lab_result.notified

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

// ── Pending requests mock ──────────────────────────────────────────────────
final List<_LabRequest> _mockPendingRequests = [
  const _LabRequest(
    requestId: 'LR-2025-042',
    patientName: 'Khalid Abdelgadir',
    patientId: 'STU-2024-1092',
    doctorName: 'Dr. Kato Emmanuel',
    requestedAt: '10:32 AM',
    status: _LabRequestStatus.urgent,
    tests: [
      _LabTest(name: 'Malaria RDT', placeholder: 'Positive / Negative'),
      _LabTest(
        name: 'Haemoglobin',
        unit: 'g/dL',
        referenceRange: '12–16',
        placeholder: 'e.g. 10.8',
      ),
      _LabTest(
        name: 'WBC Count',
        unit: '/μL',
        referenceRange: '4,000–11,000',
        placeholder: 'e.g. 12400',
      ),
      _LabTest(
        name: 'Platelet Count',
        unit: '/μL',
        referenceRange: '150,000–400,000',
        placeholder: 'e.g. 88000',
      ),
    ],
  ),
  const _LabRequest(
    requestId: 'LR-2025-047',
    patientName: 'Amina Nakato',
    patientId: 'STU-2024-0842',
    doctorName: 'Dr. Ssali Ibrahim',
    requestedAt: '11:15 AM',
    status: _LabRequestStatus.pending,
    tests: [
      _LabTest(
        name: 'Typhoid (Widal Test)',
        placeholder: 'Positive / Negative',
      ),
      _LabTest(
        name: 'Haemoglobin',
        unit: 'g/dL',
        referenceRange: '12–16',
        placeholder: 'e.g. 12.0',
      ),
    ],
  ),
  const _LabRequest(
    requestId: 'LR-2025-051',
    patientName: 'Omar Suleiman',
    patientId: 'STU-2024-0319',
    doctorName: 'Dr. Kato Emmanuel',
    requestedAt: '12:08 PM',
    status: _LabRequestStatus.pending,
    tests: [
      _LabTest(name: 'Urinalysis', placeholder: 'Normal / Abnormal'),
      _LabTest(name: 'Urine Culture', placeholder: 'Positive / Negative'),
      _LabTest(
        name: 'Creatinine',
        unit: 'mg/dL',
        referenceRange: '0.6–1.2',
        placeholder: 'e.g. 0.9',
      ),
    ],
  ),
  const _LabRequest(
    requestId: 'LR-2025-058',
    patientName: 'Fatima Osman',
    patientId: 'STU-2024-0901',
    doctorName: 'Dr. Ssali Ibrahim',
    requestedAt: '1:44 PM',
    status: _LabRequestStatus.pending,
    tests: [
      _LabTest(name: 'ECG Reading', placeholder: 'e.g. Normal sinus rhythm'),
      _LabTest(
        name: 'Troponin I',
        unit: 'ng/mL',
        referenceRange: '< 0.04',
        placeholder: 'e.g. 0.01',
      ),
    ],
  ),
];

// ── Completed requests mock ────────────────────────────────────────────────
final List<_CompletedRequest> _mockCompletedRequests = [
  const _CompletedRequest(
    requestId: 'LR-2025-039',
    patientName: 'Fatima Osman',
    patientId: 'STU-2024-0901',
    techName: 'Tech. Yusuf Kamau',
    completedAt: '9:48 AM',
    notified: true,
    results: [
      _LabResult(testName: 'Malaria RDT', value: 'POSITIVE', flag: 'H'),
      _LabResult(
        testName: 'Haemoglobin',
        value: '10.8',
        unit: 'g/dL',
        referenceRange: '12–16',
        flag: 'L',
      ),
    ],
  ),
  const _CompletedRequest(
    requestId: 'LR-2025-031',
    patientName: 'Abdi Hassan',
    patientId: 'STU-2024-0774',
    techName: 'Tech. Yusuf Kamau',
    completedAt: 'Yesterday · 3:22 PM',
    notified: true,
    results: [
      _LabResult(testName: 'Typhoid (Widal Test)', value: 'NEGATIVE'),
      _LabResult(
        testName: 'Haemoglobin',
        value: '13.4',
        unit: 'g/dL',
        referenceRange: '12–16',
      ),
    ],
  ),
  const _CompletedRequest(
    requestId: 'LR-2025-028',
    patientName: 'Zainab Musa',
    patientId: 'STU-2024-0655',
    techName: 'Tech. Yusuf Kamau',
    completedAt: 'Yesterday · 11:05 AM',
    notified: true,
    results: [
      _LabResult(testName: 'Urinalysis', value: 'ABNORMAL', flag: 'H'),
      _LabResult(
        testName: 'Creatinine',
        value: '1.5',
        unit: 'mg/dL',
        referenceRange: '0.6–1.2',
        flag: 'H',
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class LabTechScreen extends StatefulWidget {
  const LabTechScreen({super.key});

  @override
  State<LabTechScreen> createState() => _LabTechScreenState();
}

class _LabTechScreenState extends State<LabTechScreen> {
  int _tabIndex = 0; // 0 = Pending, 1 = Completed

  // Local list so we can remove items after upload (simulates submit)
  // Backend: replace with real API state management
  late List<_LabRequest> _pendingRequests;

  @override
  void initState() {
    super.initState();
    _pendingRequests = List.from(_mockPendingRequests);
  }

  void _onUploaded(String requestId) {
    // Backend: after POST /api/v1/lab-results/upload succeeds,
    // remove from pending and refresh completed list
    setState(() {
      _pendingRequests.removeWhere((r) => r.requestId == requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SubTabBar(
          tabIndex: _tabIndex,
          pendingCount: _pendingRequests.length,
          completedCount: _mockCompletedRequests.length,
          onTabChanged: (i) => setState(() => _tabIndex = i),
        ),
        Expanded(
          child: IndexedStack(
            index: _tabIndex,
            children: [
              _PendingTab(requests: _pendingRequests, onUploaded: _onUploaded),
              _CompletedTab(requests: _mockCompletedRequests),
            ],
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E4EB)),
          bottom: BorderSide(color: Color(0xFFE0E4EB)),
        ),
      ),
      child: Row(
        children: [
          _TabPill(
            label: 'Pending ($pendingCount)',
            active: tabIndex == 0,
            onTap: () => onTabChanged(0),
          ),
          _TabPill(
            label: 'Completed ($completedCount)',
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
// PENDING TAB
// ─────────────────────────────────────────────────────────────────────────────

class _PendingTab extends StatelessWidget {
  final List<_LabRequest> requests;
  final ValueChanged<String> onUploaded;

  const _PendingTab({required this.requests, required this.onUploaded});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: AppColors.ink3,
            ),
            const SizedBox(height: 12),
            Text(
              'All caught up!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No pending lab requests.',
              style: TextStyle(fontSize: 13, color: AppColors.ink3),
            ),
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
          request: req,
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
        request: request,
        onSubmitted: () => onUploaded(request.requestId),
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
    final isUrgent = request.status == _LabRequestStatus.urgent;
    final accentColor = isUrgent
        ? const Color(0xFFB81C24)
        : const Color(0xFFA05C00);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: accentColor, width: 3.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.tests.map((t) => t.name).join(' + '),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${request.patientName} · ${request.doctorName} · ${request.requestedAt}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.ink3,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        request.patientId,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.ink3,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _StatusChip(status: request.status),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Color(0xFFE0E4EB)),

          // Test list preview
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: request.tests
                  .map((t) => _TestChip(name: t.name))
                  .toList(),
            ),
          ),

          // Upload button
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
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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

// ─────────────────────────────────────────────────────────────────────────────
// COMPLETED TAB
// ─────────────────────────────────────────────────────────────────────────────

class _CompletedTab extends StatelessWidget {
  final List<_CompletedRequest> requests;

  const _CompletedTab({required this.requests});

  @override
  Widget build(BuildContext context) {
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
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
                        Text(
                          widget.request.patientName,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.request.patientId} · ${widget.request.requestId}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.ink3,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.request.techName} · ${widget.request.completedAt}',
                          style: TextStyle(fontSize: 11, color: AppColors.ink3),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const _StatusChip(status: _LabRequestStatus.completed),
                      const SizedBox(height: 6),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.ink3,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable results table
          if (_expanded) ...[
            Divider(height: 1, color: Color(0xFFE0E4EB)),
            _ResultsTable(results: widget.request.results),
            // Notified footer
            if (widget.request.notified)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: const Color(0xFF16714A),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Doctor and patient notified · ${widget.request.completedAt}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16714A),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UPLOAD SHEET (bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _UploadSheet extends StatefulWidget {
  final _LabRequest request;
  final VoidCallback onSubmitted;

  const _UploadSheet({required this.request, required this.onSubmitted});

  @override
  State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  late Map<String, TextEditingController> _controllers;
  // For RDT-style boolean tests (Positive/Negative)
  late Map<String, bool?> _boolValues;

  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  // Tests that use Positive/Negative toggle instead of text input
  // Backend: this could be driven by lab_test.input_type field
  static const _boolTestNames = {
    'Malaria RDT',
    'Typhoid (Widal Test)',
    'Urinalysis',
    'Urine Culture',
  };

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final t in widget.request.tests)
        if (!_boolTestNames.contains(t.name)) t.name: TextEditingController(),
    };
    _boolValues = {
      for (final t in widget.request.tests)
        if (_boolTestNames.contains(t.name)) t.name: null,
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  bool get _isValid {
    // All boolean tests must have a selection
    for (final entry in _boolValues.entries) {
      if (entry.value == null) return false;
    }
    // All text tests must be non-empty
    for (final c in _controllers.values) {
      if (c.text.trim().isEmpty) return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please fill in all test results before submitting.',
          ),
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

    // Backend: POST /api/v1/lab-results/upload
    // Payload: { lab_request_id, results: [{test_name, value, notes}] }
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      Navigator.pop(context);
      widget.onSubmitted();
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
                  color: Color(0xFFE0E4EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title block
            Text(
              'Upload Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${widget.request.tests.map((t) => t.name).join(' + ')} · ${widget.request.patientName}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.ink3,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Requested by ${widget.request.doctorName} · ${widget.request.requestedAt}',
              style: TextStyle(fontSize: 11.5, color: AppColors.ink3),
            ),

            const SizedBox(height: 20),
            Divider(height: 1, color: Color(0xFFE0E4EB)),
            const SizedBox(height: 20),

            // Test input fields
            ...widget.request.tests.map((test) {
              if (_boolTestNames.contains(test.name)) {
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

            // Notes
            const SizedBox(height: 4),
            _FieldLabel(label: 'Additional Observations'),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: TextStyle(fontSize: 13, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Any additional observations or flags...',
                hintStyle: TextStyle(color: AppColors.ink3, fontSize: 12.5),
                filled: true,
                fillColor: AppColors.bg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: Color(0xFFE0E4EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: Color(0xFFE0E4EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Submit CTA
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
                    : const Icon(Icons.check_rounded, size: 19),
                label: Text(
                  _isSubmitting ? 'Submitting…' : 'Submit & Notify Doctor',
                ),
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

            // Cancel
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.ink3,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                    side: BorderSide(color: Color(0xFFE0E4EB)),
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
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final _LabRequestStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border, label) = switch (status) {
      _LabRequestStatus.urgent => (
        const Color(0xFFFFF2F2),
        const Color(0xFFB81C24),
        const Color(0xFFF5AAAA),
        'Urgent',
      ),
      _LabRequestStatus.pending => (
        const Color(0xFFFFF7EA),
        const Color(0xFFA05C00),
        const Color(0xFFF5C97A),
        'Pending',
      ),
      _LabRequestStatus.completed => (
        const Color(0xFFEAFAF2),
        const Color(0xFF16714A),
        const Color(0xFF96DEBB),
        'Done',
      ),
    };

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

class _TestChip extends StatelessWidget {
  final String name;

  const _TestChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Color(0xFFE0E4EB)),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.ink2,
        ),
      ),
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
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Color(0xFFE0E4EB)),
        ),
        child: Column(
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE0E4EB))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Test',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink3,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Result',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink3,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Ref',
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
            ...results.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              final isLast = i == results.length - 1;

              final resultColor = r.flag == 'H'
                  ? const Color(0xFFB81C24)
                  : r.flag == 'L'
                  ? const Color(0xFFA05C00)
                  : AppColors.ink;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: isLast
                    ? null
                    : BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE0E4EB)),
                        ),
                      ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        r.testName,
                        style: TextStyle(fontSize: 12, color: AppColors.ink),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        r.unit != null ? '${r.value} ${r.unit}' : r.value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: resultColor,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        r.referenceRange ?? '—',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.ink3,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
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

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
        color: AppColors.ink3,
      ),
    );
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
            Text(
              'Reference: ${test.referenceRange}${test.unit != null ? ' ${test.unit}' : ''}',
              style: TextStyle(fontSize: 10, color: AppColors.ink3),
            ),
          ],
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(fontSize: 13, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: test.placeholder,
              hintStyle: TextStyle(color: AppColors.ink3, fontSize: 12.5),
              suffixText: test.unit,
              suffixStyle: TextStyle(color: AppColors.ink3, fontSize: 12),
              filled: true,
              fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: Color(0xFFE0E4EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: Color(0xFFE0E4EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: AppColors.accent, width: 1.5),
              ),
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

  const _BoolTestField({
    required this.testName,
    required this.value,
    required this.onChanged,
  });

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
              Expanded(
                child: _BoolOption(
                  label: 'Negative',
                  selected: value == false,
                  isPositive: false,
                  onTap: () => onChanged(false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BoolOption(
                  label: 'Positive',
                  selected: value == true,
                  isPositive: true,
                  onTap: () => onChanged(true),
                ),
              ),
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

  const _BoolOption({
    required this.label,
    required this.selected,
    required this.isPositive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isPositive
        ? const Color(0xFFB81C24)
        : const Color(0xFF16714A);
    final activeBg = isPositive
        ? const Color(0xFFFFF2F2)
        : const Color(0xFFEAFAF2);
    final activeBorder = isPositive
        ? const Color(0xFFF5AAAA)
        : const Color(0xFF96DEBB);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? activeBg : AppColors.bg,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected ? activeBorder : Color(0xFFE0E4EB),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected ? activeColor : AppColors.ink2,
            ),
          ),
        ),
      ),
    );
  }
}
