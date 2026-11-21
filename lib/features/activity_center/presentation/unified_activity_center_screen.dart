import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../notifications/presentation/notification_controller.dart';
import '../application/activity_center_notifier.dart';
import '../application/trip_readiness_service.dart';
import '../domain/action_item_model.dart';
import 'widgets/trip_readiness_card.dart';

class UnifiedActivityCenterScreen extends ConsumerStatefulWidget {
  const UnifiedActivityCenterScreen({super.key});

  @override
  ConsumerState<UnifiedActivityCenterScreen> createState() =>
      _UnifiedActivityCenterScreenState();
}

class _UnifiedActivityCenterScreenState
    extends ConsumerState<UnifiedActivityCenterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  ActionItemType? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actions = ref.watch(myPendingActionsProvider);
    final allTrips = ref.watch(allUserTripsProvider).value ?? [];
    final activeTrips = allTrips.where((t) => t.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Center', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: ref.watch(unreadNotificationCountProvider) > 0,
              label: Text('${ref.watch(unreadNotificationCountProvider)}'),
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Notification History',
            onPressed: () => context.push('/notifications'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pending Actions'),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppPallete.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${actions.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Trip Readiness'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Pending Actions
          _buildPendingActionsTab(context, actions),

          // Tab 2: Trip Readiness
          _buildTripReadinessTab(context, activeTrips),
        ],
      ),
    );
  }

  Widget _buildPendingActionsTab(BuildContext context, List<ActionItemModel> actions) {
    final filtered = _selectedTypeFilter == null
        ? actions
        : actions.where((a) => a.type == _selectedTypeFilter).toList();

    return Column(
      children: [
        // Filter Chips Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'All (${actions.length})'),
                const SizedBox(width: 8),
                _buildFilterChip(ActionItemType.poll, 'Polls (${actions.where((a) => a.type == ActionItemType.poll).length})'),
                const SizedBox(width: 8),
                _buildFilterChip(ActionItemType.task, 'Tasks (${actions.where((a) => a.type == ActionItemType.task).length})'),
                const SizedBox(width: 8),
                _buildFilterChip(ActionItemType.settlement, 'Settlements (${actions.where((a) => a.type == ActionItemType.settlement).length})'),
                const SizedBox(width: 8),
                _buildFilterChip(ActionItemType.shopping, 'Supplies (${actions.where((a) => a.type == ActionItemType.shopping).length})'),
              ],
            ),
          ),
        ),

        // Action Items List
        Expanded(
          child: filtered.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.done_all_rounded,
                  title: 'All Caught Up!',
                  description: _selectedTypeFilter == null
                      ? 'You have no pending tasks, votes, or settlement actions across any of your trips.'
                      : 'No actions pending under this category.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _ActionListItem(item: item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTripReadinessTab(BuildContext context, List<dynamic> trips) {
    if (trips.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.flight_takeoff_rounded,
        title: 'No Active Trips',
        description: 'Create a trip inside a Circle to see live trip readiness scores and checklists.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        final readiness = ref.watch(tripReadinessProvider(trip.id));

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TripReadinessCard(
            readiness: readiness,
            onFixBlockers: () => context.push('/trip/${trip.id}?tab=0'),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(ActionItemType? type, String label) {
    final isSelected = _selectedTypeFilter == type;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedTypeFilter = type),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
      ),
      selectedColor: AppPallete.primary,
      backgroundColor: Colors.grey.withValues(alpha: 0.08),
      side: BorderSide(
        color: isSelected ? AppPallete.primary : Colors.grey.withValues(alpha: 0.2),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }
}

class _ActionListItem extends StatelessWidget {
  final ActionItemModel item;

  const _ActionListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.urgency == ActionItemUrgency.urgent
              ? const Color(0xFFEF4444).withValues(alpha: 0.4)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          width: item.urgency == ActionItemUrgency.urgent ? 1.5 : 1,
        ),
        boxShadow: AppPallete.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push(item.actionRoute),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 20, color: item.iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.urgencyColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.urgencyLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: item.urgencyColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.tripName ?? 'CoCircle',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => context.push(item.actionRoute),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPallete.primary,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  child: Text(item.actionLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
