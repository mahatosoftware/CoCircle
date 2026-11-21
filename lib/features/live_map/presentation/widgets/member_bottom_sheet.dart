import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../live_map_controller.dart';
import '../../domain/member_location_model.dart';

class VehicleConfig {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const VehicleConfig({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<VehicleConfig> list = [
    VehicleConfig(id: 'car_1', name: 'Car 1', icon: Icons.directions_car_filled_rounded, color: Colors.teal),
    VehicleConfig(id: 'car_2', name: 'Car 2', icon: Icons.directions_car_filled_rounded, color: Colors.orange),
    VehicleConfig(id: 'car_3', name: 'Car 3', icon: Icons.directions_car_filled_rounded, color: Colors.purple),
    VehicleConfig(id: 'bike', name: 'Motorcycle / Bike', icon: Icons.two_wheeler_rounded, color: Colors.indigo),
    VehicleConfig(id: 'van', name: 'Van / Minibus', icon: Icons.airport_shuttle_rounded, color: Colors.deepOrange),
  ];

  static VehicleConfig getById(String? id) {
    return list.firstWhere(
      (v) => v.id == id,
      orElse: () => const VehicleConfig(
        id: 'default',
        name: 'Walking / On Foot',
        icon: Icons.directions_walk_rounded,
        color: Color(0xFF6750A4),
      ),
    );
  }
}

class MemberBottomSheet extends ConsumerWidget {
  final String tripId;
  final MemberLocationModel member;
  final MemberLocationModel? currentUserLocation;

  const MemberBottomSheet({
    super.key,
    required this.tripId,
    required this.member,
    required this.currentUserLocation,
  });

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
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

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 20) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _makeCall(BuildContext context) async {
    final url = Uri.parse('tel:');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot launch system dialer.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(liveMapControllerProvider(tripId));
    final controller = ref.read(liveMapControllerProvider(tripId).notifier);
    final vehicle = VehicleConfig.getById(member.vehicleId);

    // Calculate distance from current user
    double? distance;
    if (currentUserLocation != null && currentUserLocation!.userId != member.userId) {
      distance = Geolocator.distanceBetween(
        currentUserLocation!.latitude,
        currentUserLocation!.longitude,
        member.latitude,
        member.longitude,
      );
    }

    final isTarget = mapState.navigationTargetId == member.userId;
    final speedKmh = member.speed * 3.6;

    // Determine sharing status
    String statusLabel = 'Online';
    Color statusColor = Colors.green;
    if (member.isEmergency) {
      statusLabel = '🚨 EMERGENCY SOS';
      statusColor = Colors.red;
    } else if (member.sharingStatus == 'paused') {
      statusLabel = 'Sharing Paused';
      statusColor = Colors.amber.shade800;
    } else if (!member.online || DateTime.now().difference(member.lastUpdated).inMinutes > 5) {
      statusLabel = 'Offline / Stale';
      statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Emergency Banner if active
          if (member.isEmergency) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${member.name} Triggered SOS!',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        const Text(
                          'Requires immediate assistance.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: member.photoUrl != null && member.photoUrl!.isNotEmpty
                        ? NetworkImage(member.photoUrl!)
                        : null,
                    child: member.photoUrl == null || member.photoUrl!.isEmpty
                        ? Text(
                            member.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).cardColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(vehicle.icon, size: 16, color: vehicle.color),
                        const SizedBox(width: 6),
                        Text(
                          member.vehicleName ?? vehicle.name,
                          style: TextStyle(fontSize: 12, color: vehicle.color, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        if (member.battery != null) ...[
                          Icon(
                            member.battery! <= 20 ? Icons.battery_alert_rounded : Icons.battery_std_rounded,
                            size: 14,
                            color: member.battery! <= 20 ? Colors.red : Colors.grey,
                          ),
                          Text(
                            '${member.battery}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: member.battery! <= 20 ? Colors.red : Colors.grey,
                              fontWeight: member.battery! <= 20 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTimeAgo(member.lastUpdated),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatsTile(
                icon: Icons.speed_rounded,
                label: 'Speed',
                value: speedKmh > 1.0 ? '${speedKmh.toStringAsFixed(0)} km/h' : 'Stationary',
              ),
              _buildStatsTile(
                icon: Icons.navigation_rounded,
                label: 'Distance',
                value: distance != null ? _formatDistance(distance) : '—',
              ),
              if (isTarget && mapState.navigationRoute != null)
                _buildStatsTile(
                  icon: Icons.schedule_rounded,
                  label: 'ETA',
                  value: _formatDuration(mapState.navigationRoute!.duration),
                )
              else
                _buildStatsTile(
                  icon: Icons.gps_fixed_rounded,
                  label: 'Accuracy',
                  value: '±${member.accuracy.toStringAsFixed(0)} m',
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (currentUserLocation?.userId != member.userId) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (isTarget) {
                        controller.stopNavigation();
                      } else {
                        controller.startNavigation(member.userId);
                      }
                      Navigator.pop(context);
                    },
                    icon: Icon(isTarget ? Icons.navigation_outlined : Icons.navigation_rounded),
                    label: Text(isTarget ? 'Stop Nav' : 'In-App Nav'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTarget ? Colors.red : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // External Turn-by-Turn Navigation (Google Maps / Apple Maps)
                ElevatedButton.icon(
                  onPressed: () {
                    NavigationHelper.launchNavigation(
                      latitude: member.latitude,
                      longitude: member.longitude,
                      label: member.name,
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Maps App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              OutlinedButton(
                onPressed: () => _makeCall(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.call_rounded),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  controller.toggleFollowMe(true);
                  controller.selectMember(member.userId);
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.center_focus_strong_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTile({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
