import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../financial/expenses/presentation/expense_list.dart';
import '../../financial/expenses/presentation/expense_stats_screen.dart';
import '../../financial/expenses/presentation/expense_audit_screen.dart';
import '../../financial/settlements/presentation/settlement_list.dart';
import '../../circles/presentation/circle_controller.dart';
import 'trip_controller.dart';
import '../../../financial/expenses/l10n/app_localizations.dart';



class TripDetailScreen extends ConsumerWidget {
  final String tripId;
  final int initialTabIndex;
  const TripDetailScreen({super.key, required this.tripId, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailsProvider(tripId));
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 4,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: tripAsync.when(
            data: (trip) => Text(trip.name),
            loading: () => Text(l10n.loading),
            error: (_, __) => Text(l10n.error),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.expensesTab, icon: const Icon(Icons.receipt)),
              Tab(text: l10n.settlementsTab, icon: const Icon(Icons.handshake)),
              Tab(text: l10n.insightsTab, icon: const Icon(Icons.bar_chart)),
              Tab(text: l10n.auditTab, icon: const Icon(Icons.history_edu)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                tripAsync.whenData((trip) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final controller = TextEditingController(text: trip.name);
                      return AlertDialog(
                        title: Text(l10n.editTripName),
                        content: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: l10n.tripNameLabel,
                            border: const OutlineInputBorder(),
                          ),
                          autofocus: true,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.cancel),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final newName = controller.text.trim();
                              if (newName.isNotEmpty && newName != trip.name) {
                                ref.read(tripControllerProvider.notifier).updateTripName(
                                  trip: trip,
                                  newName: newName,
                                  context: context,
                                );
                                Navigator.pop(context);
                              }
                            },
                            child: Text(l10n.save),
                          ),
                        ],
                      );
                    },
                  );
                });
              },
            ),
          ],
        ),
        body: tripAsync.when(
          data: (trip) {
             final circleAsync = ref.watch(circleDetailsProvider(trip.circleId));
             
             return circleAsync.when(
               data: (circle) => TabBarView(
                 children: [
                   ExpenseList(tripId: tripId, currency: circle.currency),
                   SingleChildScrollView(
                     controller: ScrollController(),
                     child: Column(
                       children: [
                         Padding(
                           padding: const EdgeInsets.all(16.0),
                           child: Text(
                             'Settlement Plan (${circle.currency})', 
                             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                           ),
                         ),
                         SettlementList(tripId: tripId, currency: circle.currency),
                         const SizedBox(height: 100), // Space for FAB
                       ],
                     ),
                   ),
                   ExpenseStatsView(tripId: tripId),
                   ExpenseAuditView(tripId: tripId),
                 ],
               ),
               loading: () => const Center(child: CircularProgressIndicator()),
               error: (err, stack) => Center(child: Text(l10n.loadCircleError(err.toString()))),
             );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text(l10n.errorWithDetails(err.toString()))),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/trip/$tripId/create-expense'),
          child: const Icon(Icons.receipt_long),
        ),
      ),
    );
  }
}
