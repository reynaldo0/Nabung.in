import 'package:material_ui/material_ui.dart';

import '../../models/goal_model.dart';
import '../../services/storage_service.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/completed_highlight_card.dart';
import '../../widgets/goal_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({required this.storage, super.key});

  final StorageService storage;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<GoalModel> _goals = [];
  bool _isLoading = true;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await widget.storage.getGoals();
    if (!mounted) return;
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  List<GoalModel> get _activeGoals {
    final goals = _goals.where((goal) => !goal.isCompleted).toList();
    goals.sort((a, b) {
      if (a.isReadyToComplete != b.isReadyToComplete) {
        return a.isReadyToComplete ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return goals;
  }

  List<GoalModel> get _completedGoals {
    final goals = _goals.where((goal) => goal.isCompleted).toList();
    goals.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return goals;
  }

  Future<void> _completeGoal(GoalModel goal) async {
    final shouldComplete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan target?'),
        content: Text(
          'Target "${goal.name}" akan dipindahkan ke daftar Selesai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, tandai selesai'),
          ),
        ],
      ),
    );
    if (shouldComplete != true || !mounted) return;
    final saved = await widget.storage.completeGoal(goal.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Target berhasil ditandai selesai.'
              : 'Data gagal disimpan. Silakan coba lagi.',
        ),
      ),
    );
    if (saved) await _loadGoals();
  }

  Future<void> _showAddGoal() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _AddGoalDialog(storage: widget.storage),
    );
    if (!mounted || created != true) return;
    await _loadGoals();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Target berhasil dibuat.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeGoals = _activeGoals;
    final completedGoals = _completedGoals;
    final displayedGoals = _tabIndex == 0 ? activeGoals : completedGoals;
    final total = activeGoals.fold<int>(
      0,
      (sum, goal) => sum + goal.currentAmount,
    );
    final highlights = activeGoals
        .where((goal) => goal.isReadyToComplete)
        .toList();
    final regularGoals = _tabIndex == 0
        ? activeGoals.where((goal) => !goal.isReadyToComplete)
        : completedGoals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nabung.in'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loadGoals,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoal,
        icon: const Icon(Icons.add),
        label: const Text('Target baru'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadGoals,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    Text(
                      'Halo, penabung!',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sedikit demi sedikit, jadi tujuan.',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    _SummaryCard(total: total, count: activeGoals.length),
                    const SizedBox(height: 24),
                    SegmentedButton<int>(
                      segments: [
                        ButtonSegment(
                          value: 0,
                          label: Text('Berjalan (${activeGoals.length})'),
                        ),
                        ButtonSegment(
                          value: 1,
                          label: Text('Selesai (${completedGoals.length})'),
                        ),
                      ],
                      selected: {_tabIndex},
                      onSelectionChanged: (value) =>
                          setState(() => _tabIndex = value.first),
                    ),
                    const SizedBox(height: 20),
                    if (_tabIndex == 0 && highlights.isNotEmpty) ...[
                      Text(
                        'Siap dirayakan',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      ...highlights.map(
                        (goal) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CompletedHighlightCard(
                            goal: goal,
                            onComplete: () => _completeGoal(goal),
                          ),
                        ),
                      ),
                      if (regularGoals.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 10),
                          child: Text(
                            'Target lainnya',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                    ],
                    if (displayedGoals.isEmpty)
                      _EmptyState(
                        isCompletedTab: _tabIndex == 1,
                        onAdd: _showAddGoal,
                      )
                    else
                      ...regularGoals.map(
                        (goal) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GoalCard(goal: goal),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _AddGoalDialog extends StatefulWidget {
  const _AddGoalDialog({required this.storage});

  final StorageService storage;

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final now = DateTime.now().toIso8601String();
    final goal = GoalModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      targetAmount: int.parse(_amountController.text),
      currentAmount: 0,
      savingLocation: 'cash',
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );
    final saved = await widget.storage.addGoal(goal);
    if (!mounted) return;
    Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * .55;
    return AlertDialog(
      title: const Text('Buat target baru'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Nama target'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  decoration: const InputDecoration(
                    labelText: 'Nominal tujuan',
                  ),
                  validator: (value) {
                    final amount = int.tryParse(value ?? '');
                    return amount == null || amount <= 0
                        ? 'Masukkan nominal valid'
                        : null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan target'),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.total, required this.count});
  final int total;
  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xFF16856B),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              'Total Tabungan Aktif',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatRupiah(total),
            style: Theme.of(context).textTheme.displaySmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Dari $count target yang sedang berjalan',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Colors.white70),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isCompletedTab, required this.onAdd});
  final bool isCompletedTab;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 44),
    child: Column(
      children: [
        Icon(
          isCompletedTab ? Icons.emoji_events_outlined : Icons.savings_outlined,
          size: 54,
          color: const Color(0xFF16856B),
        ),
        const SizedBox(height: 14),
        Text(
          isCompletedTab
              ? 'Belum ada target yang selesai.'
              : 'Belum ada target tabungan.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (!isCompletedTab) ...[
          const SizedBox(height: 6),
          Text(
            'Buat target pertamamu untuk mulai mencatat progres menabung.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Buat target pertama'),
          ),
        ],
      ],
    ),
  );
}
