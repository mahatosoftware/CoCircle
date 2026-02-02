import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cocircle/core/theme/app_pallete.dart';
import 'package:cocircle/features/circles/presentation/circle_controller.dart';
import 'package:cocircle/features/trips/presentation/trip_controller.dart';
import '../domain/expense_model.dart';
import 'expense_controller.dart';
import 'package:cocircle/core/widgets/copyright_footer.dart';
import 'package:cocircle/l10n/app_localizations.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String tripId;
  final String expenseId;

  const ExpenseDetailScreen({
    super.key,
    required this.tripId,
    required this.expenseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(expenseDetailProvider(expenseId));
    final tripAsync = ref.watch(tripDetailsProvider(tripId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expenseDetailsTitle),
        actions: [
          expenseAsync.when(
            data: (expense) => expense.category == ExpenseCategory.settlement.name
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => context.push('/trip/$tripId/expense/$expenseId/edit', extra: expense),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _showDeleteConfirmation(context, ref, expense),
                      ),
                    ],
                  ),
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: expenseAsync.when(
        data: (expense) => tripAsync.when(
          data: (trip) {
            final circleAsync = ref.watch(circleDetailsProvider(trip.circleId));
            return circleAsync.when(
              data: (circle) => _buildBody(context, ref, expense, trip.circleId, circle.currency),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading circle: $e')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading trip: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorWithDetails(e.toString()))),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ExpenseModel expense, String circleId, String currency) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppPallete.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppPallete.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(_getCategoryIcon(expense.category), size: 48, color: AppPallete.primary),
                const SizedBox(height: 16),
                Text(
                  expense.title,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$currency ${expense.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppPallete.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(expense.date),
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Paid By Section
          _buildSectionTitle(l10n.paidBy),
          const SizedBox(height: 12),
          _buildPayerList(context, ref, expense, circleId, currency),
          
          const SizedBox(height: 32),
          
          // Split Details Section
          _buildSectionTitle('${l10n.splitDetailsWithType(expense.splitType.name.toUpperCase())}'),
          const SizedBox(height: 12),
          _buildSplitBreakdown(context, ref, expense, circleId, currency),
          
          const SizedBox(height: 32),
          
          // Notes Section
          if (expense.notes != null && expense.notes!.isNotEmpty) ...[
            _buildSectionTitle(l10n.notes),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(expense.notes!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPayerList(BuildContext context, WidgetRef ref, ExpenseModel expense, String circleId, String currency) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: expense.payers.entries.map((entry) {
        final memberAsync = ref.watch(circleMembersProvider(circleId));
        return memberAsync.when(
          data: (members) {
            final member = members.firstWhere((m) => m.uid == entry.key);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppPallete.primary.withValues(alpha: 0.1),
                child: Text(member.displayName[0].toUpperCase()),
              ),
              title: Text(member.displayName),
              trailing: Text(
                '$currency ${entry.value.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => Text(l10n.loadMemberError),
        );
      }).toList(),
    );
  }

  Widget _buildSplitBreakdown(BuildContext context, WidgetRef ref, ExpenseModel expense, String circleId, String currency) {
     final l10n = AppLocalizations.of(context)!;
    final memberAsync = ref.watch(circleMembersProvider(circleId));
    
    return memberAsync.when(
      data: (members) {
        if (expense.splitType == SplitType.equal) {
          final participants = members.where((m) => expense.splitDetails.containsKey(m.uid) || expense.splitDetails.isEmpty).toList();
          final amountPerPerson = expense.amount / participants.length;
          
          return Column(
            children: participants.map((member) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Text(member.displayName[0].toUpperCase()),
              ),
              title: Text(member.displayName),
              trailing: Text(
                '$currency ${amountPerPerson.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )).toList(),
          );
        }
        
        // For other split types, show the raw value (%, ratio, etc.) and calculate the actual amount
        return Column(
          children: expense.splitDetails.entries.map((entry) {
            final member = members.firstWhere((m) => m.uid == entry.key);
            final calculatedAmount = _calculateSplitAmount(expense, entry.value);
            
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Text(member.displayName[0].toUpperCase()),
              ),
              title: Text(member.displayName),
              subtitle: Text(_getSplitSubtitle(expense.splitType, entry.value)),
              trailing: Text(
                '$currency ${calculatedAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => Text(l10n.loadSplitDetailsError),
    );
  }

  double _calculateSplitAmount(ExpenseModel expense, double value) {
    switch (expense.splitType) {
      case SplitType.equal:
        return expense.amount / (expense.splitDetails.length > 0 ? expense.splitDetails.length : 1);
      case SplitType.exact:
        return value;
      case SplitType.percentage:
        return (value / 100) * expense.amount;
      case SplitType.ratio:
        final totalRatio = expense.splitDetails.values.fold(0.0, (sum, val) => sum + val);
        return (value / totalRatio) * expense.amount;
    }
  }

  String _getSplitSubtitle(SplitType type, double value) {
    switch (type) {
      case SplitType.percentage: return '$value%';
      case SplitType.ratio: return 'Ratio: $value';
      case SplitType.exact: return 'Exact Amount';
      case SplitType.equal: return 'Equal Share';
    }
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

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.deleteExpenseTitle),
          content: Text(l10n.deleteExpenseConfirmMessage(expense.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                context.pop(); // Close dialog
                ref.read(expenseControllerProvider.notifier).deleteExpense(
                  tripId: expense.tripId,
                  expenseId: expense.id,
                  title: expense.title,
                  amount: expense.amount,
                  context: context,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }
}
