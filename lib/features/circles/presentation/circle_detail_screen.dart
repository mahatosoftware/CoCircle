import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import 'circle_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';
import 'package:cocircle/features/trips/domain/trip_model.dart';
import 'package:cocircle/features/trips/presentation/trip_controller.dart';
import 'package:cocircle/features/shopping_lists/presentation/shopping_list_controller.dart';



class CircleDetailScreen extends ConsumerWidget {
  final String circleId;
  const CircleDetailScreen({super.key, required this.circleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circleAsync = ref.watch(circleDetailsProvider(circleId));
    final tripsStream = ref.watch(circleTripsProvider(circleId));

    return Scaffold(
      appBar: AppBar(
        title: circleAsync.when(
          data: (circle) => Text(circle.name),
          loading: () => Text(AppLocalizations.of(context)!.loading),
          error: (_, __) => Text(AppLocalizations.of(context)!.error),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), 
            onPressed: () => context.push('/circle/$circleId/settings'),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: AppLocalizations.of(context)!.tripsAndEvents),
                const Tab(text: 'Shopping Lists'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  tripsStream.when(
                    data: (trips) {
                      if (trips.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               const Icon(Icons.flight_takeoff, size: 60, color: Colors.grey),
                               const SizedBox(height: 16),
                               Text(AppLocalizations.of(context)!.noTripsYet, style: Theme.of(context).textTheme.titleMedium),
                               const SizedBox(height: 8),
                               ElevatedButton(
                                 onPressed: () => context.push('/circle/$circleId/create-trip'),
                                 child: Text(AppLocalizations.of(context)!.planATrip),
                               )
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: trips.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final trip = trips[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: trip.type == TripType.trip ? Colors.orange : Colors.purple,
                                child: Icon(trip.type == TripType.trip ? Icons.flight : Icons.event, color: Colors.white),
                              ),
                              title: Text(trip.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                trip.startDate != null 
                                ? DateFormat.yMMMd().format(trip.startDate!) 
                                : AppLocalizations.of(context)!.noDateSet,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                 context.push('/trip/${trip.id}');
                              },
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text(AppLocalizations.of(context)!.errorWithDetails(err.toString()))),
                  ),
                  ref.watch(circleShoppingListsProvider(circleId)).when(
                    data: (lists) {
                      if (lists.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               const Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
                               const SizedBox(height: 16),
                               Text('No shopping lists yet', style: Theme.of(context).textTheme.titleMedium),
                               const SizedBox(height: 8),
                               ElevatedButton(
                                 onPressed: () => context.push('/circle/$circleId/create-shopping-list'),
                                 child: const Text('Create Shopping List'),
                               )
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: lists.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final list = lists[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.teal,
                                child: Icon(Icons.shopping_cart, color: Colors.white),
                              ),
                              title: Text(list.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(DateFormat.yMMMd().format(list.createdAt)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                 context.push('/shopping-list/${list.id}', extra: list);
                              },
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   ListTile(
                     leading: const Icon(Icons.flight),
                     title: Text(AppLocalizations.of(context)!.planATrip),
                     onTap: () {
                       Navigator.pop(ctx);
                       context.push('/circle/$circleId/create-trip');
                     },
                   ),
                   ListTile(
                     leading: const Icon(Icons.shopping_cart),
                     title: const Text('Create Shopping List'),
                     onTap: () {
                       Navigator.pop(ctx);
                       context.push('/circle/$circleId/create-shopping-list');
                     },
                   ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
