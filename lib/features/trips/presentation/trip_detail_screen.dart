import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../financial/expenses/presentation/expense_list.dart';
import '../../financial/expenses/presentation/expense_stats_screen.dart';
import '../../financial/settlements/presentation/settlement_list.dart';
import '../../circles/presentation/circle_controller.dart';
import 'trip_controller.dart';



class TripDetailScreen extends ConsumerWidget {
  final String tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailsProvider(tripId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: tripAsync.when(
            data: (trip) => Text(trip.name),
            loading: () => const Text('Loading...'),
            error: (_, __) => const Text('Error'),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expenses', icon: Icon(Icons.receipt)),
              Tab(text: 'Settlements', icon: Icon(Icons.handshake)),
              Tab(text: 'Insights', icon: Icon(Icons.bar_chart)),
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
                        title: const Text('Edit Trip Name'),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: 'Trip Name',
                            border: OutlineInputBorder(),
                          ),
                          autofocus: true,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
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
                            child: const Text('Save'),
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
                 ],
               ),
               loading: () => const Center(child: CircularProgressIndicator()),
               error: (err, stack) => Center(child: Text('Error loading circle: $err')),
             );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/trip/$tripId/create-expense'),
          child: const Icon(Icons.receipt_long),
        ),
      ),
    );
  }
}
