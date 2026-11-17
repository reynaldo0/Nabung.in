import 'package:material_ui/material_ui.dart';

String formatRupiah(int amount) {
  final digits = amount.abs().toString();
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    final start = (end - 3).clamp(0, end).toInt();
    groups.insert(0, digits.substring(start, end));
  }
  return '${amount < 0 ? '-' : ''}Rp ${groups.join('.')}';
}

String formatDate(String? isoDate) {
  if (isoDate == null) return 'Belum ditentukan';
  final date = DateTime.tryParse(isoDate);
  if (date == null) return 'Belum ditentukan';
  const months = [
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
  return '${date.day} ${months[date.month - 1]} ${date.year}';
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
