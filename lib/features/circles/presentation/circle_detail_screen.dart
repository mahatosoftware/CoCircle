import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import 'circle_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';
import 'package:cocircle/features/trips/domain/trip_model.dart';
import 'package:cocircle/features/trips/presentation/trip_controller.dart';



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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              AppLocalizations.of(context)!.tripsAndEvents,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: tripsStream.when(
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/circle/$circleId/create-trip'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
