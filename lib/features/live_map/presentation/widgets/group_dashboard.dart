import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../auth/data/auth_repository_impl.dart';
import '../live_map_controller.dart';
import '../../../tracking/application/tracking_notifier.dart';
import '../../domain/member_location_model.dart';
import 'member_bottom_sheet.dart';

enum DashboardSort { distance, eta, vehicle }

class GroupDashboard extends ConsumerStatefulWidget {
  final String tripId;
  final MemberLocationModel? currentUserLocation;

  const GroupDashboard({
    super.key,
    required this.tripId,
    required this.currentUserLocation,
  });

  @override
  ConsumerState<GroupDashboard> createState() => _GroupDashboardState();
}

class _GroupDashboardState extends ConsumerState<GroupDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DashboardSort _sortBy = DashboardSort.distance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(liveMapControllerProvider(widget.tripId));
    final controller = ref.read(liveMapControllerProvider(widget.tripId).notifier);
    final theme = Theme.of(context);

    // 1. Calculate & sort member list
    final List<Map<String, dynamic>> processedList = mapState.members.map((member) {
      double distance = 0.0;
      if (widget.currentUserLocation != null) {
        distance = Geolocator.distanceBetween(
          widget.currentUserLocation!.latitude,
          widget.currentUserLocation!.longitude,
          member.latitude,
          member.longitude,
        );
      }

      double etaSeconds = double.infinity;
      final routeDetails = mapState.routes[member.userId];
      if (routeDetails != null && routeDetails['duration'] != null) {
        etaSeconds = (routeDetails['duration'] as num).toDouble();
      }

      String status = 'En route';
      if (member.isEmergency) {
        status = '🚨 SOS';
      } else if (member.sharingStatus == 'paused') {
        status = 'Paused';
      } else if (!member.online || DateTime.now().difference(member.lastUpdated).inMinutes > 5) {
        status = 'Offline';
      } else {
        final activeDestId = mapState.activeDestinationId;
        if (activeDestId != null) {
          final dest = mapState.destinations[activeDestId];
          if (dest != null) {
            final destLat = dest['latitude'] as double;
            final destLng = dest['longitude'] as double;
            final destDist = Geolocator.distanceBetween(
              member.latitude,
              member.longitude,
              destLat,
              destLng,
            );
            if (destDist <= 75.0) {
              status = 'Arrived';
            }
          }
        }
      }

      return {
        'member': member,
        'distance': distance,
        'eta': etaSeconds,
        'status': status,
      };
    }).toList();

    processedList.sort((a, b) {
      if (_sortBy == DashboardSort.distance) {
        return (a['distance'] as double).compareTo(b['distance'] as double);
      } else if (_sortBy == DashboardSort.eta) {
        return (a['eta'] as double).compareTo(b['eta'] as double);
      } else {
        final memberA = a['member'] as MemberLocationModel;
        final memberB = b['member'] as MemberLocationModel;
        return (memberA.vehicleId ?? '').compareTo(memberB.vehicleId ?? '');
      }
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      maxChildSize: 0.88,
      minChildSize: 0.14,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Pull Bar
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Tab Bar Header
              TabBar(
                controller: _tabController,
                isScrollable: false,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: theme.colorScheme.primary,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.people_alt_rounded, size: 20),
                    text: 'Members (${mapState.members.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.directions_car_filled_rounded, size: 20),
                    text: 'Convoy',
                  ),
                  Tab(
                    icon: const Icon(Icons.flag_rounded, size: 20),
                    text: 'Stops (${mapState.destinations.length + mapState.meetingPoints.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.notifications_active_rounded, size: 20),
                    text: 'Alerts',
                  ),
                ],
              ),
              // Group ETA Header
        Builder(builder: (context) {
          final validEtas = processedList
              .map((p) => p['eta'] as double)
              .where((e) => e != double.infinity && e > 0)
              .toList();
          if (validEtas.isEmpty) return const SizedBox.shrink();
          final double avgEta = validEtas.reduce((a, b) => a + b) / validEtas.length;

          return Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.navigation_rounded, size: 16, color: Color(0xFF4F46E5)),
                const SizedBox(width: 8),
                Text(
                  'Group Convoy ETA: ${_formatDuration(avgEta)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3730A3)),
                ),
                const Spacer(),
                const Text(
                  'All Connected',
                  style: TextStyle(fontSize: 11, color: Color(0xFF4F46E5), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }),
        const Divider(height: 1),

              // Tab Content Area
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // --- TAB 1: MEMBERS LIST ---
                    _buildMembersTab(context, scrollController, processedList, controller),

                    // --- TAB 2: CONVOY / VEHICLES ---
                    _buildConvoyTab(context, scrollController, mapState, controller),

                    // --- TAB 3: STOPS & MEETING POINTS ---
                    _buildStopsTab(context, scrollController, mapState, controller),

                    // --- TAB 4: ALERTS FEED ---
                    _buildAlertsTab(context, scrollController, mapState),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 1: MEMBERS ---
  Widget _buildMembersTab(
    BuildContext context,
    ScrollController scrollController,
    List<Map<String, dynamic>> processedList,
    LiveMapController controller,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Sorting and Vehicle Selector bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Sort by: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  DropdownButton<DashboardSort>(
                    value: _sortBy,
                    underline: const SizedBox(),
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    items: const [
                      DropdownMenuItem(value: DashboardSort.distance, child: Text('Distance')),
                      DropdownMenuItem(value: DashboardSort.eta, child: Text('ETA')),
                      DropdownMenuItem(value: DashboardSort.vehicle, child: Text('Vehicle')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _sortBy = val);
                    },
                  ),
                ],
              ),
              if (widget.currentUserLocation != null)
                Text(
                  'My Speed: ${(widget.currentUserLocation!.speed * 3.6).toStringAsFixed(0)} km/h',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: processedList.isEmpty
              ? const Center(
                  child: Text(
                    'No members are currently sharing their location.\nToggle "Share Live" to begin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  itemCount: processedList.length,
                  itemBuilder: (context, index) {
                    final item = processedList[index];
                    final MemberLocationModel member = item['member'] as MemberLocationModel;
                    final double dist = item['distance'] as double;
                    final double eta = item['eta'] as double;
                    final String status = item['status'] as String;
                    final vehicle = VehicleConfig.getById(member.vehicleId);

                    Color statusColor = Colors.orange;
                    if (status == 'Arrived') statusColor = Colors.green;
                    if (status == 'Offline') statusColor = Colors.grey;
                    if (status == '🚨 SOS') statusColor = Colors.red;

                    final diff = DateTime.now().difference(member.lastUpdated);
                    String freshnessText;
                    Color freshnessColor;
                    if (diff.inSeconds < 45) {
                      freshnessText = 'Live (${diff.inSeconds}s ago)';
                      freshnessColor = const Color(0xFF10B981);
                    } else if (diff.inMinutes < 5) {
                      freshnessText = '${diff.inMinutes}m ago';
                      freshnessColor = const Color(0xFFF59E0B);
                    } else if (diff.inMinutes < 30) {
                      freshnessText = 'Stale (${diff.inMinutes}m ago)';
                      freshnessColor = Colors.orange;
                    } else {
                      freshnessText = 'Offline';
                      freshnessColor = Colors.grey;
                    }

                    return ListTile(
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
                            currentUserLocation: widget.currentUserLocation?.userId.isNotEmpty == true
                                ? widget.currentUserLocation
                                : null,
                          ),
                        );
                      },
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: vehicle.color,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundImage: member.photoUrl != null && member.photoUrl!.isNotEmpty
                                  ? NetworkImage(member.photoUrl!)
                                  : null,
                              child: member.photoUrl == null || member.photoUrl!.isEmpty
                                  ? Text(
                                      member.name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: member.online ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              member.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (member.battery != null) ...[
                            Icon(
                              member.battery! <= 20 ? Icons.battery_alert_rounded : Icons.battery_std_rounded,
                              size: 13,
                              color: member.battery! <= 20 ? Colors.red : Colors.grey,
                            ),
                            Text(
                              '${member.battery}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: member.battery! <= 20 ? Colors.red : Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(vehicle.icon, size: 12, color: vehicle.color),
                              const SizedBox(width: 4),
                              Text(
                                member.vehicleName ?? vehicle.name,
                                style: TextStyle(fontSize: 11, color: vehicle.color, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•  ${_formatDistance(dist)} away',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: freshnessColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                freshnessText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: freshnessColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (eta != double.infinity)
                            Text(
                              'ETA: ${_formatDuration(eta)}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- TAB 2: CONVOY / MULTIPLE VEHICLES ---
  Widget _buildConvoyTab(
    BuildContext context,
    ScrollController scrollController,
    LiveMapState mapState,
    LiveMapController controller,
  ) {
    final theme = Theme.of(context);

    // Group members by vehicle
    final Map<String, List<MemberLocationModel>> vehicleGroups = {};
    for (final member in mapState.members) {
      final vId = member.vehicleId ?? 'default';
      vehicleGroups.putIfAbsent(vId, () => []).add(member);
    }

    final myVehicleId = widget.currentUserLocation?.vehicleId ?? 'default';

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Convoy Vehicles',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddVehicleDialog(context, controller),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Vehicle'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...VehicleConfig.list.map((v) {
          final passengers = vehicleGroups[v.id] ?? [];
          final isMyVehicle = myVehicleId == v.id;

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isMyVehicle ? v.color : Colors.transparent,
                width: isMyVehicle ? 2 : 0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: v.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(v.icon, color: v.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  v.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                if (isMyVehicle) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.green.shade300),
                                    ),
                                    child: const Text(
                                      'My Car',
                                      style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              '${passengers.length} member${passengers.length == 1 ? '' : 's'} on board',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (!isMyVehicle)
                        OutlinedButton(
                          onPressed: () {
                            ref.read(trackingProvider.notifier).updateVehicleAssignment(v.id, vehicleName: v.name);
                            controller.joinVehicle(v.id, v.name);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Switched to ${v.name}')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          child: const Text('Join Car', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  if (passengers.isNotEmpty) ...[
                    const Divider(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: passengers.map((p) {
                        return Chip(
                          avatar: CircleAvatar(
                            radius: 10,
                            backgroundImage: p.photoUrl != null && p.photoUrl!.isNotEmpty
                                ? NetworkImage(p.photoUrl!)
                                : null,
                            child: p.photoUrl == null || p.photoUrl!.isEmpty
                                ? Text(p.name.substring(0, 1), style: const TextStyle(fontSize: 10))
                                : null,
                          ),
                          label: Text(p.name, style: const TextStyle(fontSize: 11)),
                          backgroundColor: theme.cardColor,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- TAB 3: STOPS & MEETING POINTS ---
  Widget _buildStopsTab(
    BuildContext context,
    ScrollController scrollController,
    LiveMapState mapState,
    LiveMapController controller,
  ) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateChangesProvider).value;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Destinations section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trip Destinations',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_location_alt_outlined),
              tooltip: 'Add Stop',
              onPressed: () => _showAddStopDialog(context, controller),
            ),
          ],
        ),

        if (mapState.destinations.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No destinations set yet. Tap + to add the trip destination.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          )
        else
          ...mapState.destinations.entries.map((entry) {
            final destId = entry.key;
            final dest = entry.value;
            final name = dest['name'] as String? ?? 'Destination';
            final lat = (dest['latitude'] as num).toDouble();
            final lng = (dest['longitude'] as num).toDouble();
            final isActive = mapState.activeDestinationId == destId;

            return Card(
              elevation: isActive ? 2 : 1,
              margin: const EdgeInsets.only(bottom: 8),
              color: isActive ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4) : null,
              child: ListTile(
                leading: Icon(
                  isActive ? Icons.stars_rounded : Icons.location_on_rounded,
                  color: isActive ? theme.colorScheme.primary : Colors.grey,
                ),
                title: Text(name, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.w600)),
                subtitle: Text('${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}', style: const TextStyle(fontSize: 11)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.navigation_rounded, color: Colors.teal),
                      tooltip: 'Navigate',
                      onPressed: () {
                        NavigationHelper.launchNavigation(latitude: lat, longitude: lng, label: name);
                      },
                    ),
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'active') {
                          controller.selectActiveDestination(destId);
                        } else if (val == 'delete') {
                          controller.removeDestination(destId);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'active', child: Text('Set as Active')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete Stop')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

        const Divider(height: 28),

        // Meeting Points Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Rendezvous Meeting Points',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddMeetingPointDialog(context, controller),
              icon: const Icon(Icons.flag_rounded, size: 16),
              label: const Text('Add Point'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (mapState.meetingPoints.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No meeting points scheduled. Add breakfast or fuel stops.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          )
        else
          ...mapState.meetingPoints.entries.map((entry) {
            final pointId = entry.key;
            final point = entry.value;
            final name = point['name'] as String? ?? 'Meeting Point';
            final lat = (point['latitude'] as num).toDouble();
            final lng = (point['longitude'] as num).toDouble();
            final arrivedMap = point['arrivedMembers'] as Map? ?? {};
            final hasCheckedIn = user != null && arrivedMap.containsKey(user.uid);

            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flag_circle_rounded, color: Colors.orange, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(
                                '${arrivedMap.length} member${arrivedMap.length == 1 ? '' : 's'} arrived',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        // Check In Button
                        ElevatedButton.icon(
                          onPressed: hasCheckedIn
                              ? null
                              : () async {
                                  await controller.checkInAtMeetingPoint(pointId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Checked in at $name! 🎉')),
                                    );
                                  }
                                },
                          icon: Icon(hasCheckedIn ? Icons.check_circle : Icons.where_to_vote, size: 16),
                          label: Text(hasCheckedIn ? 'Arrived' : 'Check In'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasCheckedIn ? Colors.green : theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.navigation_outlined, color: Colors.teal),
                          onPressed: () {
                            NavigationHelper.launchNavigation(latitude: lat, longitude: lng, label: name);
                          },
                        ),
                      ],
                    ),
                    if (arrivedMap.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: arrivedMap.values.map((v) {
                          final uName = (v as Map)['userName'] as String? ?? 'Member';
                          return Chip(
                            avatar: const Icon(Icons.check, size: 14, color: Colors.green),
                            label: Text(uName, style: const TextStyle(fontSize: 11)),
                            backgroundColor: Colors.green.shade50,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // --- TAB 4: ALERTS FEED ---
  Widget _buildAlertsTab(
    BuildContext context,
    ScrollController scrollController,
    LiveMapState mapState,
  ) {
    if (mapState.notifications.isEmpty) {
      return const Center(
        child: Text(
          'No activity alerts yet.\nArrivals, stop changes, and convoy alerts will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: mapState.notifications.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notif = mapState.notifications[index];
        final title = notif['title'] as String? ?? 'Update';
        final body = notif['body'] as String? ?? '';
        final timestamp = notif['timestamp'] as int? ?? 0;
        final timeStr = timestamp > 0 ? DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(timestamp)) : '';

        final isEmergency = title.contains('SOS') || title.contains('EMERGENCY');

        return ListTile(
          leading: Icon(
            isEmergency ? Icons.warning_rounded : Icons.info_outline_rounded,
            color: isEmergency ? Colors.red : Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isEmergency ? Colors.red : null,
            ),
          ),
          subtitle: Text(body, style: const TextStyle(fontSize: 12)),
          trailing: Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        );
      },
    );
  }

  // --- DIALOGS ---

  void _showAddStopDialog(BuildContext context, LiveMapController controller) {
    final nameController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();

    if (widget.currentUserLocation != null) {
      latController.text = widget.currentUserLocation!.latitude.toStringAsFixed(5);
      lngController.text = widget.currentUserLocation!.longitude.toStringAsFixed(5);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Trip Destination/Stop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Stop Name (e.g. Abbey Falls)'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latController,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: lngController,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final lat = double.tryParse(latController.text.trim()) ?? 0.0;
              final lng = double.tryParse(lngController.text.trim()) ?? 0.0;
              if (name.isNotEmpty && lat != 0.0) {
                controller.addNewDestination(name, lat, lng);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Stop'),
          ),
        ],
      ),
    );
  }

  void _showAddMeetingPointDialog(BuildContext context, LiveMapController controller) {
    final nameController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();

    if (widget.currentUserLocation != null) {
      latController.text = widget.currentUserLocation!.latitude.toStringAsFixed(5);
      lngController.text = widget.currentUserLocation!.longitude.toStringAsFixed(5);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Rendezvous Meeting Point'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name (e.g. Kamat Dhaba, Toll Plaza)'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latController,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: lngController,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final lat = double.tryParse(latController.text.trim()) ?? 0.0;
              final lng = double.tryParse(lngController.text.trim()) ?? 0.0;
              if (name.isNotEmpty && lat != 0.0) {
                controller.addMeetingPoint(name, lat, lng);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Meeting Point'),
          ),
        ],
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context, LiveMapController controller) {
    final nameController = TextEditingController();
    String vehicleType = 'car';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Convoy Vehicle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Vehicle Name (e.g. Rahul’s Scorpio)'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: vehicleType,
                decoration: const InputDecoration(labelText: 'Vehicle Type'),
                items: const [
                  DropdownMenuItem(value: 'car', child: Text('Car / Sedan / Hatchback')),
                  DropdownMenuItem(value: 'suv', child: Text('SUV / MUV')),
                  DropdownMenuItem(value: 'bike', child: Text('Bike / Motorcycle')),
                  DropdownMenuItem(value: 'van', child: Text('Van / Minibus')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => vehicleType = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final vId = 'veh_${DateTime.now().millisecondsSinceEpoch}';
                  controller.createOrUpdateVehicle(
                    vehicleId: vId,
                    name: name,
                    type: vehicleType,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Create Vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
