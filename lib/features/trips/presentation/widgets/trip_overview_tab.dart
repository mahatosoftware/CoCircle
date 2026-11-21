import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../circles/presentation/circle_controller.dart';
import '../trip_controller.dart';
import '../trip_participant_controller.dart';

class TripOverviewTab extends ConsumerWidget {
  final String tripId;
  final VoidCallback onNavigateToMap;
  final VoidCallback onNavigateToItinerary;
  final VoidCallback onNavigateToExpenses;
  final VoidCallback onNavigateToTasks;
  final VoidCallback onNavigateToPolls;
  final VoidCallback? onNavigateToMembers;

  const TripOverviewTab({
    super.key,
    required this.tripId,
    required this.onNavigateToMap,
    required this.onNavigateToItinerary,
    required this.onNavigateToExpenses,
    required this.onNavigateToTasks,
    required this.onNavigateToPolls,
    this.onNavigateToMembers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailsProvider(tripId));
    final participantsAsync = ref.watch(tripParticipantsProvider(tripId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return tripAsync.when(
      data: (trip) {
        final circleMembersAsync = ref.watch(circleMembersProvider(trip.circleId));
        final memberNames = circleMembersAsync.value?.map((u) => u.displayName).toList() ?? ['You'];
        
        final participants = participantsAsync.value ?? [];
        final memberCount = participants.isNotEmpty 
            ? participants.length 
            : (trip.participantIds.isNotEmpty ? trip.participantIds.length : (memberNames.length > 1 ? memberNames.length : 1));

        String datesText = '12 - 15 Mar (4 days)';
        if (trip.startDate != null) {
          final startStr = DateFormat('d MMM').format(trip.startDate!);
          final endStr = trip.endDate != null ? DateFormat('d MMM').format(trip.endDate!) : '';
          final days = trip.endDate != null ? trip.endDate!.difference(trip.startDate!).inDays + 1 : 1;
          datesText = endStr.isNotEmpty ? '$startStr - $endStr ($days days)' : '$startStr ($days day)';
        }

        final locationText = trip.location?.isNotEmpty == true ? trip.location! : 'Coorg, Karnataka';
        final budgetText = trip.totalBudget > 0 ? '₹${trip.totalBudget.toStringAsFixed(0)}' : '₹60,000';

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
          children: [
            // 1. Trip Progress Card (68% with Checklist)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trip Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppPallete.navy,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Text(
                        '68%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppPallete.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const LinearProgressIndicator(
                      value: 0.68,
                      minHeight: 8,
                      backgroundColor: Color(0xFFEEF2FF),
                      valueColor: AlwaysStoppedAnimation<Color>(AppPallete.indigo),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress Checklist
                  _buildProgressItem('Destination & dates', isDone: true, isDark: isDark),
                  const SizedBox(height: 8),
                  _buildProgressItem('Itinerary (3/4 days)', isDone: true, isDark: isDark),
                  const SizedBox(height: 8),
                  _buildProgressItem('Key bookings', isDone: false, isDark: isDark),
                  const SizedBox(height: 8),
                  _buildProgressItem('Tasks (5 open)', isDone: false, isDark: isDark),
                  const SizedBox(height: 8),
                  _buildProgressItem('Final confirmation', isDone: false, isDark: isDark),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Next Actions Section (Wireframe 2 Planning Workspace)
            Text(
              'Next Actions',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: isDark ? Colors.white : AppPallete.navy,
              ),
            ),
            const SizedBox(height: 10),

            _buildActionItem(
              icon: Icons.how_to_vote_rounded,
              iconColor: const Color(0xFF5B42F3),
              iconBgColor: const Color(0xFFEEF2FF),
              title: 'Vote: Choose a stay option',
              subtitle: 'Ends in 2 days',
              isDark: isDark,
              onTap: onNavigateToPolls,
            ),
            const SizedBox(height: 10),

            _buildActionItem(
              icon: Icons.assignment_turned_in_rounded,
              iconColor: const Color(0xFF0284C7),
              iconBgColor: const Color(0xFFE0F2FE),
              title: 'Task: Book accommodation',
              subtitle: 'Assigned to Priya • Due in 3 days',
              isDark: isDark,
              onTap: onNavigateToTasks,
            ),
            const SizedBox(height: 10),

            _buildActionItem(
              icon: Icons.edit_calendar_rounded,
              iconColor: const Color(0xFFF59E0B),
              iconBgColor: const Color(0xFFFEF3C7),
              title: 'Finalize Day 3 itinerary',
              subtitle: '2 suggestions ready',
              isDark: isDark,
              onTap: onNavigateToItinerary,
            ),

            const SizedBox(height: 20),

            // 3. Trip Snapshot Grid
            Text(
              'Trip Snapshot',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: isDark ? Colors.white : AppPallete.navy,
              ),
            ),
            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.3,
              children: [
                _buildSnapshotTile(
                  icon: Icons.calendar_today_rounded,
                  iconColor: const Color(0xFF5B42F3),
                  title: datesText,
                  subtitle: 'Dates',
                  isDark: isDark,
                ),
                _buildSnapshotTile(
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFF0D9488),
                  title: '$memberCount Members',
                  subtitle: 'Confirmed (View)',
                  isDark: isDark,
                  onTap: onNavigateToMembers,
                ),
                _buildSnapshotTile(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: budgetText,
                  subtitle: 'Budget',
                  isDark: isDark,
                ),
                _buildSnapshotTile(
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFFEF4444),
                  title: locationText,
                  subtitle: 'Destination',
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading overview: $err')),
    );
  }

  Widget _buildProgressItem(String title, {required bool isDone, required bool isDark}) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 18,
          color: isDone ? const Color(0xFF10B981) : (isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
            color: isDark ? Colors.white : AppPallete.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? iconColor.withValues(alpha: 0.15) : iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppPallete.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
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
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSnapshotTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppPallete.navy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: tile,
        ),
      );
    }
    return tile;
  }
}
