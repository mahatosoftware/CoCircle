import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/expense_model.dart';
import 'expense_controller.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/copyright_footer.dart';

import 'package:cocircle/l10n/app_localizations.dart';
import '../../../../core/widgets/native_ad_widget.dart';

class ExpenseList extends ConsumerWidget {
  final String tripId;
  final String currency;
  const ExpenseList({super.key, required this.tripId, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesStream = ref.watch(tripExpensesProvider(tripId));
    final l10n = AppLocalizations.of(context)!;

    return expensesStream.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return Center(child: Text(l10n.noExpensesYet));
        }
        final int adInterval = 4;
        final int totalItems = expenses.length + (expenses.length / adInterval).floor();

        return ListView.builder(
          itemCount: totalItems,
          itemBuilder: (context, index) {
            if (index > 0 && (index + 1) % (adInterval + 1) == 0) {
              return const NativeAdWidget();
            }

            final expenseIndex = index - (index / (adInterval + 1)).floor();
            if (expenseIndex >= expenses.length) return const SizedBox.shrink();

            final expense = expenses[expenseIndex];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey[100],
                child: Icon(_getCategoryIcon(expense.category), color: AppPallete.primary),
              ),
              title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                l10n.paidBySummary(
                  expense.payerId == FirebaseAuth.instance.currentUser?.uid ? l10n.you : l10n.member,
                  DateFormat.MMMd().format(expense.date),
                ) + (expense.payers.length > 1 ? ' ' + l10n.plusMore(expense.payers.length - 1) : ''),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$currency ${expense.amount.toStringAsFixed(2)}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (expense.category != ExpenseCategory.settlement.name)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.push('/trip/$tripId/expense/${expense.id}/edit', extra: expense);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              const SizedBox(width: 8),
                              Text(l10n.edit),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              onTap: () {
                context.push('/trip/$tripId/expense/${expense.id}');
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.errorWithDetails(e.toString()))),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final category = ExpenseCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => ExpenseCategory.misc,
    );
    switch (category) {
      case ExpenseCategory.food: return Icons.restaurant;
      case ExpenseCategory.travel: return Icons.flight;
      case ExpenseCategory.stay: return Icons.hotel;
      case ExpenseCategory.shopping: return Icons.shopping_bag;
      case ExpenseCategory.fuel: return Icons.local_gas_station;
      case ExpenseCategory.misc: return Icons.receipt;
      case ExpenseCategory.settlement: return Icons.handshake;
    }
  }
}
