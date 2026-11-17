class GoalModel {
  const GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.savingLocation,
    this.savingAmount,
    this.frequency,
    this.calculationMode,
    this.targetDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final String savingLocation;
  final int? savingAmount;
  final String? frequency;
  final String? calculationMode;
  final String? targetDate;
  final String status;
  final String createdAt;
  final String updatedAt;

  bool get isCompleted => status == 'completed';
  bool get isReadyToComplete =>
      status == 'active' && targetAmount > 0 && currentAmount >= targetAmount;

  GoalModel copyWith({String? status, int? currentAmount, String? updatedAt}) {
    return GoalModel(
      id: id,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      savingLocation: savingLocation,
      savingAmount: savingAmount,
      frequency: frequency,
      calculationMode: calculationMode,
      targetDate: targetDate,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'savingLocation': savingLocation,
    'savingAmount': savingAmount,
    'frequency': frequency,
    'calculationMode': calculationMode,
    'targetDate': targetDate,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final targetAmount = _intValue(json['targetAmount']);
    final currentAmount = _intValue(json['currentAmount']);
    final status = json['status'] == 'completed' ? 'completed' : 'active';
    return GoalModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Target tanpa nama',
      targetAmount: targetAmount < 0 ? 0 : targetAmount,
      currentAmount: currentAmount < 0 ? 0 : currentAmount,
      savingLocation: json['savingLocation']?.toString() ?? 'cash',
      savingAmount: _nullableInt(json['savingAmount']),
      frequency: json['frequency']?.toString(),
      calculationMode: json['calculationMode']?.toString(),
      targetDate: json['targetDate']?.toString(),
      status: status,
      createdAt:
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt:
          json['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    return _intValue(value);
  }
}

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.goalId,
    required this.type,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String goalId;
  final String type;
  final int amount;
  final String? note;
  final String createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'goalId': goalId,
    'type': type,
    'amount': amount,
    'note': note,
    'createdAt': createdAt,
  };

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      TransactionItem(
        id: json['id']?.toString() ?? '',
        goalId: json['goalId']?.toString() ?? '',
        type: json['type'] == 'withdrawal' ? 'withdrawal' : 'deposit',
        amount: int.tryParse(json['amount']?.toString() ?? '') ?? 0,
        note: json['note']?.toString(),
        createdAt:
            json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      );
}
