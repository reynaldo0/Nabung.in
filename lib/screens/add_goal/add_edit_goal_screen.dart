import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/goal_model.dart';
import '../../services/storage_service.dart';
import '../../utils/currency_formatter.dart';

class AddEditGoalScreen extends StatefulWidget {
  const AddEditGoalScreen({
    required this.storage,
    this.existingGoal,
    super.key,
  });

  final StorageService storage;
  final GoalModel? existingGoal;

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _installmentController = TextEditingController();

  static const List<String> _locations = [
    'cash',
    'e_wallet',
    'bank_account',
    'deposit',
  ];

  static const List<String> _frequencies = [
    'daily',
    'weekly',
    'monthly',
  ];

  String _savingLocation = 'cash';
  String _calculationMode = 'installment'; // Default: Nominal Cicilan
  String _frequency = 'monthly';
  DateTime? _selectedDeadline;
  bool _isSaving = false;

  bool get _isEditMode => widget.existingGoal != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingGoal;
    if (existing != null) {
      _nameController.text = existing.name;
      _targetAmountController.text = formatPlainNumber(existing.targetAmount);
      _savingLocation = _locations.contains(existing.savingLocation)
          ? existing.savingLocation
          : 'cash';
      _calculationMode = existing.calculationMode == 'deadline'
          ? 'deadline'
          : 'installment';
      _frequency = _frequencies.contains(existing.frequency)
          ? existing.frequency!
          : 'monthly';
      if (existing.savingAmount != null && existing.savingAmount! > 0) {
        _installmentController.text = formatPlainNumber(existing.savingAmount!);
      }
      if (existing.targetDate != null) {
        _selectedDeadline = DateTime.tryParse(existing.targetDate!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _installmentController.dispose();
    super.dispose();
  }

  int get _parsedTargetAmount => parseRupiah(_targetAmountController.text);

  int get _parsedInstallmentAmount => parseRupiah(_installmentController.text);

  int get _remainingTarget {
    final target = _parsedTargetAmount;
    final current = widget.existingGoal?.currentAmount ?? 0;
    return remainingFor(current, target);
  }

  DateTime get _defaultTomorrow {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  Future<void> _pickDeadlineDate() async {
    final initial =
        (_selectedDeadline != null &&
            !_selectedDeadline!.isBefore(_defaultTomorrow))
        ? _selectedDeadline!
        : DateTime.now().add(const Duration(days: 30));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _defaultTomorrow,
      lastDate: DateTime(DateTime.now().year + 30),
    );

    if (picked != null && mounted) {
      setState(() => _selectedDeadline = picked);
    }
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final targetAmount = _parsedTargetAmount;
    final remaining = _remainingTarget;

    int? finalSavingAmount;
    String? finalFrequency;
    String? finalCalculationMode;
    String? finalTargetDate;

    if (_calculationMode == 'installment') {
      final installment = _parsedInstallmentAmount;
      if (installment > 0) {
        final estimation = estimateFromInstallment(
          remainingAmount: remaining,
          installmentAmount: installment,
          frequency: _frequency,
        );
        finalSavingAmount = installment;
        finalFrequency = _frequency;
        finalCalculationMode = 'installment';
        finalTargetDate = estimation.estimatedDate.toIso8601String();
      }
    } else {
      final deadline =
          _selectedDeadline ?? DateTime.now().add(const Duration(days: 30));
      final calc = calculateInstallmentFromDate(
        remainingAmount: remaining,
        targetDate: deadline,
        frequency: _frequency,
      );
      finalSavingAmount = calc.installmentAmount;
      finalFrequency = _frequency;
      finalCalculationMode = 'deadline';
      finalTargetDate = DateTime(
        deadline.year,
        deadline.month,
        deadline.day,
      ).toIso8601String();
    }

    setState(() => _isSaving = true);
    final nowIso = DateTime.now().toIso8601String();
    final existing = widget.existingGoal;

    final goal = GoalModel(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      targetAmount: targetAmount,
      currentAmount: existing?.currentAmount ?? 0,
      savingLocation: _savingLocation,
      savingAmount: finalSavingAmount,
      frequency: finalFrequency,
      calculationMode: finalCalculationMode,
      targetDate: finalTargetDate,
      status: existing?.status ?? 'active',
      createdAt: existing?.createdAt ?? nowIso,
      updatedAt: nowIso,
    );

    final saved = _isEditMode
        ? await widget.storage.updateGoal(goal)
        : await widget.storage.addGoal(goal);

    if (!mounted) return;
    if (!saved) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data gagal disimpan. Silakan coba lagi.'),
        ),
      );
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final targetAmount = _parsedTargetAmount;
    final remaining = _remainingTarget;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit target' : 'Target baru'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _SectionCard(
                title: 'Informasi Utama',
                icon: Icons.flag_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      autofocus: !_isEditMode,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nama target',
                        hintText: 'Contoh: Laptop Kuliah, Dana Darurat',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nama target wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _targetAmountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Nominal tujuan',
                        prefixText: 'Rp ',
                        hintText: '15.000.000',
                      ),
                      validator: (value) {
                        final amount = parseRupiah(value ?? '');
                        if (amount <= 0) {
                          return 'Masukkan nominal tujuan yang valid';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Wadah Penyimpanan',
                icon: Icons.account_balance_wallet_outlined,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _locations.map((loc) {
                    final isSelected = _savingLocation == loc;
                    final accent = savingLocationColor(loc);
                    return ChoiceChip(
                      label: Text(savingLocationLabel(loc)),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _savingLocation = loc),
                      selectedColor: accent.withAlpha(32),
                      backgroundColor: const Color(0xFFF6F8F7),
                      side: BorderSide(
                        color: isSelected ? accent : const Color(0xFFE4EAE7),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? accent : const Color(0xFF17211E),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Kalkulator Rencana 2 Arah',
                icon: Icons.calculate_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: 'installment',
                            icon: Icon(Icons.payments_outlined, size: 18),
                            label: Text('Nominal Cicilan'),
                          ),
                          ButtonSegment<String>(
                            value: 'deadline',
                            icon: Icon(Icons.event_outlined, size: 18),
                            label: Text('Tanggal Target'),
                          ),
                        ],
                        selected: {_calculationMode},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _calculationMode = selection.first;
                            if (_calculationMode == 'deadline' &&
                                _selectedDeadline == null) {
                              _selectedDeadline = DateTime.now().add(
                                const Duration(days: 30),
                              );
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Frekuensi menabung',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _frequencies.map((freq) {
                        final isSelected = _frequency == freq;
                        return ChoiceChip(
                          label: Text(frequencyLabel(freq)),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _frequency = freq),
                          selectedColor: const Color(0xFFE5F5EF),
                          backgroundColor: const Color(0xFFF6F8F7),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF16856B)
                                : const Color(0xFFE4EAE7),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF116B56)
                                : const Color(0xFF17211E),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (_calculationMode == 'installment') ...[
                      TextFormField(
                        controller: _installmentController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThousandsSeparatorInputFormatter(),
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText:
                              'Nominal cicilan per ${frequencyUnit(_frequency)} (opsional)',
                          prefixText: 'Rp ',
                          hintText: '500.000',
                        ),
                      ),
                    ] else ...[
                      InkWell(
                        onTap: _pickDeadlineDate,
                        borderRadius: BorderRadius.circular(14),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Pilih tanggal target tercapai',
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          child: Text(
                            formatDateFull(
                              _selectedDeadline ??
                                  DateTime.now().add(const Duration(days: 30)),
                            ),
                            style: const TextStyle(
                              color: Color(0xFF17211E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _CalculatorResultBox(
                      calculationMode: _calculationMode,
                      targetAmount: targetAmount,
                      remainingAmount: remaining,
                      installmentAmount: _parsedInstallmentAmount,
                      frequency: _frequency,
                      selectedDeadline:
                          _selectedDeadline ??
                          DateTime.now().add(const Duration(days: 30)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditMode ? 'Simpan perubahan' : 'Simpan target',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EAE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF16856B)),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CalculatorResultBox extends StatelessWidget {
  const _CalculatorResultBox({
    required this.calculationMode,
    required this.targetAmount,
    required this.remainingAmount,
    required this.installmentAmount,
    required this.frequency,
    required this.selectedDeadline,
  });

  final String calculationMode;
  final int targetAmount;
  final int remainingAmount;
  final int installmentAmount;
  final String frequency;
  final DateTime selectedDeadline;

  @override
  Widget build(BuildContext context) {
    final unit = frequencyUnit(frequency);

    if (targetAmount <= 0) {
      return _infoContainer(
        context,
        title: 'Simulasi rencana menabung',
        subtitle:
            'Masukkan nominal tujuan terlebih dahulu untuk melihat hasil perhitungan otomatis.',
      );
    }

    if (remainingAmount <= 0) {
      return _infoContainer(
        context,
        title: 'Target sudah terpenuhi',
        subtitle:
            'Saldo tabungan saat ini sudah mencapai atau melampaui nominal tujuan.',
      );
    }

    if (calculationMode == 'installment') {
      if (installmentAmount <= 0) {
        return _infoContainer(
          context,
          title: 'Estimasi waktu tercapai',
          subtitle:
              'Isi nominal cicilan per $unit di atas untuk menghitung estimasi tanggal target tercapai.',
        );
      }

      final estimation = estimateFromInstallment(
        remainingAmount: remainingAmount,
        installmentAmount: installmentAmount,
        frequency: frequency,
      );

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE5F5EF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB7E2D3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ESTIMASI TERCAPAI',
              style: TextStyle(
                color: Color(0xFF116B56),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${estimation.periods} $unit lagi (${formatDateFull(estimation.estimatedDate)})',
              style: const TextStyle(
                color: Color(0xFF17211E),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dengan menyisihkan ${formatRupiah(installmentAmount)} per $unit.',
              style: const TextStyle(
                color: Color(0xFF116B56),
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      );
    }

    final calc = calculateInstallmentFromDate(
      remainingAmount: remainingAmount,
      targetDate: selectedDeadline,
      frequency: frequency,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F5EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB7E2D3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REKOMENDASI TABUNGAN RUTIN',
            style: TextStyle(
              color: Color(0xFF116B56),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${formatRupiah(calc.installmentAmount)} / $unit',
              style: const TextStyle(
                color: Color(0xFF17211E),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selama ${calc.periods} $unit menuju ${formatDateFull(selectedDeadline)}.',
            style: const TextStyle(
              color: Color(0xFF116B56),
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoContainer(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF17211E),
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}