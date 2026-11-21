import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:collection/collection.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../trips/presentation/trip_controller.dart';
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

    // Check if trip has an initial destination set that should be auto-synchronized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSeedTripDestination();
    });
  }

  void _checkAndSeedTripDestination() {
    final tripAsync = ref.read(tripDetailsProvider(widget.tripId));
    tripAsync.whenData((trip) {
      if (trip.location != null && trip.location!.trim().isNotEmpty) {
        ref.read(liveMapControllerProvider(widget.tripId).notifier).seedTripDestinationIfNeeded(
          name: trip.location!,
          lat: 12.9716, // Default fallback coordinate; organizer can adjust pin
          lng: 77.5946,
        );
      }
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
    final mapState = ref.read(liveMapControllerProvider(widget.tripId));
    final points = <LatLng>[];

    for (final m in members) {
      points.add(LatLng(m.latitude, m.longitude));
    }

    for (final dest in mapState.destinations.values) {
      points.add(LatLng(dest['latitude'] as double, dest['longitude'] as double));
    }

    for (final pt in mapState.meetingPoints.values) {
      points.add(LatLng(pt['latitude'] as double, pt['longitude'] as double));
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 14.5);
    } else {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.only(top: 80, bottom: 220, left: 40, right: 40),
        ),
      );
    }
  }

  void _showAddDestinationDialog(LatLng latLng) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Point on Map'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Abbey Falls, Kamat Fuel Station',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Coords: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                ref.read(liveMapControllerProvider(widget.tripId).notifier).addMeetingPoint(
                  name,
                  latLng.latitude,
                  latLng.longitude,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('As Meeting Point'),
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
            child: const Text('As Destination Stop'),
          ),
        ],
      ),
    );
  }

  void _showLocationPrivacySheet(BuildContext context) {
    final trackingState = ref.read(trackingProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isTracking = trackingState.isTracking && trackingState.sharingStatus != 'offline';
          final isPaused = trackingState.sharingStatus == 'paused';

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Location Sharing & Privacy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Only authorized members of this trip can view your live position. You can pause or stop sharing anytime.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: isTracking ? (isPaused ? Colors.amber.shade50 : Colors.green.shade50) : Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isTracking ? (isPaused ? Colors.amber.shade300 : Colors.green.shade300) : Colors.grey.shade300,
                    ),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      isTracking ? (isPaused ? 'Location Sharing Paused' : 'Live Sharing Active') : 'Location Sharing Disabled',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isTracking ? (isPaused ? Colors.amber.shade900 : Colors.green.shade900) : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      isTracking
                          ? (trackingState.sharingExpiry != null
                              ? 'Auto-expires in ${trackingState.sharingExpiry!.difference(DateTime.now()).inHours}h ${trackingState.sharingExpiry!.difference(DateTime.now()).inMinutes % 60}m'
                              : 'Active until trip ends or stopped')
                          : 'No coordinates are relayed to the group',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: isTracking,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      if (val) {
                        ref.read(trackingProvider.notifier).startTracking(widget.tripId, duration: const Duration(hours: 8));
                      } else {
                        ref.read(trackingProvider.notifier).stopTracking();
                      }
                      Navigator.pop(ctx);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (isTracking) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (isPaused) {
                              ref.read(trackingProvider.notifier).resumeTracking();
                            } else {
                              ref.read(trackingProvider.notifier).pauseTracking();
                            }
                            Navigator.pop(ctx);
                          },
                          icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                          label: Text(isPaused ? 'Resume Sharing' : 'Pause for 30m'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(trackingProvider.notifier).stopTracking();
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text('Stop Sharing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmTriggerSOS(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Trigger Emergency SOS?'),
          ],
        ),
        content: const Text(
          'This will immediately broadcast an urgent emergency alert to ALL trip members with your current GPS coordinates and battery level.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(liveMapControllerProvider(widget.tripId).notifier).triggerEmergencySOS();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🚨 Emergency SOS alert broadcast to group!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Broadcast SOS Alert'),
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
      latitude: 12.9716,
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
    final hasEmergency = mapState.sosAlerts.isNotEmpty;

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

                // 2. Route Polylines
                PolylineLayer(
                  polylines: [
                    if (mapState.navigationRoute != null)
                      Polyline(
                        points: mapState.navigationRoute!.coordinates,
                        color: theme.colorScheme.primary,
                        strokeWidth: 5.0,
                      ),
                    ...mapState.routes.entries.map((entry) {
                      final userId = entry.key;
                      final routeData = entry.value;
                      if (userId == user?.uid) return null;

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

                // 3. Destinations & Meeting Points Layer
                MarkerLayer(
                  markers: [
                    // A. Destination Markers
                    ...mapState.destinations.values.map((dest) {
                      final lat = (dest['latitude'] as num).toDouble();
                      final lng = (dest['longitude'] as num).toDouble();
                      final name = dest['name'] as String? ?? 'Destination';
                      final destId = dest['id'] as String;
                      final isActiveDest = mapState.activeDestinationId == destId;

                      return Marker(
                        point: LatLng(lat, lng),
                        width: 90,
                        height: 80,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () {
                            controller.selectActiveDestination(destId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Target Destination: $name'),
                                action: SnackBarAction(
                                  label: 'Navigate in Maps',
                                  onPressed: () => NavigationHelper.launchNavigation(
                                    latitude: lat,
                                    longitude: lng,
                                    label: name,
                                  ),
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
                                  color: isActiveDest ? theme.colorScheme.primary : Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
                                child: Text(
                                  name,
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                isActiveDest ? Icons.stars_rounded : Icons.location_on_rounded,
                                color: isActiveDest ? theme.colorScheme.primary : Colors.red,
                                size: 36,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // B. Meeting Point Markers (🚩)
                    ...mapState.meetingPoints.values.map((point) {
                      final lat = (point['latitude'] as num).toDouble();
                      final lng = (point['longitude'] as num).toDouble();
                      final name = point['name'] as String? ?? 'Meeting Point';
                      final arrivedCount = (point['arrivedMembers'] as Map? ?? {}).length;

                      return Marker(
                        point: LatLng(lat, lng),
                        width: 90,
                        height: 80,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Rendezvous: $name ($arrivedCount arrived)'),
                                action: SnackBarAction(
                                  label: 'Navigate',
                                  onPressed: () => NavigationHelper.launchNavigation(
                                    latitude: lat,
                                    longitude: lng,
                                    label: name,
                                  ),
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
                                  color: Colors.orange.shade800,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
                                child: Text(
                                  '🚩 $name ($arrivedCount)',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.flag_rounded,
                                color: Colors.orange,
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                // 4. Member Markers
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
                      final isStale = !member.online || DateTime.now().difference(member.lastUpdated).inMinutes > 5;
                      final isPaused = member.sharingStatus == 'paused';
                      final isEmergency = member.isEmergency;

                      Color ringColor = vehicle.color;
                      if (isEmergency) ringColor = Colors.red;
                      if (isPaused) ringColor = Colors.amber;
                      if (isStale) ringColor = Colors.grey;

                      return Marker(
                        point: LatLng(member.latitude, member.longitude),
                        width: 58,
                        height: 58,
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
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: ringColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isEmergency ? Colors.red.withValues(alpha: 0.6) : Colors.black26,
                                      blurRadius: isEmergency ? 8 : 4,
                                      spreadRadius: isEmergency ? 2 : 0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isStale ? Colors.grey.shade300 : null,
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
                                    color: isEmergency
                                        ? Colors.red
                                        : (isPaused ? Colors.amber : (member.online ? Colors.green : Colors.grey)),
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

          // 5. Emergency SOS Banner across top if any active alert
          if (hasEmergency)
            Positioned(
              top: 70,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Card(
                  color: Colors.red.shade900,
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🚨 EMERGENCY SOS ACTIVE',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                '${mapState.sosAlerts.values.first['userName'] ?? "A member"} needs assistance!',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final alert = mapState.sosAlerts.values.first;
                            final lat = (alert['latitude'] as num).toDouble();
                            final lng = (alert['longitude'] as num).toDouble();
                            _mapController.move(LatLng(lat, lng), 15);
                            NavigationHelper.launchNavigation(latitude: lat, longitude: lng, label: 'Emergency Location');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red.shade900,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          child: const Text('Navigate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        if (mapState.sosAlerts.containsKey(user?.uid)) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.white),
                            tooltip: 'Clear My SOS',
                            onPressed: () => controller.resolveEmergencySOS(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 6. Top Bar: Compass, SOS Button, and Location Sharing Status
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Compass
                  FloatingActionButton.small(
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

                  Row(
                    children: [
                      // Emergency SOS Trigger Button
                      FloatingActionButton.small(
                        heroTag: 'sos_trigger_btn',
                        onPressed: () => _confirmTriggerSOS(context),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        tooltip: 'Emergency SOS',
                        child: const Text('SOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      const SizedBox(width: 8),

                      // Location Sharing Pill
                      GestureDetector(
                        onTap: () => _showLocationPrivacySheet(context),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: theme.cardColor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  trackingState.isTracking
                                      ? (trackingState.sharingStatus == 'paused'
                                          ? Icons.pause_circle_filled
                                          : Icons.location_on)
                                      : Icons.location_off,
                                  color: trackingState.isTracking
                                      ? (trackingState.sharingStatus == 'paused' ? Colors.amber.shade800 : Colors.green)
                                      : Colors.grey,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  trackingState.isTracking
                                      ? (trackingState.sharingStatus == 'paused' ? 'Sharing Paused' : 'Sharing Live')
                                      : 'Not Sharing',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: trackingState.isTracking
                                        ? (trackingState.sharingStatus == 'paused' ? Colors.amber.shade800 : Colors.green)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 7. Active Navigation Guidance Bar
          if (mapState.isNavigating && mapState.navigationRoute != null)
            Positioned(
              top: hasEmergency ? 140 : 80,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Card(
                  color: theme.colorScheme.primaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.directions_outlined),
                    title: const Text('Navigating convoy route...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

          // 8. Right-side Map Controls
          Positioned(
            right: 16,
            bottom: 270,
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
                  tooltip: 'Overview of all members & stops',
                  onPressed: () => _fitAllMembers(mapState.members),
                  backgroundColor: theme.cardColor,
                  child: const Icon(Icons.group_work_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'my_location_btn',
                  tooltip: 'Recenter on me',
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

          // 9. Multi-Tab Convoy & Stops Dashboard
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
