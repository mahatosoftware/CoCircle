import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cocircle/l10n/app_localizations.dart';
import 'package:cocircle/features/trips/domain/trip_model.dart';
import 'package:cocircle/features/trips/presentation/trip_controller.dart';
import 'circle_controller.dart';

class CircleTripsScreen extends ConsumerStatefulWidget {
  final String circleId;
  const CircleTripsScreen({super.key, required this.circleId});

  @override
  ConsumerState<CircleTripsScreen> createState() => _CircleTripsScreenState();
}

class _CircleTripsScreenState extends ConsumerState<CircleTripsScreen> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final tripsStream = ref.watch(circleTripsProvider(widget.circleId));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tripsAndEvents),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggleInactive') {
                setState(() {
                  _showInactive = !_showInactive;
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggleInactive',
                child: Row(
                  children: [
                    Icon(_showInactive ? Icons.visibility_off : Icons.visibility),
                    const SizedBox(width: 8),
                    Text(_showInactive ? 'Hide Inactive Trips' : 'Show Inactive Trips'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: tripsStream.when(
        data: (allTrips) {
          final trips = allTrips.where((t) => _showInactive || t.isActive).toList();
          
          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.flight_takeoff, size: 60, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text(
                     _showInactive ? 'No trips found' : AppLocalizations.of(context)!.noTripsYet, 
                     style: Theme.of(context).textTheme.titleMedium
                   ),
                   const SizedBox(height: 8),
                   ElevatedButton(
                     onPressed: () => context.push('/circle/${widget.circleId}/create-trip'),
                     child: Text(AppLocalizations.of(context)!.planATrip),
                   )
                ],
              ),
            );
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: trips.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                     context.push('/trip/${trip.id}');
                  },
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: trip.type == TripType.trip ? Colors.orange : Colors.purple,
                              child: Icon(
                                trip.type == TripType.trip ? Icons.flight : Icons.event, 
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              trip.name, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                trip.startDate != null 
                                ? DateFormat.yMMMd().format(trip.startDate!) 
                                : AppLocalizations.of(context)!.noDateSet,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!trip.isActive)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'INACTIVE',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(AppLocalizations.of(context)!.errorWithDetails(err.toString()))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/circle/${widget.circleId}/create-trip');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
