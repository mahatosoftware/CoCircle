import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../domain/poll_model.dart';
import '../domain/decision_engine_service.dart';
import 'poll_controller.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/utils/snackbar.dart';
import 'package:cocircle/l10n/app_localizations.dart';
import 'package:cocircle/features/circles/presentation/circle_controller.dart';
import 'package:cocircle/features/trips/presentation/trip_controller.dart';

class PollListView extends ConsumerWidget {
  final String tripId;
  const PollListView({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollsAsync = ref.watch(tripPollsProvider(tripId));
    final tripAsync = ref.watch(tripDetailsProvider(tripId));
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return pollsAsync.when(
      data: (polls) {
        if (polls.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.poll_outlined,
            title: 'No Polls Yet',
            description: 'Create a poll to decide on destinations, dates, hotels, or activities together.',
            actionLabel: 'Create a Poll',
            onAction: () => context.push('/trip/$tripId/create-poll'),
          );
        }

        return tripAsync.when(
          data: (trip) {
            final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
            return membersAsync.when(
              data: (members) {
                final memberMap = {for (var m in members) m.uid: m.displayName};

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: polls.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 0, 16),
                        child: Text(
                          l10n.polls,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    final poll = polls[index - 1];
                    final hasVoted = currentUserId != null && poll.votes.containsKey(currentUserId);
                    final totalVotes = poll.votes.length;
                    final isCreator = poll.creatorId == currentUserId;
                    final hasDeadlinePassed = poll.deadline != null && DateTime.now().isAfter(poll.deadline!);
                    final isActuallyActive = poll.isActive && !hasDeadlinePassed;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        poll.question,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Text(
                                            DateFormat.MMMd().add_jm().format(poll.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          if (poll.pollType == 'availability')
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text('📅 Dates', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                                            ),
                                          if (poll.isAnonymous)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text('🔒 Anonymous', style: TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold)),
                                            ),
                                          if (poll.deadline != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: hasDeadlinePassed ? Colors.red.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                hasDeadlinePassed
                                                    ? '⏰ Voting Closed'
                                                    : '⏰ Closes ${DateFormat.MMMd().add_jm().format(poll.deadline!)}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: hasDeadlinePassed ? Colors.red : Colors.orange.shade800,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          if (poll.convertedToAction)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text('✓ Converted', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                                            ),
                                        ],
                                      ),
                                      if (poll.allowMultipleSelections)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            l10n.allowMultipleSelections,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isCreator)
                                      IconButton(
                                        tooltip: l10n.editPoll,
                                        onPressed: () => context.push(
                                          '/trip/$tripId/create-poll',
                                          extra: poll,
                                        ),
                                        icon: const Icon(Icons.edit_outlined, size: 20),
                                      ),
                                    if (isCreator)
                                      IconButton(
                                        tooltip: l10n.deletePoll,
                                        onPressed: () => _showDeleteConfirmation(
                                          context,
                                          ref,
                                          poll.id,
                                        ),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...poll.options.asMap().entries.map((entry) {
                              final optIndex = entry.key;
                              final option = entry.value;
                              final percent = totalVotes == 0 ? 0.0 : option.voteCount / totalVotes;
                              final isSelected = currentUserId != null && (poll.votes[currentUserId]?.contains(optIndex) ?? false);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: isActuallyActive
                                          ? () => ref.read(pollControllerProvider.notifier).vote(
                                                pollId: poll.id,
                                                optionIndex: optIndex,
                                                context: context,
                                              )
                                          : null,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          if (hasVoted || !isActuallyActive)
                                            FractionallySizedBox(
                                              widthFactor: percent,
                                              child: Container(
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppPallete.primary.withValues(alpha: 0.2)
                                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          Container(
                                            height: 44,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    option.text,
                                                    style: TextStyle(
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                      color: isSelected ? AppPallete.primary : Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (hasVoted || !isActuallyActive)
                                                  Text(
                                                    '${option.voteCount} (${(percent * 100).toInt()}%)',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                      color: Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // AI Recommendation Banner if available
                            if (poll.aiRecommendation != null && poll.aiRecommendation!.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.auto_awesome, size: 16, color: Color(0xFF6366F1)),
                                        SizedBox(width: 6),
                                        Text(
                                          'AI Recommendation',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color(0xFF6366F1),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      poll.aiRecommendation!,
                                      style: const TextStyle(fontSize: 12, height: 1.35),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.votesCount(totalVotes),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 4,
                                  children: [
                                    if (poll.aiRecommendation == null && totalVotes > 0)
                                      TextButton.icon(
                                        onPressed: () => _fetchAiRecommendation(
                                          context,
                                          ref,
                                          poll,
                                          trip.name,
                                          members.length,
                                        ),
                                        icon: const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF6366F1)),
                                        label: const Text('AI Recommend', style: TextStyle(fontSize: 11, color: Color(0xFF6366F1))),
                                      ),
                                    if (!poll.convertedToAction && (totalVotes > 0 || !isActuallyActive))
                                      TextButton.icon(
                                        onPressed: () => _showConvertToActionDialog(
                                          context,
                                          ref,
                                          poll,
                                          currentUserId ?? '',
                                        ),
                                        icon: const Icon(Icons.bolt, size: 14, color: Colors.teal),
                                        label: const Text(
                                          'Convert to Action',
                                          style: TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    if (hasVoted || !isActuallyActive)
                                      TextButton(
                                        onPressed: () => _showPollResults(
                                          context,
                                          poll,
                                          memberMap,
                                        ),
                                        child: const Text('View Results', style: TextStyle(fontSize: 11)),
                                      ),
                                    if (!isActuallyActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          l10n.pollClosed.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    if (isActuallyActive && isCreator)
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, size: 20),
                                        tooltip: l10n.addOption,
                                        onPressed: () => _showAddOptionDialog(
                                          context,
                                          ref,
                                          poll.id,
                                          poll.question,
                                        ),
                                      ),
                                    if (isActuallyActive && isCreator)
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context).colorScheme.error,
                                        ),
                                        onPressed: () => ref.read(pollControllerProvider.notifier).closePoll(
                                              pollId: poll.id,
                                              context: context,
                                            ),
                                        child: Text(l10n.closePoll, style: const TextStyle(fontSize: 11)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.errorWithDetails(e.toString()))),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.errorWithDetails(e.toString()))),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.errorWithDetails(e.toString()))),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String pollId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePoll),
        content: Text(l10n.confirmDeletePoll),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(pollControllerProvider.notifier).deletePoll(
                    pollId: pollId,
                    context: context,
                  );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.deletePoll),
          ),
        ],
      ),
    );
  }

  void _showAddOptionDialog(
    BuildContext context,
    WidgetRef ref,
    String pollId,
    String question,
  ) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addOption),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.pollOptions,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                ref.read(pollControllerProvider.notifier).addOption(
                      pollId: pollId,
                      tripId: tripId,
                      question: question,
                      optionText: text,
                      context: context,
                    );
                Navigator.pop(context);
              }
            },
            child: Text(l10n.addOption),
          ),
        ],
      ),
    );
  }

  void _showPollResults(
    BuildContext context,
    PollModel poll,
    Map<String, String> memberMap,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poll.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: poll.options.length,
                      itemBuilder: (context, index) {
                        final option = poll.options[index];
                        final voters = poll.votes.entries
                            .where((e) => e.value.contains(index))
                            .map((e) => memberMap[e.key] ?? 'Member')
                            .toList();

                        if (voters.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      option.text,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${option.voteCount}',
                                    style: TextStyle(
                                      color: AppPallete.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...voters.map((name) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppPallete.primary.withValues(alpha: 0.1),
                                    child: Text(
                                      name[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppPallete.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                )),
                            const Divider(height: 32),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _fetchAiRecommendation(
    BuildContext context,
    WidgetRef ref,
    PollModel poll,
    String tripName,
    int memberCount,
  ) async {
    showSnackBar(context, 'Analyzing poll options with AI...');
    try {
      final decisionEngine = ref.read(decisionEngineServiceProvider);
      await decisionEngine.generateAiRecommendation(
        poll: poll,
        tripName: tripName,
        totalMembers: memberCount,
      );
      if (context.mounted) {
        showSnackBar(context, 'AI recommendation updated!');
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Could not generate recommendation: $e');
      }
    }
  }

  void _showConvertToActionDialog(
    BuildContext context,
    WidgetRef ref,
    PollModel poll,
    String currentUserId,
  ) {
    if (poll.options.isEmpty) return;

    // Determine leading option by votes
    int winningIndex = 0;
    int maxVotes = -1;
    for (int i = 0; i < poll.options.length; i++) {
      if (poll.options[i].voteCount > maxVotes) {
        maxVotes = poll.options[i].voteCount;
        winningIndex = i;
      }
    }

    final winningOption = poll.options[winningIndex];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bolt, color: Colors.teal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Convert Decision to Action', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Winning Option: "${winningOption.text}" ($maxVotes votes)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: const Text('Add to Trip Itinerary'),
                  subtitle: const Text('Schedule as an activity in the plan'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final decisionEngine = ref.read(decisionEngineServiceProvider);
                      final msg = await decisionEngine.convertDecisionToAction(
                        poll: poll,
                        winningOptionIndex: winningIndex,
                        actionType: DecisionActionType.itineraryActivity,
                        currentUserId: currentUserId,
                      );
                      if (context.mounted) showSnackBar(context, msg);
                    } catch (e) {
                      if (context.mounted) showSnackBar(context, 'Error: $e');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.amber),
                  title: const Text('Create Group Task'),
                  subtitle: const Text('Assign responsibility to take action'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final decisionEngine = ref.read(decisionEngineServiceProvider);
                      final msg = await decisionEngine.convertDecisionToAction(
                        poll: poll,
                        winningOptionIndex: winningIndex,
                        actionType: DecisionActionType.task,
                        currentUserId: currentUserId,
                      );
                      if (context.mounted) showSnackBar(context, msg);
                    } catch (e) {
                      if (context.mounted) showSnackBar(context, 'Error: $e');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
                  title: const Text('Add Budget Commitment'),
                  subtitle: const Text('Reserve expense in the group budget'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final decisionEngine = ref.read(decisionEngineServiceProvider);
                      final msg = await decisionEngine.convertDecisionToAction(
                        poll: poll,
                        winningOptionIndex: winningIndex,
                        actionType: DecisionActionType.budgetCommitment,
                        currentUserId: currentUserId,
                      );
                      if (context.mounted) showSnackBar(context, msg);
                    } catch (e) {
                      if (context.mounted) showSnackBar(context, 'Error: $e');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
