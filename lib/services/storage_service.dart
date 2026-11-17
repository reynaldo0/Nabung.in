import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal_model.dart';

class StorageService {
  StorageService(this._preferences);

  static const goalsKey = 'goals_v1';
  static const transactionsKey = 'transactions_v1';
  static const onboardingCompletedKey = 'onboarding_completed_v1';
  final SharedPreferences _preferences;

  static Future<StorageService> initialize() async =>
      StorageService(await SharedPreferences.getInstance());

  bool get hasCompletedOnboarding =>
      _preferences.getBool(onboardingCompletedKey) ?? false;

  Future<bool> completeOnboarding() =>
      _preferences.setBool(onboardingCompletedKey, true);

  Future<List<GoalModel>> getGoals() async {
    final raw = _preferences.getString(goalsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => GoalModel.fromJson(Map<String, dynamic>.from(item)))
          .where((goal) => goal.id.isNotEmpty)
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<bool> saveGoals(List<GoalModel> goals) => _preferences.setString(
    goalsKey,
    jsonEncode(goals.map((goal) => goal.toJson()).toList()),
  );

  Future<List<TransactionItem>> getTransactions() async {
    final raw = _preferences.getString(transactionsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map(
            (item) => TransactionItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<bool> saveTransactions(List<TransactionItem> transactions) =>
      _preferences.setString(
        transactionsKey,
        jsonEncode(transactions.map((item) => item.toJson()).toList()),
      );

  Future<bool> addGoal(GoalModel goal) async {
    final goals = await getGoals()
      ..add(goal);
    return saveGoals(goals);
  }

  Future<bool> updateGoal(GoalModel goal) async {
    final goals = await getGoals();
    final index = goals.indexWhere((item) => item.id == goal.id);
    if (index < 0) return false;
    goals[index] = goal;
    return saveGoals(goals);
  }

  Future<bool> deleteGoal(String id) async {
    final goals = await getGoals();
    return saveGoals(goals.where((goal) => goal.id != id).toList());
  }

  Future<List<TransactionItem>> getTransactionsByGoalId(String goalId) async =>
      (await getTransactions()).where((item) => item.goalId == goalId).toList();

  Future<bool> completeGoal(String id) async {
    final goals = await getGoals();
    final index = goals.indexWhere((goal) => goal.id == id);
    if (index < 0) return false;
    goals[index] = goals[index].copyWith(
      status: 'completed',
      updatedAt: DateTime.now().toIso8601String(),
    );
    return saveGoals(goals);
  }
}
