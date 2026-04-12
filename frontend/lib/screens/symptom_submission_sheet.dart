import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../shared/widgets.dart';

// ─────────────────────────────────────────────
// DATA MODEL — returned by the sheet on submit
// ─────────────────────────────────────────────

class SymptomSubmissionData {
  final String duration; // Backend: symptom.duration
  final List<String> symptoms; // Backend: symptom.name[]
  final String? temperature; // Backend: visits.temperature
  final String? notes; // Backend: symptom.notes

  const SymptomSubmissionData({
    required this.duration,
    required this.symptoms,
    this.temperature,
    this.notes,
  });
}

// ─────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────

const _kSymptoms = [
  'Fever',
  'Cough',
  'Headache',
  'Nausea',
  'Fatigue',
  'Chills',
  'Body aches',
  'Diarrhoea',
  'Chest pain',
  'Breathlessness',
  'Sore throat',
  'Vomiting',
];

const _kDurations = ['Under 24 hours', '1–3 days', '4–7 days', 'Over a week'];

// ─────────────────────────────────────────────
// PUBLIC ENTRY POINT
//
// Initial submission (from HomeScreen CTA):
//   showSymptomSubmissionSheet(context, onSubmitted: (data) { ... })
//
// Edit (from QueueSubmissionScreen):
//   showSymptomSubmissionSheet(context, existing: data, isEdit: true, onSubmitted: (data) { ... })
//
// Backend: POST /api/v1/visits/submit
// ─────────────────────────────────────────────

Future<void> showSymptomSubmissionSheet(
  BuildContext context, {
  SymptomSubmissionData? existing,
  bool isEdit = false,
  required ValueChanged<SymptomSubmissionData> onSubmitted,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SymptomSheet(
      existing: existing,
      isEdit: isEdit,
      onSubmitted: onSubmitted,
    ),
  );
}

// ─────────────────────────────────────────────
// SHEET WIDGET
// ─────────────────────────────────────────────

class _SymptomSheet extends StatefulWidget {
  final SymptomSubmissionData? existing;
  final bool isEdit;
  final ValueChanged<SymptomSubmissionData> onSubmitted;

  const _SymptomSheet({
    required this.existing,
    required this.isEdit,
    required this.onSubmitted,
  });

  @override
  State<_SymptomSheet> createState() => _SymptomSheetState();
}

class _SymptomSheetState extends State<_SymptomSheet> {
  late String _selectedDuration;
  late Set<String> _selectedSymptoms;
  late TextEditingController _tempController;
  late TextEditingController _notesController;

  bool _isSubmitting = false;
  bool _showConfirmation = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _selectedDuration = e?.duration ?? '1–3 days';
    _selectedSymptoms = Set<String>.from(e?.symptoms ?? []);
    _tempController = TextEditingController(text: e?.temperature ?? '');
    _notesController = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _tempController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _selectedSymptoms.isNotEmpty && !_isSubmitting;

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);

    // TODO: replace with real API call
    // Backend: POST /api/v1/visits/submit
    // Body: { patient_id, duration, symptoms: [...], temperature, notes }
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final data = SymptomSubmissionData(
      duration: _selectedDuration,
      symptoms: _selectedSymptoms.toList(),
      temperature: _tempController.text.trim().isEmpty
          ? null
          : _tempController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    // Show mid-screen confirmation, then close and return data
    setState(() {
      _isSubmitting = false;
      _showConfirmation = true;
    });

    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    Navigator.of(context).pop();
    widget.onSubmitted(data);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Stack(
            children: [
              // ── Main scrollable form ───────────────────────
              Column(
                children: [
                  const _SheetHandle(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEdit
                                ? 'Edit your submission'
                                : 'How are you feeling?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.isEdit
                                ? 'Update your symptoms below. Changes are logged and your priority may be reassessed.'
                                : 'Describe your symptoms honestly. Our system will assess your case and place you in the right queue — you don\'t need to self-diagnose.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.ink2,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 22),

                          _FieldLabel('How long have you had symptoms?'),
                          const SizedBox(height: 8),
                          _DurationPicker(
                            options: _kDurations,
                            selected: _selectedDuration,
                            onChanged: (val) =>
                                setState(() => _selectedDuration = val),
                          ),
                          const SizedBox(height: 20),

                          _FieldLabel('Select all that apply'),
                          const SizedBox(height: 4),
                          if (_selectedSymptoms.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'Tap at least one symptom to continue',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.ink3.withValues(alpha: 0.8),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          _SymptomChips(
                            options: _kSymptoms,
                            selected: _selectedSymptoms,
                            onToggle: (sym) => setState(() {
                              _selectedSymptoms.contains(sym)
                                  ? _selectedSymptoms.remove(sym)
                                  : _selectedSymptoms.add(sym);
                            }),
                          ),
                          const SizedBox(height: 20),

                          _FieldLabel('Temperature °C (optional)'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _tempController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,3}\.?\d{0,1}'),
                              ),
                            ],
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.ink,
                            ),
                            decoration: _inputDecoration('e.g. 38.4'),
                          ),
                          const SizedBox(height: 20),

                          _FieldLabel('Additional notes'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.ink,
                            ),
                            decoration: _inputDecoration(
                              'Anything the doctor should know...',
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Info box — uses AppInfoBox from shared/widgets.dart
                          AppInfoBox(
                            label: 'Note',
                            body:
                                'You may edit within 30 minutes of submission. Each edit is logged. Priority is assigned by medical need — not how you describe it.',
                            variant: AppInfoVariant.accent,
                          ),
                          const SizedBox(height: 18),

                          _SubmitButton(
                            enabled: _canSubmit,
                            isLoading: _isSubmitting,
                            isEdit: widget.isEdit,
                            onTap: _handleSubmit,
                          ),
                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Mid-screen confirmation overlay ────────────
              if (_showConfirmation)
                _ConfirmationOverlay(isEdit: widget.isEdit),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.ink3),
      filled: true,
      fillColor: AppColors.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONFIRMATION OVERLAY
// ─────────────────────────────────────────────

class _ConfirmationOverlay extends StatefulWidget {
  final bool isEdit;
  const _ConfirmationOverlay({required this.isEdit});

  @override
  State<_ConfirmationOverlay> createState() => _ConfirmationOverlayState();
}

class _ConfirmationOverlayState extends State<_ConfirmationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEdit
        ? 'Submission updated'
        : 'Doctor received your submission';
    final body = widget.isEdit
        ? 'Your changes have been saved.\nYour priority may be reassessed.'
        : 'Head to the clinic premise\nand await your turn';

    return Positioned.fill(
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.hero.withValues(alpha: 0.82),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Center(
            child: ScaleTransition(
              scale: _scale,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.ok,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ok.withValues(alpha: 0.45),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: Center(
        child: Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: AppColors.ink3,
        letterSpacing: 0.07 * 10.5,
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  const _DurationPicker({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isOn = opt == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isOn ? AppColors.accentLight : AppColors.surface2,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isOn ? AppColors.accent : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isOn ? AppColors.accent : AppColors.ink2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SymptomChips extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const _SymptomChips({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((sym) {
        final isOn = selected.contains(sym);
        return GestureDetector(
          onTap: () => onToggle(sym),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: isOn ? AppColors.accentLight : AppColors.surface2,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isOn ? AppColors.accent : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              sym,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isOn ? AppColors.accent : AppColors.ink2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final bool isEdit;
  final VoidCallback onTap;
  const _SubmitButton({
    required this.enabled,
    required this.isLoading,
    required this.isEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: [AppColors.accent, AppColors.accentDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : AppColors.border,
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.38),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 19,
                      color: enabled ? Colors.white : AppColors.ink3,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      isEdit ? 'Save Changes' : 'Submit & Join Queue',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: enabled ? Colors.white : AppColors.ink3,
                        letterSpacing: 0.01 * 14,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
