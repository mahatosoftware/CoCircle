import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/map_tile_config.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../live_map/presentation/live_map_tab.dart';
import '../../trips/data/trip_planner_repository_impl.dart';
import '../../trips/domain/itinerary_item_model.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../trips/presentation/trip_planner_controller.dart';
import '../domain/road_trip_route_model.dart';
import 'road_trip_controller.dart';

class DayWiseItineraryView extends ConsumerStatefulWidget {
  final String tripId;

  const DayWiseItineraryView({super.key, required this.tripId});

  @override
  ConsumerState<DayWiseItineraryView> createState() => _DayWiseItineraryViewState();
}

class _DayWiseItineraryViewState extends ConsumerState<DayWiseItineraryView> {
  int _selectedDay = 1;
  int _viewMode = 0; // 0: Timeline, 1: Map View, 2: Day Summary
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final itineraryAsync = ref.watch(tripItineraryProvider(widget.tripId));
    final routeAsync = ref.watch(roadTripRouteStreamProvider(widget.tripId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final trip = tripAsync.asData?.value;
    final allItems = itineraryAsync.asData?.value ?? [];
    final route = routeAsync.asData?.value;

    // Determine total days from trip dates
    int totalDays = 3;
    if (trip?.startDate != null && trip?.endDate != null) {
      final diff = trip!.endDate!.difference(trip.startDate!).inDays + 1;
      if (diff > 0) totalDays = diff.clamp(1, 14);
    }

    // Filter items for selected day
    final dayItems = allItems.where((it) {
      // Either dayNumber matches, or item's startTime date matches trip.startDate + day
      if (it.dayNumber == _selectedDay) return true;
      if (trip?.startDate != null) {
        final expectedDate = trip!.startDate!.add(Duration(days: _selectedDay - 1));
        return it.startTime.year == expectedDate.year &&
            it.startTime.month == expectedDate.month &&
            it.startTime.day == expectedDate.day;
      }
      return false;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      body: Column(
        children: [
          // 1. Day Selector Tabs (Day 1, Day 2, Day 3...)
          Container(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(totalDays, (index) {
                  final dayNum = index + 1;
                  final isSelected = _selectedDay == dayNum;
                  String dateSub = '';
                  if (trip?.startDate != null) {
                    final d = trip!.startDate!.add(Duration(days: index));
                    dateSub = DateFormat('d MMM').format(d);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedDay = dayNum);
                      },
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Day $dayNum', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          if (dateSub.isNotEmpty)
                            Text(dateSub, style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                      selectedColor: AppPallete.indigo,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.white : AppPallete.navy),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // 2. View Mode Switcher & Add Activity CTA
          Container(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Segment switcher (Timeline, Map, Summary)
                Row(
                  children: [
                    _buildModeIcon(0, Icons.timeline_rounded, 'Timeline', isDark),
                    const SizedBox(width: 4),
                    _buildModeIcon(1, Icons.map_rounded, 'Map', isDark),
                    const SizedBox(width: 4),
                    _buildModeIcon(2, Icons.analytics_outlined, 'Summary', isDark),
                  ],
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => _showActivitySheet(context, trip: trip, route: route),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),

          // 3. Main Content
          Expanded(
            child: _viewMode == 0
                ? _buildTimelineView(context, dayItems, trip, route, isDark)
                : (_viewMode == 1
                    ? _buildDayMapView(context, dayItems, route, isDark)
                    : _buildDaySummaryView(context, dayItems, isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildModeIcon(int mode, IconData icon, String tooltip, bool isDark) {
    final isSelected = _viewMode == mode;
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      color: isSelected ? AppPallete.indigo : AppPallete.gray,
      style: IconButton.styleFrom(
        backgroundColor: isSelected
            ? AppPallete.indigo.withValues(alpha: 0.12)
            : Colors.transparent,
      ),
      onPressed: () => setState(() => _viewMode = mode),
    );
  }

  Widget _buildTimelineView(
    BuildContext context,
    List<ItineraryItemModel> items,
    dynamic trip,
    RoadTripRouteModel? route,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppPallete.indigo.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.explore_outlined, color: AppPallete.indigo, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                'No Activities for Day $_selectedDay',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap "+ Add Activity" to schedule sightseeing, restaurants, rest breaks, or fuel stops.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppPallete.gray),
              ),
            ],
          ),
        ),
      );
    }

    final timeFmt = DateFormat('hh:mm a');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final it = items[index];

        String timeStr;
        if (it.hasStartTime) {
          final startFormatted = timeFmt.format(it.startTime);
          if (it.endTime != null) {
            timeStr = '$startFormatted - ${timeFmt.format(it.endTime!)}';
          } else {
            timeStr = startFormatted;
          }
        } else {
          if (it.endTime != null) {
            timeStr = 'Until ${timeFmt.format(it.endTime!)}';
          } else {
            timeStr = 'Flexible time';
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppPallete.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: it.isCompleted
                    ? const Color(0xFF10B981).withValues(alpha: 0.4)
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showActivitySheet(context, trip: trip, route: route, existingItem: it),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(it.category).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_getCategoryIcon(it.category), color: _getCategoryColor(it.category), size: 20),
                      ),
                      const SizedBox(width: 12),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    it.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppPallete.navy,
                                      decoration: it.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: it.hasStartTime
                                        ? AppPallete.indigo.withValues(alpha: 0.08)
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    timeStr,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: it.hasStartTime ? AppPallete.indigo : AppPallete.gray,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (it.location != null && it.location!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.place_rounded, size: 12, color: AppPallete.gray),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      it.location!,
                                      style: const TextStyle(fontSize: 11, color: AppPallete.gray),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(it.category).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    it.category.toUpperCase(),
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getCategoryColor(it.category)),
                                  ),
                                ),
                                if (it.cost != null && it.cost! > 0) ...[
                                  const SizedBox(width: 8),
                                  Text('₹${it.cost!.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                ],
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppPallete.primary),
                                  tooltip: 'Edit Activity',
                                  onPressed: () => _showActivitySheet(context, trip: trip, route: route, existingItem: it),
                                ),
                                IconButton(
                                  icon: Icon(
                                    it.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    size: 18,
                                    color: it.isCompleted ? const Color(0xFF10B981) : AppPallete.gray,
                                  ),
                                  tooltip: it.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
                                  onPressed: () {
                                    final updated = it.copyWith(isCompleted: !it.isCompleted);
                                    ref.read(tripPlannerRepositoryProvider).updateItineraryItem(updated);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                  tooltip: 'Delete Activity',
                                  onPressed: () {
                                    ref.read(tripPlannerRepositoryProvider).deleteItineraryItem(it.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayMapView(BuildContext context, List<ItineraryItemModel> items, RoadTripRouteModel? route, bool isDark) {
    final tileProviderAsync = ref.watch(mapTileProviderProvider);

    final markers = <Marker>[];
    for (final it in items) {
      if (it.latitude != null && it.longitude != null) {
        markers.add(
          Marker(
            point: LatLng(it.latitude!, it.longitude!),
            width: 34,
            height: 34,
            child: Container(
              decoration: BoxDecoration(
                color: _getCategoryColor(it.category),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Icon(_getCategoryIcon(it.category), color: Colors.white, size: 16),
            ),
          ),
        );
      }
    }

    // Default center
    final center = markers.isNotEmpty
        ? markers.first.point
        : LatLng(route?.originLat ?? 12.9716, route?.originLng ?? 77.5946);

    return tileProviderAsync.when(
      data: (tileProvider) => FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 11.0,
        ),
        children: [
          TileLayer(
            urlTemplate: MapTileConfig.getUrlTemplate(isDark: isDark),
            subdomains: MapTileConfig.subdomains,
            userAgentPackageName: MapTileConfig.userAgentPackageName,
            tileProvider: tileProvider,
            tileBuilder: MapTileConfig.getTileBuilder(isDark: isDark),
          ),
          MarkerLayer(markers: markers),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Map tile error: $e')),
    );
  }

  Widget _buildDaySummaryView(BuildContext context, List<ItineraryItemModel> items, bool isDark) {
    double totalCost = 0.0;
    for (final it in items) {
      if (it.cost != null) totalCost += it.cost!;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppPallete.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Day $_selectedDay Overview', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMetricItem('ACTIVITIES', '${items.length}', AppPallete.indigo),
                    _buildMetricItem('EST. DAY COST', '₹${totalCost.toStringAsFixed(0)}', const Color(0xFF10B981)),
                    _buildMetricItem('COMPLETED', '${items.where((i) => i.isCompleted).length}/${items.length}', AppPallete.teal),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('travel') || c.contains('transit')) return Icons.flight_takeoff_rounded;
    if (c.contains('food') || c.contains('dining') || c.contains('breakfast') || c.contains('lunch') || c.contains('dinner')) return Icons.restaurant_rounded;
    if (c.contains('sightseeing') || c.contains('attraction')) return Icons.photo_camera_rounded;
    if (c.contains('stay') || c.contains('hotel')) return Icons.hotel_rounded;
    if (c.contains('fuel')) return Icons.local_gas_station_rounded;
    if (c.contains('adventure')) return Icons.terrain_rounded;
    return Icons.explore_rounded;
  }

  Color _getCategoryColor(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('travel')) return Colors.blue;
    if (c.contains('food')) return Colors.redAccent;
    if (c.contains('sightseeing')) return AppPallete.teal;
    if (c.contains('stay')) return Colors.orange;
    if (c.contains('fuel')) return const Color(0xFFF59E0B);
    return AppPallete.indigo;
  }

  void _showActivitySheet(
    BuildContext context, {
    required dynamic trip,
    required RoadTripRouteModel? route,
    ItineraryItemModel? existingItem,
  }) {
    final isEditing = existingItem != null;
    final titleController = TextEditingController(text: existingItem?.title ?? '');
    final locationController = TextEditingController(text: existingItem?.location ?? '');
    final costController = TextEditingController(
      text: existingItem?.cost != null && existingItem!.cost! > 0
          ? existingItem.cost!.toStringAsFixed(0)
          : '',
    );
    final notesController = TextEditingController(text: existingItem?.notes ?? '');

    String selectedCategory = existingItem?.category ?? 'sightseeing';
    String? selectedStopId = existingItem?.stopId;
    int selectedDay = existingItem?.dayNumber ?? _selectedDay;

    TimeOfDay? selectedStartTime = (existingItem != null && existingItem.hasStartTime)
        ? TimeOfDay.fromDateTime(existingItem.startTime)
        : null;
    TimeOfDay? selectedEndTime = existingItem?.endTime != null
        ? TimeOfDay.fromDateTime(existingItem!.endTime!)
        : null;

    int totalDays = 3;
    if (trip?.startDate != null && trip?.endDate != null) {
      final diff = trip!.endDate!.difference(trip.startDate!).inDays + 1;
      if (diff > 0) totalDays = diff.clamp(1, 14);
    }
    if (selectedDay > totalDays) totalDays = selectedDay;

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Activity' : 'Add Activity for Day $selectedDay',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (isEditing)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppPallete.indigo.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Editing',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppPallete.indigo,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Option to link from route stops
                    if (route != null && route.stops.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedStopId,
                        decoration: const InputDecoration(
                          labelText: 'Link from Route Stop (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('None (Custom Activity)', overflow: TextOverflow.ellipsis),
                          ),
                          ...route.stops.map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text('${s.sequence}. ${s.name}', overflow: TextOverflow.ellipsis),
                              )),
                        ],
                        onChanged: (val) {
                          setSheetState(() {
                            selectedStopId = val;
                            if (val != null) {
                              final stop = route.stops.firstWhere((s) => s.id == val);
                              titleController.text = stop.name;
                              locationController.text = stop.address ?? stop.name;
                              costController.text = stop.estimatedCost.toStringAsFixed(0);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Activity Title *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Location / Landmark', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            isExpanded: true,
                            initialValue: selectedDay,
                            decoration: const InputDecoration(labelText: 'Day', border: OutlineInputBorder()),
                            items: List.generate(
                              totalDays,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('Day ${i + 1}', overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            onChanged: (val) {
                              if (val != null) setSheetState(() => selectedDay = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: selectedCategory,
                            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'sightseeing', child: Text('Sightseeing', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'dining', child: Text('Restaurant / Dining', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'travel', child: Text('Travel / Transit', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'lodging', child: Text('Hotel / Stay', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'fuel', child: Text('Fuel / EV', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'adventure', child: Text('Adventure', overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: (val) {
                              if (val != null) setSheetState(() => selectedCategory = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Start Time & End Time pickers (Optional)
                    Row(
                      children: [
                        // Start Time
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedStartTime ?? const TimeOfDay(hour: 10, minute: 0),
                              );
                              if (picked != null) {
                                setSheetState(() => selectedStartTime = picked);
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Start Time (Opt)',
                                border: const OutlineInputBorder(),
                                suffixIcon: selectedStartTime != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 16),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => setSheetState(() => selectedStartTime = null),
                                      )
                                    : const Icon(Icons.access_time_rounded, size: 18),
                              ),
                              child: Text(
                                selectedStartTime != null
                                    ? selectedStartTime!.format(context)
                                    : 'Not set (Flexible)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: selectedStartTime != null
                                      ? (isDark ? Colors.white : AppPallete.navy)
                                      : AppPallete.gray,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // End Time
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final initial = selectedEndTime ??
                                  (selectedStartTime != null
                                      ? TimeOfDay(
                                          hour: (selectedStartTime!.hour + 1) % 24,
                                          minute: selectedStartTime!.minute,
                                        )
                                      : const TimeOfDay(hour: 12, minute: 0));
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: initial,
                              );
                              if (picked != null) {
                                setSheetState(() => selectedEndTime = picked);
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Time (Opt)',
                                border: const OutlineInputBorder(),
                                suffixIcon: selectedEndTime != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 16),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => setSheetState(() => selectedEndTime = null),
                                      )
                                    : const Icon(Icons.access_time_filled_rounded, size: 18),
                              ),
                              child: Text(
                                selectedEndTime != null
                                    ? selectedEndTime!.format(context)
                                    : 'Not set',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: selectedEndTime != null
                                      ? (isDark ? Colors.white : AppPallete.navy)
                                      : AppPallete.gray,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: costController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Est. Cost (₹, optional)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes / Tips (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    PrimaryButton(
                      label: isEditing ? 'Save Changes' : 'Add Activity to Itinerary',
                      width: double.infinity,
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        final user = await ref.read(authRepositoryProvider).getCurrentUser();
                        final baseDate = trip?.startDate != null
                            ? trip!.startDate!.add(Duration(days: selectedDay - 1))
                            : DateTime.now();

                        final bool hasStartTime = selectedStartTime != null;
                        final DateTime startTime;
                        if (hasStartTime) {
                          startTime = DateTime(
                            baseDate.year,
                            baseDate.month,
                            baseDate.day,
                            selectedStartTime!.hour,
                            selectedStartTime!.minute,
                          );
                        } else {
                          startTime = DateTime(baseDate.year, baseDate.month, baseDate.day, 10, 0);
                        }

                        final DateTime? endTime;
                        if (selectedEndTime != null) {
                          endTime = DateTime(
                            baseDate.year,
                            baseDate.month,
                            baseDate.day,
                            selectedEndTime!.hour,
                            selectedEndTime!.minute,
                          );
                        } else {
                          endTime = null;
                        }

                        if (isEditing) {
                          final updated = existingItem.copyWith(
                            title: title,
                            type: selectedCategory,
                            category: selectedCategory,
                            location: locationController.text.trim(),
                            cost: double.tryParse(costController.text) ?? 0.0,
                            dayNumber: selectedDay,
                            stopId: selectedStopId,
                            startTime: startTime,
                            endTime: endTime,
                            clearEndTime: endTime == null,
                            hasStartTime: hasStartTime,
                            notes: notesController.text.trim(),
                          );
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                          await ref.read(tripPlannerRepositoryProvider).updateItineraryItem(updated);
                        } else {
                          final item = ItineraryItemModel(
                            id: const Uuid().v4(),
                            tripId: widget.tripId,
                            title: title,
                            type: selectedCategory,
                            category: selectedCategory,
                            location: locationController.text.trim(),
                            cost: double.tryParse(costController.text) ?? 0.0,
                            dayNumber: selectedDay,
                            stopId: selectedStopId,
                            startTime: startTime,
                            endTime: endTime,
                            hasStartTime: hasStartTime,
                            notes: notesController.text.trim(),
                            createdBy: user?.uid ?? 'organizer',
                            createdAt: DateTime.now(),
                          );

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                          await ref.read(tripPlannerRepositoryProvider).createItineraryItem(item);
                        }
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
}
