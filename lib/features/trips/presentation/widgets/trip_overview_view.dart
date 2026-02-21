import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/trip_model.dart';
import '../../../circles/presentation/circle_controller.dart';
import '../../../financial/expenses/presentation/expense_controller.dart';
import '../../../../core/theme/app_pallete.dart';
import 'package:cocircle/l10n/app_localizations.dart';

class TripOverviewView extends ConsumerWidget {
  final TripModel trip;
  const TripOverviewView({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final circleAsync = ref.watch(circleDetailsProvider(trip.circleId));
    final expensesStream = ref.watch(tripExpensesProvider(trip.id));

    return circleAsync.when(
      data: (circle) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trip Info Card
          Card(
            elevation: 0,
            color: AppPallete.primary.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppPallete.primary.withValues(alpha: 0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        trip.type == TripType.trip ? Icons.flight : Icons.event,
                        color: AppPallete.primary,
                      ),
                    ],
                  ),
                  if (trip.location != null && trip.location!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(trip.location!, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        trip.startDate != null
                            ? DateFormat.yMMMd().format(trip.startDate!)
                            : l10n.noDateSet,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (trip.endDate != null) ...[
                        const Text(' - '),
                        Text(
                          DateFormat.yMMMd().format(trip.endDate!),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Spending Summary
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.totalSpending,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  expensesStream.when(
                    data: (expenses) {
                      final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
                      return Text(
                        '${circle.currency} ${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.primary,
                        ),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Recent Activity
          Text(
            l10n.recentActivity,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          expensesStream.when(
            data: (expenses) {
              if (expenses.isEmpty) {
                return Text(l10n.noExpensesYet, style: const TextStyle(color: Colors.grey));
              }
              final recent = expenses.take(3).toList();
              return Column(
                children: recent.map((e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    child: const Icon(Icons.receipt, size: 18),
                  ),
                  title: Text(e.title),
                  subtitle: Text(DateFormat.MMMd().format(e.date)),
                  trailing: Text(
                    '${circle.currency} ${e.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )).toList(),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.error)),
    );
  }
}
