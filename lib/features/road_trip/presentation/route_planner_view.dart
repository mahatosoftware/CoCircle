import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/google_maps_config.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../live_map/presentation/live_map_tab.dart';
import '../../trips/presentation/trip_controller.dart';
import '../data/road_trip_repository.dart';
import '../domain/road_trip_route_model.dart';
import '../infrastructure/road_trip_routing_service.dart';
import 'road_trip_controller.dart';

class RoutePlannerView extends ConsumerStatefulWidget {
  final String tripId;

  const RoutePlannerView({super.key, required this.tripId});

  @override
  ConsumerState<RoutePlannerView> createState() => _RoutePlannerViewState();
}

class _RoutePlannerViewState extends ConsumerState<RoutePlannerView> {
  gmaps.GoogleMapController? _googleMapController;
  late final TextEditingController _originController;
  late final TextEditingController _destController;
  bool _showMap = true;
  bool _forceEmptyState = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController(text: 'Bengaluru');
    _destController = TextEditingController();
  }

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeAsync = ref.watch(roadTripRouteStreamProvider(widget.tripId));
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_forceEmptyState) {
      return _buildEmptyRouteState(context, tripAsync.asData?.value, isDark);
    }

    return routeAsync.when(
      data: (route) {
        if (route == null) {
          return _buildEmptyRouteState(context, tripAsync.asData?.value, isDark);
        }

        return Scaffold(
          backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Route Summary Header Card
                _buildRouteSummaryCard(context, route, isDark),

                // 2. Map Toggle & Preview
                if (_showMap) _buildMapPreview(context, route, isDark),

                // 3. Stops Section Header with Add Stop CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Route Stops (${route.stops.length + 2})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppPallete.navy,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _showMap ? Icons.map_rounded : Icons.map_outlined,
                              size: 20,
                              color: AppPallete.indigo,
                            ),
                            tooltip: _showMap ? 'Hide Map' : 'Show Map',
                            onPressed: () => setState(() => _showMap = !_showMap),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPallete.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () => _showAddStopDialog(context, route),
                            icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                            label: const Text('Add Stop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 4. Origin Card (Fixed Start)
                _buildEndpointTile(
                  title: 'Origin (Start)',
                  name: route.originName,
                  isOrigin: true,
                  isDark: isDark,
                  onEdit: () => _showEditEndpointDialog(context, route, isOrigin: true),
                ),

                // 5. Reorderable Intermediate Stops
                if (route.stops.isNotEmpty)
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: route.stops.length,
                    onReorder: (oldIdx, newIdx) {
                      ref.read(roadTripControllerProvider).reorderStops(widget.tripId, oldIdx, newIdx);
                    },
                    itemBuilder: (context, index) {
                      final stop = route.stops[index];
                      return _buildStopCard(context, stop, isDark, key: ValueKey(stop.id));
                    },
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppPallete.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppPallete.gray, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'No intermediate stops added yet. Tap "+ Add Stop" to include scenic view points, fuel stops, restaurants, or hotels along your route.',
                              style: TextStyle(fontSize: 12, color: AppPallete.gray),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 6. Destination Card (End)
                _buildEndpointTile(
                  title: 'Final Destination',
                  name: route.destinationName,
                  isOrigin: false,
                  isDark: isDark,
                  onEdit: () => _showEditEndpointDialog(context, route, isOrigin: false),
                ),

                if (route.returnDestinationName != null && route.returnDestinationName!.isNotEmpty)
                  _buildEndpointTile(
                    title: 'Return Destination',
                    name: route.returnDestinationName!,
                    isOrigin: false,
                    isDark: isDark,
                    onEdit: () {},
                  ),

                const SizedBox(height: 100), // Spacing for bottom floating bar
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: PrimaryButton(
              label: 'Open Complete Route in Google Maps',
              icon: Icons.navigation_rounded,
              height: 48,
              onPressed: () async {
                final success = await RoadTripRoutingService.launchMultiStopGoogleMaps(
                  originLat: route.originLat,
                  originLng: route.originLng,
                  destinationLat: route.destinationLat,
                  destinationLng: route.destinationLng,
                  waypoints: route.stops,
                  mode: route.travelMode,
                );
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open Google Maps. Please verify Google Maps or a browser is installed.'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Loading route planner...', style: TextStyle(color: AppPallete.gray)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _forceEmptyState = true),
                child: const Text('Start New Route'),
              ),
            ],
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
                const SizedBox(height: 12),
                const Text(
                  'Route Setup Needed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString().contains('permission-denied')
                      ? 'Cloud permissions error. Please ensure the latest firestore.rules are published in Firebase Console.'
                      : 'Could not load saved route: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppPallete.gray),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Set Up Route Now',
                  icon: Icons.add_road_rounded,
                  onPressed: () => setState(() => _forceEmptyState = true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteSummaryCard(BuildContext context, RoadTripRouteModel route, bool isDark) {
    final hours = route.estimatedDurationMinutes ~/ 60;
    final mins = route.estimatedDurationMinutes % 60;
    final durationText = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppPallete.indigo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.route_rounded, color: AppPallete.indigo, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${route.originName} ➔ ${route.destinationName}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppPallete.navy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mode: ${route.travelMode.name.toUpperCase()} • Multi-Stop Convoy',
                      style: const TextStyle(fontSize: 11, color: AppPallete.gray),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMetricPill(
                label: 'TOTAL DISTANCE',
                value: '${route.totalDistanceKm.toStringAsFixed(0)} km',
                color: AppPallete.indigo,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildMetricPill(
                label: 'EST. TRAVEL TIME',
                value: durationText,
                color: AppPallete.teal,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildMetricPill(
                label: 'TOTAL STOPS',
                value: '${route.stops.length + 2}',
                color: const Color(0xFFF59E0B),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppPallete.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context, RoadTripRouteModel route, bool isDark) {
    final origin = gmaps.LatLng(route.originLat, route.originLng);
    final destination = gmaps.LatLng(route.destinationLat, route.destinationLng);

    final googleMarkers = <gmaps.Marker>{
      // Origin marker (Green)
      gmaps.Marker(
        markerId: const gmaps.MarkerId('origin'),
        position: origin,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueGreen),
        infoWindow: gmaps.InfoWindow(title: 'Origin: ${route.originName}'),
      ),
      // Intermediate stops (Azure / Yellow)
      for (final s in route.stops)
        gmaps.Marker(
          markerId: gmaps.MarkerId('stop_${s.id}'),
          position: gmaps.LatLng(s.latitude, s.longitude),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            s.isVisited ? gmaps.BitmapDescriptor.hueYellow : gmaps.BitmapDescriptor.hueAzure,
          ),
          infoWindow: gmaps.InfoWindow(
            title: '${s.sequence}. ${s.name}',
            snippet: s.address,
          ),
        ),
      // Destination marker (Red)
      gmaps.Marker(
        markerId: const gmaps.MarkerId('destination'),
        position: destination,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
        infoWindow: gmaps.InfoWindow(title: 'Destination: ${route.destinationName}'),
      ),
    };

    final polylinePoints = <gmaps.LatLng>[
      origin,
      ...route.stops.map((s) => gmaps.LatLng(s.latitude, s.longitude)),
      destination,
    ];

    final polylines = <gmaps.Polyline>{
      gmaps.Polyline(
        polylineId: const gmaps.PolylineId('road_trip_route_line'),
        points: polylinePoints,
        color: AppPallete.indigo,
        width: 5,
      ),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: gmaps.GoogleMap(
        initialCameraPosition: gmaps.CameraPosition(
          target: origin,
          zoom: 8.5,
        ),
        markers: googleMarkers,
        polylines: polylines,
        style: GoogleMapsConfig.getMapStyle(isDark),
        onMapCreated: (controller) {
          _googleMapController = controller;
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
      ),
    );
  }

  Widget _buildEndpointTile({
    required String title,
    required String name,
    required bool isOrigin,
    required bool isDark,
    required VoidCallback onEdit,
  }) {
    final color = isOrigin ? const Color(0xFF10B981) : const Color(0xFFDC2626);
    final icon = isOrigin ? Icons.trip_origin_rounded : Icons.location_on_rounded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppPallete.navy,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppPallete.gray),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildStopCard(BuildContext context, RouteStopModel stop, bool isDark, {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stop.isVisited
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_indicator_rounded, color: AppPallete.gray, size: 20),
            const SizedBox(width: 6),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: stop.isVisited ? const Color(0xFF10B981) : AppPallete.indigo,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${stop.sequence}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                stop.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppPallete.navy,
                  decoration: stop.isVisited ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (stop.isOptional) StatusBadge.neutral(label: 'Optional'),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              _buildStopTypeBadge(stop.stopType),
              const SizedBox(width: 6),
              Text(
                'Day ${stop.dayNumber} • ${stop.estimatedDurationMinutes}m',
                style: const TextStyle(fontSize: 11, color: AppPallete.gray),
              ),
              if (stop.estimatedCost > 0) ...[
                const SizedBox(width: 6),
                Text('• ₹${stop.estimatedCost.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppPallete.gray),
          onSelected: (val) {
            if (val == 'toggle_visited') {
              ref.read(roadTripControllerProvider).updateStop(
                    widget.tripId,
                    stop.copyWith(isVisited: !stop.isVisited),
                  );
            } else if (val == 'delete') {
              ref.read(roadTripControllerProvider).removeStop(widget.tripId, stop.id);
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'toggle_visited',
              child: Text(stop.isVisited ? 'Mark Unvisited' : 'Mark Visited'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete Stop', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopTypeBadge(StopType type) {
    IconData icon;
    Color color;
    switch (type) {
      case StopType.fuel:
        icon = Icons.local_gas_station_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case StopType.meal:
        icon = Icons.restaurant_rounded;
        color = const Color(0xFFEF4444);
        break;
      case StopType.attraction:
        icon = Icons.attractions_rounded;
        color = AppPallete.indigo;
        break;
      case StopType.stay:
        icon = Icons.hotel_rounded;
        color = const Color(0xFF8B5CF6);
        break;
      default:
        icon = Icons.place_rounded;
        color = AppPallete.teal;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(type.name.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildEmptyRouteState(BuildContext context, dynamic trip, bool isDark) {
    if (_destController.text.isEmpty && trip?.location != null && trip!.location!.toString().trim().isNotEmpty) {
      _destController.text = trip!.location!.toString().trim();
    } else if (_destController.text.isEmpty) {
      _destController.text = 'Mysuru';
    }

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppPallete.indigo.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_road_rounded, color: AppPallete.indigo, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Plan Multi-Stop Road Trip',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Define your starting location and destination to begin adding waypoints, fuel stops, and calculating distances.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppPallete.gray),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _originController,
                decoration: const InputDecoration(
                  labelText: 'Starting Location (Origin)',
                  prefixIcon: Icon(Icons.trip_origin_rounded, color: Color(0xFF10B981)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _destController,
                decoration: const InputDecoration(
                  labelText: 'Final Destination',
                  prefixIcon: Icon(Icons.location_on_rounded, color: Color(0xFFDC2626)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _isInitializing
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      label: 'Initialize Route & Compute Distance',
                      icon: Icons.check_rounded,
                      width: double.infinity,
                      onPressed: () async {
                        final orig = _originController.text.trim();
                        final dest = _destController.text.trim();
                        if (orig.isEmpty || dest.isEmpty) return;

                        setState(() => _isInitializing = true);
                        try {
                          await ref.read(roadTripControllerProvider).initializeRoute(
                                tripId: widget.tripId,
                                originName: orig,
                                originLat: 12.9716,
                                originLng: 77.5946,
                                destinationName: dest,
                                destinationLat: 12.2958,
                                destinationLng: 76.6394,
                              );
                          if (mounted) {
                            setState(() => _forceEmptyState = false);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error saving route: $e'),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isInitializing = false);
                          }
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddStopDialog(BuildContext context, RoadTripRouteModel route) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final costController = TextEditingController(text: '0');
    final durationController = TextEditingController(text: '45');
    StopType selectedType = StopType.attraction;
    int selectedDay = 1;
    bool isOptional = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Add Intermediate Route Stop', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Stop Name (e.g. Abbey Falls, Mysore Palace)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address / Landmark (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<StopType>(
                            isExpanded: true,
                            initialValue: selectedType,
                            decoration: const InputDecoration(labelText: 'Stop Type', border: OutlineInputBorder()),
                            items: StopType.values
                                .map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase(), overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setSheetState(() => selectedType = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            isExpanded: true,
                            initialValue: selectedDay,
                            decoration: const InputDecoration(labelText: 'Itinerary Day', border: OutlineInputBorder()),
                            items: [1, 2, 3, 4, 5, 6, 7]
                                .map((d) => DropdownMenuItem(value: d, child: Text('Day $d', overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setSheetState(() => selectedDay = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Duration (Mins)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: costController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Estimated Cost (₹)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mark as Optional Stop', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      value: isOptional,
                      activeThumbColor: AppPallete.indigo,
                      onChanged: (val) => setSheetState(() => isOptional = val),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Save Stop',
                      width: double.infinity,
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;

                        // Approximate offset coordinate for simulation
                        final offset = (route.stops.length + 1) * 0.05;
                        final stop = RouteStopModel(
                          id: const Uuid().v4(),
                          tripId: widget.tripId,
                          name: name,
                          address: addressController.text.trim(),
                          latitude: route.originLat + offset,
                          longitude: route.originLng - offset,
                          sequence: route.stops.length + 1,
                          dayNumber: selectedDay,
                          stopType: selectedType,
                          estimatedDurationMinutes: int.tryParse(durationController.text) ?? 45,
                          estimatedCost: double.tryParse(costController.text) ?? 0.0,
                          isOptional: isOptional,
                          createdBy: 'organizer',
                          createdAt: DateTime.now(),
                        );

                        Navigator.pop(ctx);
                        ref.read(roadTripControllerProvider).addStop(widget.tripId, stop);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditEndpointDialog(BuildContext context, RoadTripRouteModel route, {required bool isOrigin}) {
    final controller = TextEditingController(text: isOrigin ? route.originName : route.destinationName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isOrigin ? 'Edit Origin (Start)' : 'Edit Destination'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Place Name / City', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final updated = isOrigin
                    ? route.copyWith(originName: newName)
                    : route.copyWith(destinationName: newName);
                ref.read(roadTripRepositoryProvider).saveRoute(updated);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
