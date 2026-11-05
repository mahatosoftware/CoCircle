import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../live_map_controller.dart';
import '../../../tracking/application/tracking_notifier.dart';
import '../../domain/member_location_model.dart';
import 'member_bottom_sheet.dart';

enum DashboardSort { eta, distance, vehicle }

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

class _GroupDashboardState extends ConsumerState<GroupDashboard> {
  DashboardSort _sortBy = DashboardSort.distance;

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

    // 1. Calculate and Sort List
    final List<Map<String, dynamic>> processedList = mapState.members.map((member) {
      // Distance calculation
      double distance = 0.0;
      if (widget.currentUserLocation != null) {
        distance = Geolocator.distanceBetween(
          widget.currentUserLocation!.latitude,
          widget.currentUserLocation!.longitude,
          member.latitude,
          member.longitude,
        );
      }

      // Check route status
      double etaSeconds = double.infinity;
      final routeDetails = mapState.routes[member.userId];
      if (routeDetails != null && routeDetails['duration'] != null) {
        etaSeconds = (routeDetails['duration'] as num).toDouble();
      }

      // Calculate status
      String status = 'On the way';
      if (!member.online) {
        status = 'Offline';
      } else {
        // Find if user has arrived at active destination
        final activeDestId = mapState.activeDestinationId;
        if (activeDestId != null) {
          final dest = mapState.destinations[activeDestId];
          if (dest != null) {
            final destLat = dest['latitude'] as double;
            final destLng = dest['longitude'] as double;
            final destDistance = Geolocator.distanceBetween(
              member.latitude,
              member.longitude,
              destLat,
              destLng,
            );
            if (destDistance <= 50.0) {
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

    // Sort list based on selected filter
    processedList.sort((a, b) {
      if (_sortBy == DashboardSort.distance) {
        final double distA = a['distance'] as double;
        final double distB = b['distance'] as double;
        return distA.compareTo(distB);
      } else if (_sortBy == DashboardSort.eta) {
        final double etaA = a['eta'] as double;
        final double etaB = b['eta'] as double;
        return etaA.compareTo(etaB);
      } else {
        final MemberLocationModel memberA = a['member'] as MemberLocationModel;
        final MemberLocationModel memberB = b['member'] as MemberLocationModel;
        final vA = memberA.vehicleId ?? '';
        final vB = memberB.vehicleId ?? '';
        return vA.compareTo(vB);
      }
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      maxChildSize: 0.85,
      minChildSize: 0.15,
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
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header & Sorting controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trip Members (${mapState.members.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Text('Sort: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                            if (val != null) {
                              setState(() => _sortBy = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Current User Vehicle Selector
              if (widget.currentUserLocation != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.directions_car_filled_outlined, size: 18, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('My Vehicle:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      DropdownButton<String>(
                        value: widget.currentUserLocation!.vehicleId ?? 'default',
                        underline: const SizedBox(),
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        items: [
                          const DropdownMenuItem(value: 'default', child: Text('Walking / No Vehicle')),
                          ...VehicleConfig.list.map((v) => DropdownMenuItem(
                                value: v.id,
                                child: Row(
                                  children: [
                                    Icon(v.icon, size: 16, color: v.color),
                                    const SizedBox(width: 6),
                                    Text(v.name),
                                  ],
                                ),
                              )),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(trackingProvider.notifier).updateVehicleAssignment(val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              const Divider(height: 1),
              // Members list
              Expanded(
                child: processedList.isEmpty
                    ? const Center(
                        child: Text(
                          'No active tracking members.',
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

                          final isSelf = member.userId == widget.currentUserLocation?.userId;

                          Color statusColor = Colors.orange;
                          if (status == 'Arrived') statusColor = Colors.green;
                          if (status == 'Offline') statusColor = Colors.grey;

                          return ListTile(
                            onTap: () {
                              controller.selectMember(member.userId);
                              controller.toggleFollowMe(true);
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                builder: (ctx) => MemberBottomSheet(
                                  tripId: widget.tripId,
                                  member: member,
                                  currentUserLocation: widget.currentUserLocation,
                                ),
                              );
                            },
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: member.photoUrl != null && member.photoUrl!.isNotEmpty
                                      ? NetworkImage(member.photoUrl!)
                                      : null,
                                  child: member.photoUrl == null || member.photoUrl!.isEmpty
                                      ? Text(member.name.substring(0, 1).toUpperCase())
                                      : null,
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
                                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    member.name + (isSelf ? ' (Me)' : ''),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Icon(vehicle.icon, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  vehicle.name,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                if (member.battery != null) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.battery_std_rounded, size: 12, color: Colors.grey),
                                  Text(
                                    '${member.battery}%',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  !isSelf && dist > 0 ? _formatDistance(dist) : '—',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                if (eta != double.infinity) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'ETA: ${_formatDuration(eta)}',
                                    style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
