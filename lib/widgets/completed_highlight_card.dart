import 'package:material_ui/material_ui.dart';

import '../models/goal_model.dart';
import '../utils/currency_formatter.dart';

class CompletedHighlightCard extends StatelessWidget {
  const CompletedHighlightCard({
    required this.goal,
    required this.onComplete,
    super.key,
  });

  final GoalModel goal;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F5EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB7E2D3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF16856B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Target tercapai!',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: const Color(0xFF116B56)),
                ),
              ),
              Text(
                savingLocationLabel(goal.savingLocation),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(goal.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            '${formatRupiah(goal.currentAmount)} dari ${formatRupiah(goal.targetAmount)}',
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.done),
            label: const Text('Tandai Selesai'),
          ),
        ],
      ),
    );
  }
}
