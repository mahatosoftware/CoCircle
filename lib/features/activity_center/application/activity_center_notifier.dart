import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../financial/settlements/presentation/settlement_controller.dart';
import '../../polls/presentation/poll_controller.dart';
import '../../tasks/presentation/task_controller.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../trips/presentation/trip_planner_controller.dart';
import '../domain/action_item_model.dart';
import 'trip_readiness_service.dart';

final myPendingActionsProvider = Provider<List<ActionItemModel>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return [];

  final allTrips = ref.watch(allUserTripsProvider).value ?? [];
  final activeTrips = allTrips.where((t) => t.isActive).toList();

  final items = <ActionItemModel>[];

  for (final trip in activeTrips) {
    // 1. Pending Polls
    final pollsAsync = ref.watch(tripPollsProvider(trip.id));
    final polls = pollsAsync.value ?? [];
    for (final poll in polls) {
      final hasVoted = poll.votes.containsKey(user.uid);
      final hasDeadlinePassed = poll.deadline != null && DateTime.now().isAfter(poll.deadline!);
      final isActuallyActive = poll.isActive && !hasDeadlinePassed;

      if (!hasVoted && isActuallyActive) {
        items.add(ActionItemModel(
          id: 'poll_${poll.id}',
          tripId: trip.id,
          tripName: trip.name,
          circleId: trip.circleId,
          type: ActionItemType.poll,
          title: 'Vote: ${poll.question}',
          subtitle: '${poll.options.length} options · ${poll.votes.length} votes cast so far',
          urgency: poll.deadline != null ? ActionItemUrgency.urgent : ActionItemUrgency.high,
          timestamp: poll.createdAt,
          actionRoute: '/trip/${trip.id}?tab=5',
          actionLabel: 'Vote Now',
          icon: Icons.poll_rounded,
          iconColor: const Color(0xFF8B5CF6),
        ));
      }
    }

    // 2. Pending Tasks
    final tasksAsync = ref.watch(tripTasksProvider(trip.id));
    final tasks = tasksAsync.value ?? [];
    for (final task in tasks) {
      if (!task.isCompleted) {
        // If assigned or general pending to-do
        items.add(ActionItemModel(
          id: 'task_${task.id}',
          tripId: trip.id,
          tripName: trip.name,
          circleId: trip.circleId,
          type: ActionItemType.task,
          title: task.title,
          subtitle: 'Trip prep to-do for ${trip.name}',
          urgency: ActionItemUrgency.normal,
          timestamp: task.createdAt,
          actionRoute: '/trip/${trip.id}?tab=4',
          actionLabel: 'View Task',
          icon: Icons.task_alt_rounded,
          iconColor: const Color(0xFFF59E0B),
        ));
      }
    }

    // 3. Pending Settlements
    final settlementsAsync = ref.watch(activeSettlementsProvider(trip.id));
    final settlements = settlementsAsync.value ?? [];
    for (final s in settlements) {
      if (s.fromUid == user.uid) {
        items.add(ActionItemModel(
          id: 'settle_${trip.id}_${s.toUid}',
          tripId: trip.id,
          tripName: trip.name,
          circleId: trip.circleId,
          type: ActionItemType.settlement,
          title: 'Pay ₹${s.amount.toStringAsFixed(0)} settlement',
          subtitle: 'Expense balance settlement for ${trip.name}',
          urgency: ActionItemUrgency.urgent,
          timestamp: DateTime.now(),
          actionRoute: '/trip/${trip.id}?tab=3',
          actionLabel: 'Settle Up',
          icon: Icons.payments_rounded,
          iconColor: const Color(0xFF10B981),
          metadata: {'amount': s.amount, 'toUid': s.toUid},
        ));
      }
    }

    // 4. Pending Unclaimed or Needed Packing Items
    final packingAsync = ref.watch(tripPackingProvider(trip.id));
    final packing = packingAsync.value ?? [];
    final unassignedPacking = packing.where((p) => !p.isPacked && (p.assignedTo == null || p.assignedTo!.isEmpty)).toList();
    if (unassignedPacking.isNotEmpty) {
      items.add(ActionItemModel(
        id: 'pack_${trip.id}',
        tripId: trip.id,
        tripName: trip.name,
        circleId: trip.circleId,
        type: ActionItemType.shopping,
        title: '${unassignedPacking.length} packing supplies needed',
        subtitle: 'Items like "${unassignedPacking.first.title}" need claiming',
        urgency: ActionItemUrgency.normal,
        timestamp: DateTime.now(),
        actionRoute: '/trip/${trip.id}?tab=1',
        actionLabel: 'Claim Items',
        icon: Icons.backpack_rounded,
        iconColor: const Color(0xFF0EA5E9),
      ));
    }

    // 5. Trip Readiness Blocker Warning
    final readiness = ref.watch(tripReadinessProvider(trip.id));
    if (readiness.criticalBlockers.isNotEmpty) {
      items.add(ActionItemModel(
        id: 'readiness_${trip.id}',
        tripId: trip.id,
        tripName: trip.name,
        circleId: trip.circleId,
        type: ActionItemType.readiness,
        title: '${trip.name}: ${readiness.criticalBlockers.first}',
        subtitle: 'Readiness: ${readiness.overallScore}% · ${readiness.recommendedActions.isNotEmpty ? readiness.recommendedActions.first : "Check workspace"}',
        urgency: ActionItemUrgency.high,
        timestamp: DateTime.now(),
        actionRoute: '/trip/${trip.id}?tab=0',
        actionLabel: 'Fix Blocker',
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFEF4444),
      ));
    }
  }

  // Sort by urgency, then timestamp descending
  items.sort((a, b) {
    final urgencyComp = a.urgency.index.compareTo(b.urgency.index);
    if (urgencyComp != 0) return urgencyComp;
    return b.timestamp.compareTo(a.timestamp);
  });

  return items;
});
