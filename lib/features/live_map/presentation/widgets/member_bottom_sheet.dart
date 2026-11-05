import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
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
    VehicleConfig(id: 'bike', name: 'Bike', icon: Icons.two_wheeler_rounded, color: Colors.indigo),
  ];

  static VehicleConfig getById(String? id) {
    return list.firstWhere(
      (v) => v.id == id,
      orElse: () => const VehicleConfig(
        id: 'default',
        name: 'Walking/On Foot',
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
    if (diff.inSeconds < 15) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _makeCall(BuildContext context) async {
    final url = Uri.parse('tel:+919999999999'); // Standard fallback dialer placeholder
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

    // Check if this member is the active navigation target
    final isTarget = mapState.navigationTargetId == member.userId;
    final speedKmh = member.speed * 3.6;

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
                        color: member.online ? Colors.green : Colors.grey,
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
                          vehicle.name,
                          style: TextStyle(fontSize: 12, color: vehicle.color, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        if (member.battery != null) ...[
                          const Icon(Icons.battery_std_rounded, size: 14, color: Colors.grey),
                          Text(
                            '${member.battery}%',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                      color: member.online ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      member.online ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: member.online ? Colors.green : Colors.grey,
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
                  value: '${member.accuracy.toStringAsFixed(0)} m',
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
                    label: Text(isTarget ? 'Stop Nav' : 'Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTarget ? Colors.red : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat link is currently a placeholder.')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded),
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
