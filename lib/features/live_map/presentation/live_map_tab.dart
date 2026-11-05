import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:collection/collection.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../data/map_repository_impl.dart';
import '../../tracking/application/tracking_notifier.dart';
import '../domain/member_location_model.dart';
import 'live_map_controller.dart';
import 'widgets/group_dashboard.dart';
import 'widgets/member_bottom_sheet.dart';

final mapTileProviderProvider = FutureProvider<TileProvider>((ref) async {
  return await ref.watch(mapRepositoryProvider).getTileProvider();
});

class LiveMapTab extends ConsumerStatefulWidget {
  final String tripId;
  const LiveMapTab({super.key, required this.tripId});

  @override
  ConsumerState<LiveMapTab> createState() => _LiveMapTabState();
}

class _LiveMapTabState extends ConsumerState<LiveMapTab> {
  late final MapController _mapController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Automatically start location sharing when the user opens the live map page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trackingProvider.notifier).startTracking(widget.tripId);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<LatLng> _decodePolyline(String str) {
    if (str.isEmpty) return [];
    final List<LatLng> coordinates = [];
    int index = 0, len = str.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = str.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = str.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      coordinates.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return coordinates;
  }

  void _centerOnUser(MemberLocationModel myLoc) {
    _mapController.move(LatLng(myLoc.latitude, myLoc.longitude), 14.5);
    ref.read(liveMapControllerProvider(widget.tripId).notifier).toggleFollowMe(true);
  }

  void _fitAllMembers(List<MemberLocationModel> members) {
    if (members.isEmpty) return;
    final points = members.map((m) => LatLng(m.latitude, m.longitude)).toList();
    
    // Also include destinations
    final mapState = ref.read(liveMapControllerProvider(widget.tripId));
    for (final dest in mapState.destinations.values) {
      points.add(LatLng(dest['latitude'] as double, dest['longitude'] as double));
    }

    if (points.length == 1) {
      _mapController.move(points.first, 14.5);
    } else {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0),
        ),
      );
    }
    ref.read(liveMapControllerProvider(widget.tripId).notifier).toggleFollowMe(false);
  }

  void _showAddDestinationDialog(LatLng latLng) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Meetup Point'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Mountain Cafe, Petrol Pump',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                ref.read(liveMapControllerProvider(widget.tripId).notifier).addNewDestination(
                      name,
                      latLng.latitude,
                      latLng.longitude,
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tileProviderAsync = ref.watch(mapTileProviderProvider);
    final trackingState = ref.watch(trackingProvider);
    final mapState = ref.watch(liveMapControllerProvider(widget.tripId));
    final controller = ref.read(liveMapControllerProvider(widget.tripId).notifier);
    final user = ref.watch(authStateChangesProvider).value;

    final myLocation = mapState.members.firstWhereOrNull(
      (m) => m.userId == user?.uid,
    ) ?? MemberLocationModel(
      userId: '',
      name: '',
      latitude: 12.9716, // Bangalore default center if no GPS
      longitude: 77.5946,
      lastUpdated: DateTime.now(),
    );

    // Initial camera placement
    if (!_initialized && mapState.members.isNotEmpty && user != null) {
      final userLoc = mapState.members.firstWhereOrNull((m) => m.userId == user.uid);
      if (userLoc != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(LatLng(userLoc.latitude, userLoc.longitude), 13.0);
        });
        _initialized = true;
      }
    }

    // Auto camera follow
    if (mapState.followMe && user != null) {
      final userLoc = mapState.members.firstWhereOrNull((m) => m.userId == user.uid);
      if (userLoc != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(LatLng(userLoc.latitude, userLoc.longitude), _mapController.camera.zoom);
        });
      }
    }

    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Render Layer
          tileProviderAsync.when(
            data: (tileProvider) => FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(myLocation.latitude, myLocation.longitude),
                initialZoom: 13.0,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture && mapState.followMe) {
                    controller.toggleFollowMe(false);
                  }
                  if (position.rotation != mapState.mapRotation) {
                    controller.updateRotation(position.rotation);
                  }
                },
                onLongPress: (tapPosition, latLng) {
                  _showAddDestinationDialog(latLng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'in.mahato.cocircle',
                  tileProvider: tileProvider,
                ),
                // 2. Active routes rendering (including user routes and other vehicles)
                PolylineLayer(
                  polylines: [
                    // Draw user active navigation route
                    if (mapState.navigationRoute != null)
                      Polyline(
                        points: mapState.navigationRoute!.coordinates,
                        color: theme.colorScheme.primary,
                        strokeWidth: 5.0,
                      ),
                    // Draw other vehicles' shared routes
                    ...mapState.routes.entries.map((entry) {
                      final userId = entry.key;
                      final routeData = entry.value;
                      if (userId == user?.uid) return null; // Avoid duplicating own navigation line

                      final polylineStr = routeData['encodedPolyline'] as String? ?? '';
                      if (polylineStr.isEmpty) return null;

                      final points = _decodePolyline(polylineStr);
                      final member = mapState.members.firstWhereOrNull((m) => m.userId == userId);
                      final vehicle = VehicleConfig.getById(member?.vehicleId);

                      return Polyline(
                        points: points,
                        color: vehicle.color.withValues(alpha: 0.7),
                        strokeWidth: 4.0,
                      );
                    }).whereType<Polyline>(),
                  ],
                ),
                // 3. Destinations & Meetup Points Marker Layer
                MarkerLayer(
                  markers: mapState.destinations.values.map((dest) {
                    final lat = (dest['latitude'] as num).toDouble();
                    final lng = (dest['longitude'] as num).toDouble();
                    final name = dest['name'] as String? ?? 'Meetup';
                    final destId = dest['id'] as String;

                    final isActiveDest = mapState.activeDestinationId == destId;

                    return Marker(
                      point: LatLng(lat, lng),
                      width: 80,
                      height: 80,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () {
                          controller.selectActiveDestination(destId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Selected Active Destination: $name'),
                              action: SnackBarAction(
                                label: 'Delete',
                                onPressed: () => controller.removeDestination(destId),
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isActiveDest ? theme.colorScheme.primary : Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                name,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.location_on_rounded,
                              color: isActiveDest ? theme.colorScheme.primary : Colors.grey,
                              size: 34,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // 4. Member markers & marker clustering layer
                SafeMarkerClusterLayer(
                  mapController: _mapController,
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(6),
                    builder: (context, clusterMarkers) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: theme.colorScheme.primary,
                        ),
                        child: Center(
                          child: Text(
                            clusterMarkers.length.toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    markers: mapState.members.map((member) {
                      final vehicle = VehicleConfig.getById(member.vehicleId);

                      return Marker(
                        point: LatLng(member.latitude, member.longitude),
                        width: 55,
                        height: 55,
                        child: GestureDetector(
                          onTap: () {
                            controller.selectMember(member.userId);
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (ctx) => MemberBottomSheet(
                                tripId: widget.tripId,
                                member: member,
                                currentUserLocation: myLocation.userId.isNotEmpty ? myLocation : null,
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              // Avatar Container
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: vehicle.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: member.photoUrl != null && member.photoUrl!.isNotEmpty
                                      ? NetworkImage(member.photoUrl!)
                                      : null,
                                  child: member.photoUrl == null || member.photoUrl!.isEmpty
                                      ? Text(member.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 14))
                                      : null,
                                ),
                              ),
                              // Online/Offline status dot badge
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: member.online ? Colors.green : Colors.grey,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                              // Vehicle type indicator badge
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                  ),
                                  child: Icon(vehicle.icon, size: 10, color: vehicle.color),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text(err.toString())),
          ),

          // 5. Compass Overlay (top left)
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: FloatingActionButton.small(
                heroTag: 'compass_btn',
                onPressed: () {
                  _mapController.rotate(0.0);
                  controller.updateRotation(0.0);
                },
                backgroundColor: theme.cardColor,
                child: Transform.rotate(
                  angle: -mapState.mapRotation * pi / 180,
                  child: Icon(Icons.navigation, color: theme.colorScheme.primary),
                ),
              ),
            ),
          ),

          // 6. Share Location Control card (top right)
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Card(
                elevation: 4,
                color: theme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trackingState.isTracking ? Icons.location_on : Icons.location_off,
                        color: trackingState.isTracking ? Colors.green : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        trackingState.isTracking ? 'Sharing Live' : 'Location Idle',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: trackingState.isTracking ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Switch.adaptive(
                        value: trackingState.isTracking,
                        activeColor: Colors.green,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) {
                          if (val) {
                            ref.read(trackingProvider.notifier).startTracking(widget.tripId);
                          } else {
                            ref.read(trackingProvider.notifier).stopTracking();
                            controller.stopNavigation();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 7. Navigation guidance overlay (top center)
          if (mapState.isNavigating && mapState.navigationRoute != null)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Card(
                  color: theme.colorScheme.primaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.directions_outlined),
                    title: const Text(
                      'Navigating group route...',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      'Dist: ${(mapState.navigationRoute!.distance / 1000).toStringAsFixed(1)} km  |  '
                      'ETA: ${(mapState.navigationRoute!.duration / 60).round()} mins',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: TextButton(
                      onPressed: () => controller.stopNavigation(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),

          // 8. Navigation Controls & Re-center utilities (right side)
          Positioned(
            right: 16,
            bottom: 260,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in_btn',
                  onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
                  backgroundColor: theme.cardColor,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out_btn',
                  onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
                  backgroundColor: theme.cardColor,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'fit_members_btn',
                  onPressed: () => _fitAllMembers(mapState.members),
                  backgroundColor: theme.cardColor,
                  child: const Icon(Icons.group_work_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'my_location_btn',
                  onPressed: () {
                    if (myLocation.userId.isNotEmpty) {
                      _centerOnUser(myLocation);
                    }
                  },
                  backgroundColor: theme.cardColor,
                  child: Icon(
                    mapState.followMe ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                    color: mapState.followMe ? theme.colorScheme.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // 9. Dashboard pull sheet (at bottom)
          GroupDashboard(
            tripId: widget.tripId,
            currentUserLocation: myLocation.userId.isNotEmpty ? myLocation : null,
          ),
        ],
      ),
    );
  }
}

class SafeMarkerClusterLayer extends StatelessWidget {
  final MapController mapController;
  final MarkerClusterLayerOptions options;

  const SafeMarkerClusterLayer({
    super.key,
    required this.mapController,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerClusterLayer(
      mapCamera: MapCamera.of(context),
      mapController: mapController,
      options: options,
    );
  }
}
