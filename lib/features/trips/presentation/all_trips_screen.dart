import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../circles/presentation/circle_controller.dart';
import '../domain/trip_model.dart';
import 'trip_controller.dart';

enum TripFilter { all, ongoing, upcoming, completed }

class AllTripsScreen extends ConsumerStatefulWidget {
  const AllTripsScreen({super.key});

  @override
  ConsumerState<AllTripsScreen> createState() => _AllTripsScreenState();
}

class _AllTripsScreenState extends ConsumerState<AllTripsScreen> {
  TripFilter _selectedFilter = TripFilter.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTripsAsync = ref.watch(allUserTripsProvider);
    final circlesAsync = ref.watch(userCirclesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search trips...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              )
            : Text(
                'Trips',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : AppPallete.navy,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: isDark ? Colors.white : AppPallete.navy,
              size: 24,
            ),
            tooltip: 'Search',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: isDark ? Colors.white : AppPallete.navy,
              size: 22,
            ),
            tooltip: 'Filter & Sort',
            onPressed: () => _showFilterSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row (All, Ongoing, Upcoming, Completed)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('All', TripFilter.all, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Ongoing', TripFilter.ongoing, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Upcoming', TripFilter.upcoming, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', TripFilter.completed, isDark),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Trips List
          Expanded(
            child: allTripsAsync.when(
              data: (trips) {
                // Apply search filter
                var filtered = trips.where((t) {
                  final nameMatches = t.name.toLowerCase().contains(_searchQuery);
                  final locMatches = t.location?.toLowerCase().contains(_searchQuery) ?? false;
                  return nameMatches || locMatches;
                }).toList();

                // Apply status filter
                if (_selectedFilter == TripFilter.ongoing) {
                  filtered = filtered.where((t) {
                    if (t.status.toLowerCase() == 'ongoing') return true;
                    if (!t.isActive) return false;
                    if (t.startDate != null && t.endDate != null) {
                      return now.isAfter(t.startDate!) &&
                          now.isBefore(t.endDate!.add(const Duration(days: 1)));
                    }
                    return false;
                  }).toList();
                } else if (_selectedFilter == TripFilter.upcoming) {
                  filtered = filtered.where((t) {
                    if (t.status.toLowerCase() == 'upcoming' || t.status.toLowerCase() == 'planning') {
                      return true;
                    }
                    if (t.startDate == null) return false;
                    return t.startDate!.isAfter(now) && t.isActive;
                  }).toList();
                } else if (_selectedFilter == TripFilter.completed) {
                  filtered = filtered.where((t) {
                    if (t.status.toLowerCase() == 'closed' || t.status.toLowerCase() == 'completed') {
                      return true;
                    }
                    if (!t.isActive) return true;
                    if (t.endDate != null) return now.isAfter(t.endDate!.add(const Duration(days: 1)));
                    return false;
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.flight_takeoff_rounded,
                    title: 'No Trips Found',
                    description: _searchQuery.isNotEmpty
                        ? 'No trips matched your search for "$_searchQuery".'
                        : 'Plan your next adventure with your group!',
                    actionLabel: _searchQuery.isEmpty ? 'Plan a Trip' : null,
                    onAction: () {
                      circlesAsync.whenData((circles) {
                        if (circles.isNotEmpty) {
                          _showSelectCircleForTripDialog(context, circles);
                        } else {
                          context.push('/create-circle');
                        }
                      });
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(allUserTripsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final trip = filtered[index];
                      return _buildTripRowItem(context, trip, isDark);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading trips: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppPallete.indigo,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          circlesAsync.whenData((circles) {
            if (circles.isNotEmpty) {
              _showSelectCircleForTripDialog(context, circles);
            } else {
              context.push('/create-circle');
            }
          });
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Create Trip',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TripFilter filter, bool isDark) {
    final isSelected = _selectedFilter == filter;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppPallete.indigo
              : (isDark ? AppPallete.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppPallete.indigo
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppPallete.indigo.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : AppPallete.gray),
          ),
        ),
      ),
    );
  }

  Widget _buildTripRowItem(BuildContext context, TripModel trip, bool isDark) {
    String dateRange = 'Dates pending';
    if (trip.startDate != null) {
      final startFmt = DateFormat('d MMM').format(trip.startDate!);
      final endFmt = trip.endDate != null ? DateFormat('d MMM').format(trip.endDate!) : '';
      dateRange = endFmt.isNotEmpty ? '$startFmt - $endFmt' : startFmt;
    }
    final membersCount = trip.participantIds.isNotEmpty ? trip.participantIds.length : 6;
    final subtitle = '$dateRange • $membersCount members';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push('/trip/${trip.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail Image
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=300&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppPallete.navy,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Status Badge
                StatusBadge.fromTripStatus(trip.status.isNotEmpty ? trip.status : 'Ongoing'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort & Filter Trips',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: const Text('Sort by Start Date (Earliest first)'),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: const Icon(Icons.people_alt_rounded),
                  title: const Text('Sort by Member Count'),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money_rounded),
                  title: const Text('Sort by Total Budget'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSelectCircleForTripDialog(BuildContext context, List circles) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Circle', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: circles.length,
            itemBuilder: (ctx, i) {
              final c = circles[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppPallete.indigo.withValues(alpha: 0.15),
                  child: Text(
                    c.name[0].toUpperCase(),
                    style: const TextStyle(color: AppPallete.indigo, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${c.memberIds.length} members'),
                onTap: () {
                  Navigator.pop(dialogCtx);
                  context.push('/circle/${c.id}/create-trip');
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
