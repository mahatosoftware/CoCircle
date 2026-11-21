import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../domain/action_item_model.dart';

class SmartAssistantBanner extends StatelessWidget {
  final List<ActionItemModel> actions;
  final VoidCallback onOpenActivityCenter;

  const SmartAssistantBanner({
    super.key,
    required this.actions,
    required this.onOpenActivityCenter,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return Card(
        elevation: 0,
        color: const Color(0xFFF0FDF4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFA7F3D0)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppPallete.tertiary, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All caught up! No pending votes, tasks, or settlements.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final urgentCount = actions.where((a) => a.urgency == ActionItemUrgency.urgent).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppPallete.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppPallete.primary, size: 18),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Needs Your Attention',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (urgentCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppPallete.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$urgentCount urgent',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            TextButton(
              onPressed: onOpenActivityCenter,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text('View All (${actions.length})', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Horizontal Action Item Strip
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length > 5 ? 5 : actions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = actions[index];
              return _ActionCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final ActionItemModel item;

  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 270,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.urgency == ActionItemUrgency.urgent
              ? const Color(0xFFEF4444).withValues(alpha: 0.4)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          width: item.urgency == ActionItemUrgency.urgent ? 1.5 : 1,
        ),
        boxShadow: AppPallete.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 16, color: item.iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.tripName ?? 'CoCircle',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.urgencyColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.urgencyLabel,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: item.urgencyColor,
                  ),
                ),
              ),
            ],
          ),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 28,
              child: FilledButton(
                onPressed: () => context.push(item.actionRoute),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPallete.primary,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.actionLabel),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
