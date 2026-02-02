import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cocircle/features/trips/presentation/trip_controller.dart';
import 'package:cocircle/features/circles/presentation/circle_controller.dart';
import 'package:cocircle/features/financial/settlements/presentation/settlement_controller.dart';
import 'package:cocircle/features/financial/expenses/domain/expense_model.dart';
import 'package:cocircle/features/financial/expenses/presentation/expense_controller.dart';
import 'package:cocircle/features/financial/settlements/domain/settlement_model.dart';
import 'package:cocircle/core/widgets/copyright_footer.dart';
import 'package:collection/collection.dart';

class SettlementList extends ConsumerWidget {
  final String tripId;
  final String currency;
  const SettlementList({super.key, required this.tripId, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailsProvider(tripId));
    final activeSettlementsAsync = ref.watch(activeSettlementsProvider(tripId));
    final expensesAsync = ref.watch(tripExpensesProvider(tripId));

    return tripAsync.when(
      data: (trip) {
        final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
        
        return activeSettlementsAsync.when(
          data: (settlements) {
            return expensesAsync.when(
              data: (expenses) {
                final history = expenses.where((e) => e.category == ExpenseCategory.settlement.name).toList();

                if (settlements.isEmpty && history.isEmpty) {
                  return _buildEmptyState(context, ref);
                }

                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure cards take full width
                    children: [
                      if (settlements.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Text(
                            'Active Settlements',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...settlements.asMap().entries.map((entry) {
                          final t = entry.value;
                          return membersAsync.when(
                            data: (members) => _buildActiveSettlementCard(context, ref, t, members),
                            loading: () => const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: LinearProgressIndicator(),
                            ),
                            error: (err, _) => Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Error loading members: $err'),
                            ),
                          );
                        }),
                      ],
                      if (history.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 32, 16, 12),
                          child: Text(
                            'Settlement History',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...history.map((expense) => membersAsync.when(
                          data: (members) => _buildHistoryTile(expense, members),
                          loading: () => const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: LinearProgressIndicator(),
                          ),
                          error: (err, _) => Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Error: $err'),
                          ),
                        )),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text('Error loading history: $e')),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Center(child: Text('Error calculating settlements: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading trip: $err')),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.green[100]),
          const SizedBox(height: 24),
          const Text(
            'All settled up!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 12),
          const Text(
            'Everyone is even. Any new expenses added will show up here if settlements are needed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSettlementCard(BuildContext context, WidgetRef ref, SettlementTransaction t, List<dynamic> members) {
    final fromMember = members.firstWhereOrNull((m) => m.uid == t.fromUid);
    final toMember = members.firstWhereOrNull((m) => m.uid == t.toUid);
    final fromName = fromMember?.displayName ?? t.fromUid.substring(0, 4);
    final toName = toMember?.displayName ?? t.toUid.substring(0, 4);

    final currentUser = FirebaseAuth.instance.currentUser;
    final isPayer = currentUser?.uid == t.fromUid;
    final isReceiver = currentUser?.uid == t.toUid;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.send, color: Colors.green, size: 20),
              ),
              title: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  children: [
                    TextSpan(text: fromName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' pays '),
                    TextSpan(text: toName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              trailing: Text(
                '$currency${t.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
              ),
            ),
            if (isPayer || isReceiver)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmSettleUp(context, ref, t, fromName, toName),
                  icon: const Icon(Icons.check),
                  label: const Text('Settle Up'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(ExpenseModel expense, List<dynamic> members) {
    final fromUid = expense.payerId;
    final toUid = expense.splitDetails.keys.first;
    
    final fromMember = members.firstWhereOrNull((m) => m.uid == fromUid);
    final toMember = members.firstWhereOrNull((m) => m.uid == toUid);
    
    final fromName = fromMember?.displayName ?? fromUid.substring(0, 4);
    final toName = toMember?.displayName ?? toUid.substring(0, 4);

    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text('$fromName settled with $toName'),
      subtitle: Text(DateFormat.MMMd().format(expense.date)),
      trailing: Text(
        '$currency${expense.amount.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _confirmSettleUp(BuildContext context, WidgetRef ref, SettlementTransaction t, String fromName, String toName) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isPayer = currentUser?.uid == t.fromUid;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Settle Up'),
        content: Text(isPayer 
          ? 'Confirm that you have paid $currency${t.amount} to $toName?'
          : 'Confirm that you have received $currency${t.amount} from $fromName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(settlementControllerProvider.notifier).settleUp(
                tripId: tripId,
                fromUid: t.fromUid,
                toUid: t.toUid,
                amount: t.amount,
                context: context, // Using outer context
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
