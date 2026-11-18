import 'package:flutter/services.dart';

String formatRupiah(int amount) {
  final absVal = amount.abs();
  if (absVal >= 1000000000000) {
    final trillions = absVal / 1000000000000;
    final formattedTrillion = trillions.toStringAsFixed(3).replaceAll('.', ',');
    return '${amount < 0 ? '-' : ''}Rp $formattedTrillion Triliun';
  }

  final digits = absVal.toString();
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    final start = (end - 3).clamp(0, end).toInt();
    groups.insert(0, digits.substring(start, end));
  }
  return '${amount < 0 ? '-' : ''}Rp ${groups.join('.')}';
}

String formatPlainNumber(int amount) {
  final digits = amount.abs().toString();
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    final start = (end - 3).clamp(0, end).toInt();
    groups.insert(0, digits.substring(start, end));
  }
  return groups.join('.');
}

int parseRupiah(String text) {
  final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
  if (clean.isEmpty) return 0;
  return int.tryParse(clean) ?? 0;
}

const List<String> _monthsShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

const List<String> _monthsFull = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String formatDate(String? isoDate) {
  if (isoDate == null) return 'Belum ditentukan';
  final date = DateTime.tryParse(isoDate);
  if (date == null) return 'Belum ditentukan';
  return '${date.day} ${_monthsShort[date.month - 1]} ${date.year}';
}

String formatDateFromDateTime(DateTime date) {
  return '${date.day} ${_monthsShort[date.month - 1]} ${date.year}';
}

String formatDateFull(DateTime date) {
  return '${date.day} ${_monthsFull[date.month - 1]} ${date.year}';
}

double progressFor(int currentAmount, int targetAmount) {
  if (targetAmount <= 0) return 0;
  return (currentAmount / targetAmount).clamp(0.0, 1.0);
}

int remainingFor(int currentAmount, int targetAmount) {
  if (targetAmount <= 0) return 0;
  final remaining = targetAmount - currentAmount;
  return remaining > 0 ? remaining : 0;
}

String savingLocationLabel(String value) {
  const labels = {
    'cash': 'Cash',
    'e_wallet': 'E-Wallet',
    'bank_account': 'Rekening Bank',
    'deposit': 'Deposito',
  };
  return labels[value] ?? value;
}

Color savingLocationColor(String value) {
  switch (value) {
    case 'bank_account':
      return const Color(0xFF3B82A0);
    case 'e_wallet':
      return const Color(0xFFD99127);
    case 'deposit':
      return const Color(0xFF7C5CBF);
    default:
      return const Color(0xFF16856B);
  }
}

String frequencyLabel(String? value) {
  switch (value) {
    case 'daily':
      return 'Harian';
    case 'weekly':
      return 'Mingguan';
    case 'monthly':
      return 'Bulanan';
    default:
      return 'Bulanan';
  }
}

String frequencyUnit(String? value) {
  switch (value) {
    case 'daily':
      return 'hari';
    case 'weekly':
      return 'minggu';
    default:
      return 'bulan';
  }
}

class InstallmentEstimation {
  const InstallmentEstimation({
    required this.periods,
    required this.estimatedDate,
  });

  final int periods;
  final DateTime estimatedDate;
}

class DeadlineCalculation {
  const DeadlineCalculation({
    required this.installmentAmount,
    required this.periods,
    required this.daysDiff,
  });

  final int installmentAmount;
  final int periods;
  final int daysDiff;
}

/// Mode 1 Kalkulator: Atur Nominal Cicilan -> Hitung Estimasi Durasi & Tanggal Tercapai
InstallmentEstimation estimateFromInstallment({
  required int remainingAmount,
  required int installmentAmount,
  required String frequency,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  if (remainingAmount <= 0 || installmentAmount <= 0) {
    return InstallmentEstimation(periods: 0, estimatedDate: today);
  }

  final periods = (remainingAmount / installmentAmount).ceil();
  DateTime estimated;

  if (frequency == 'daily') {
    estimated = today.add(Duration(days: periods));
  } else if (frequency == 'weekly') {
    estimated = today.add(Duration(days: periods * 7));
  } else {
    final targetMonth = today.month + periods;
    final lastDayOfTargetMonth = DateTime(today.year, targetMonth + 1, 0).day;
    final safeDay =
        today.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : today.day;
    estimated = DateTime(today.year, targetMonth, safeDay);
  }

  return InstallmentEstimation(periods: periods, estimatedDate: estimated);
}

/// Mode 2 Kalkulator: Atur Tanggal Target -> Hitung Nominal Wajib per Periode
DeadlineCalculation calculateInstallmentFromDate({
  required int remainingAmount,
  required DateTime targetDate,
  required String frequency,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
  final daysDiff = target.difference(today).inDays;

  if (remainingAmount <= 0 || daysDiff <= 0) {
    return DeadlineCalculation(
      installmentAmount: remainingAmount > 0 ? remainingAmount : 0,
      periods: 1,
      daysDiff: 0,
    );
  }

  int periods;
  if (frequency == 'daily') {
    periods = daysDiff;
  } else if (frequency == 'weekly') {
    periods = (daysDiff / 7).ceil();
  } else {
    periods = (daysDiff / 30).ceil();
  }

  if (periods < 1) periods = 1;
  final requiredAmount = (remainingAmount / periods).ceil();

  return DeadlineCalculation(
    installmentAmount: requiredAmount,
    periods: periods,
    daysDiff: daysDiff,
  );
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final value = int.tryParse(digits) ?? 0;
    final formatted = formatPlainNumber(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}