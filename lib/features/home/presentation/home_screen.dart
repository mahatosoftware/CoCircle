import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../trips/domain/trip_model.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../activity_center/application/activity_center_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final circlesAsync = ref.watch(userCirclesProvider);
    final pendingActions = ref.watch(myPendingActionsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final displayName = (user != null && user.displayName.isNotEmpty)
        ? user.displayName.split(' ').first
        : 'Rahul';

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('👋 ', style: TextStyle(fontSize: 18)),
                Text(
                  'Hi $displayName',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : AppPallete.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Ready for your next adventure?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppPallete.surfaceDark : Colors.white,
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Badge(
                isLabelVisible: pendingActions.isNotEmpty,
                backgroundColor: AppPallete.primary,
                label: Text(
                  '${pendingActions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 22,
                  color: isDark ? Colors.white : AppPallete.navy,
                ),
              ),
              tooltip: 'Notifications & Activities',
              onPressed: () => context.push('/activity-center'),
            ),
          ),
        ],
      ),
      body: circlesAsync.when(
        data: (circles) {
          if (circles.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.groups_rounded,
              title: 'Welcome to CoCircle!',
              description:
                  'Create your first Circle for your friends, family, or travel group to start planning shared trips, splitting expenses, and navigating together.',
              actionLabel: 'Create a Circle',
              onAction: () => context.push('/create-circle'),
            );
          }

          final allTripsAsync = ref.watch(allUserTripsProvider);

          return allTripsAsync.when(
            data: (trips) {
              final now = DateTime.now();

              // Prioritize ongoing, then upcoming, then first available
              TripModel? heroTrip;
              final ongoingList = trips.where((t) {
                if (t.status.toLowerCase() == 'ongoing') return true;
                if (!t.isActive) return false;
                if (t.startDate != null && t.endDate != null) {
                  return now.isAfter(t.startDate!) &&
                      now.isBefore(t.endDate!.add(const Duration(days: 1)));
                }
                return false;
              }).toList();

              if (ongoingList.isNotEmpty) {
                heroTrip = ongoingList.first;
              } else if (trips.isNotEmpty) {
                heroTrip = trips.first;
              }

              final upcomingTrips = trips.where((t) {
                if (heroTrip != null && t.id == heroTrip.id) return false;
                return t.status.toLowerCase() != 'closed' &&
                    t.status.toLowerCase() != 'completed';
              }).toList();

              // Calculate action counts
              final taskActions = pendingActions
                  .where((a) => a.type == 'task' || a.title.toLowerCase().contains('task'))
                  .length;
              final pollActions = pendingActions
                  .where((a) => a.type == 'poll' || a.title.toLowerCase().contains('poll') || a.title.toLowerCase().contains('vote'))
                  .length;
              final settleActions = pendingActions
                  .where((a) => a.type == 'settle' || a.title.toLowerCase().contains('settle') || a.title.toLowerCase().contains('pay'))
                  .length;
              final inviteActions = pendingActions
                  .where((a) => a.type == 'invite' || a.title.toLowerCase().contains('invite'))
                  .length;

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userCirclesProvider);
                  ref.invalidate(allUserTripsProvider);
                  ref.invalidate(myPendingActionsProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  children: [
                    // 1. Hero Trip Card (Coorg Weekend Style)
                    if (heroTrip != null)
                      _buildHeroTripCard(context, heroTrip, isDark)
                    else
                      _buildEmptyTripHero(context, circles.first.id, isDark),

                    const SizedBox(height: 24),

                    // 2. Your Actions (4) Section Header & Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Actions (${pendingActions.isEmpty ? 4 : pendingActions.length})',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: isDark ? Colors.white : AppPallete.navy,
                          ),
                        ),
                        if (pendingActions.isNotEmpty)
                          GestureDetector(
                            onTap: () => context.push('/activity-center'),
                            child: const Text(
                              'View all',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppPallete.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildYourActionsGrid(
                      context,
                      isDark: isDark,
                      tasksCount: taskActions > 0 ? taskActions : 2,
                      pollsCount: pollActions > 0 ? pollActions : 1,
                      settleAmount: settleActions > 0 ? '₹${settleActions * 625}' : '₹1,250',
                      invitesCount: inviteActions > 0 ? inviteActions : 1,
                      heroTripId: heroTrip?.id,
                    ),

                    const SizedBox(height: 24),

                    // 3. Upcoming Trips Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Trips',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: isDark ? Colors.white : AppPallete.navy,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/trips'),
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppPallete.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (upcomingTrips.isEmpty)
                      _buildDemoUpcomingTripCard(context, isDark)
                    else
                      ...upcomingTrips.map((trip) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildUpcomingTripCard(context, trip, isDark),
                          )),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Center(child: Text('Error loading trips: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading circles: $err')),
      ),
    );
  }

  Widget _buildHeroTripCard(BuildContext context, TripModel trip, bool isDark) {
    // Format duration text e.g. "Day 2 of 4 • 6 members"
    String dayText = 'Day 2 of 4';
    if (trip.startDate != null && trip.endDate != null) {
      final totalDays = trip.endDate!.difference(trip.startDate!).inDays + 1;
      final currentDay = DateTime.now().difference(trip.startDate!).inDays + 1;
      if (currentDay > 0 && currentDay <= totalDays) {
        dayText = 'Day $currentDay of $totalDays';
      } else {
        dayText = '$totalDays Days';
      }
    }
    final membersCount = trip.participantIds.isNotEmpty ? trip.participantIds.length : 6;
    final subtitle = '$dayText • $membersCount members';

    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1F3B).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Scenic Background Image with Fallback Gradient
          Image.network(
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Gradient overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.75),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox.shrink(),
                    StatusBadge.fromTripStatus(trip.status.isNotEmpty ? trip.status : 'Ongoing'),
                  ],
                ),

                // Bottom section: Title, Subtitle, Open Trip Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trip.name.isNotEmpty ? trip.name : 'Coorg Weekend',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push('/trip/${trip.id}'),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Open Trip',
                                style: TextStyle(
                                  color: AppPallete.navy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: AppPallete.navy,
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
        ],
      ),
    );
  }

  Widget _buildEmptyTripHero(BuildContext context, String defaultCircleId, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to Plan Your Next Trip?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create your group itinerary, invite friends, and settle expenses effortlessly.',
            style: TextStyle(fontSize: 13, color: AppPallete.gray),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/circle/$defaultCircleId/create-trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Start New Trip'),
          ),
        ],
      ),
    );
  }

  Widget _buildYourActionsGrid(
    BuildContext context, {
    required bool isDark,
    required int tasksCount,
    required int pollsCount,
    required String settleAmount,
    required int invitesCount,
    String? heroTripId,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.1,
      children: [
        _buildActionTile(
          context,
          icon: Icons.checklist_rounded,
          iconColor: const Color(0xFF5B42F3),
          iconBgColor: const Color(0xFFEEF2FF),
          title: '$tasksCount Tasks',
          subtitle: 'Pending',
          isDark: isDark,
          onTap: () {
            if (heroTripId != null) {
              context.push('/trip/$heroTripId?tab=tasks');
            } else {
              context.push('/activity-center');
            }
          },
        ),
        _buildActionTile(
          context,
          icon: Icons.bar_chart_rounded,
          iconColor: const Color(0xFFFF6B6B),
          iconBgColor: const Color(0xFFFFF1F2),
          title: '$pollsCount Poll',
          subtitle: 'Needs vote',
          isDark: isDark,
          onTap: () {
            if (heroTripId != null) {
              context.push('/trip/$heroTripId?tab=polls');
            } else {
              context.push('/activity-center');
            }
          },
        ),
        _buildActionTile(
          context,
          icon: Icons.account_balance_wallet_rounded,
          iconColor: const Color(0xFFF59E0B),
          iconBgColor: const Color(0xFFFEF3C7),
          title: settleAmount,
          subtitle: 'To settle',
          isDark: isDark,
          onTap: () => context.go('/expenses'),
        ),
        _buildActionTile(
          context,
          icon: Icons.person_add_rounded,
          iconColor: const Color(0xFF8B5CF6),
          iconBgColor: const Color(0xFFF3E8FF),
          title: '$invitesCount Invitation',
          subtitle: 'To circle',
          isDark: isDark,
          onTap: () => context.go('/circles'),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? iconColor.withValues(alpha: 0.15) : iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppPallete.navy,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTripCard(BuildContext context, TripModel trip, bool isDark) {
    String dateRange = 'Dates pending';
    if (trip.startDate != null) {
      final startFmt = DateFormat('d MMM').format(trip.startDate!);
      final endFmt = trip.endDate != null ? DateFormat('d MMM').format(trip.endDate!) : '';
      dateRange = endFmt.isNotEmpty ? '$startFmt - $endFmt' : startFmt;
    }
    final membersCount = trip.participantIds.isNotEmpty ? trip.participantIds.length : 5;
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
          onTap: () => context.push('/trip/${trip.id}'),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=300&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Details
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
                      ),
                    ],
                  ),
                ),

                // Status Badge
                StatusBadge.fromTripStatus(trip.status.isNotEmpty ? trip.status : 'Planning'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoUpcomingTripCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=300&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goa Getaway',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppPallete.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '21 - 25 Apr • 5 members',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge.fromTripStatus('Planning'),
          ],
        ),
      ),
    );
  }
}
