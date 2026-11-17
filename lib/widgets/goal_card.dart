import 'package:material_ui/material_ui.dart';

import '../models/goal_model.dart';
import '../utils/currency_formatter.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({required this.goal, super.key});

  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    final progress = progressFor(goal.currentAmount, goal.targetAmount);
    final locationColor = savingLocationColor(goal.savingLocation);
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
              Expanded(
                child: Text(
                  goal.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: locationColor.withAlpha(24),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  savingLocationLabel(goal.savingLocation),
                  style: TextStyle(
                    color: locationColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupiah(goal.currentAmount),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Text(
                'dari ${formatRupiah(goal.targetAmount)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5F5EF),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF16856B)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${(progress * 100).round()}% tercapai',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (goal.targetDate != null)
                Text(
                  formatDate(goal.targetDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
