import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ai/ai_provider.dart';
import '../../../core/ai/domain/ai_models.dart';
import '../../../core/theme/app_pallete.dart';
import '../../../core/utils/snackbar.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../trips/data/trip_planner_repository_impl.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../tasks/data/task_repository_impl.dart';
import '../../polls/data/poll_repository_impl.dart';
import '../data/copilot_service.dart';
import '../domain/copilot_models.dart';

final copilotServiceProvider = Provider<CopilotService>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final tripPlannerRepo = ref.watch(tripPlannerRepositoryProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);
  final pollRepo = ref.watch(pollRepositoryProvider);

  return CopilotService(
    aiService: aiService,
    tripPlannerRepository: tripPlannerRepo,
    taskRepository: taskRepo,
    pollRepository: pollRepo,
  );
});

class CoCircleMagicSheet extends ConsumerStatefulWidget {
  final String tripId;

  const CoCircleMagicSheet({super.key, required this.tripId});

  static Future<void> show(BuildContext context, String tripId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CoCircleMagicSheet(tripId: tripId),
    );
  }

  @override
  ConsumerState<CoCircleMagicSheet> createState() => _CoCircleMagicSheetState();
}

class _CoCircleMagicSheetState extends ConsumerState<CoCircleMagicSheet> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<CopilotMessage> _messages = [];
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    'Plan a 3-day trip with ₹8,000/person budget',
    'Organize a birthday celebration for the group',
    'Create a hotel selection poll',
    'Generate packing and prep tasks',
    'Who has unpaid balances or pending expenses?',
    'Summarize our trip plan and budget',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      CopilotMessage(
        role: AiRole.assistant,
        content:
            'Hello! I am **CoCircle Magic**, your AI Group Life Assistant. ✨\n\nTell me what you\'d like to plan, decide, or track for this group. I can generate complete itineraries, allocate budgets, draft polls, and create tasks for everyone to review!',
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? presetText]) async {
    final text = (presetText ?? _inputController.text).trim();
    if (text.isEmpty || _isLoading) return;

    _inputController.clear();
    setState(() {
      _messages.add(CopilotMessage(role: AiRole.user, content: text));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final trip = await ref.read(tripDetailsProvider(widget.tripId).future);
      final members = await ref.read(circleMembersProvider(trip.circleId).future);
      final memberNames = members.map((m) => m.displayName.isNotEmpty ? m.displayName : 'Member').toList();

      final copilot = ref.read(copilotServiceProvider);
      final responseMessage = await copilot.processPrompt(
        prompt: text,
        tripId: widget.tripId,
        tripName: trip.name,
        startDate: trip.startDate,
        location: trip.location,
        memberNames: memberNames,
        totalExpenses: trip.totalExpenses,
      );

      if (mounted) {
        setState(() {
          _messages.add(responseMessage);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            CopilotMessage(
              role: AiRole.assistant,
              content: 'Sorry, I ran into an error: $e',
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _approveProposal(CopilotProposal proposal) async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      if (mounted) showSnackBar(context, 'Please log in to apply changes.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final trip = await ref.read(tripDetailsProvider(widget.tripId).future);
      final startDate = trip.startDate ?? DateTime.now();

      final copilot = ref.read(copilotServiceProvider);
      final counts = await copilot.commitProposal(
        tripId: widget.tripId,
        userId: user.uid,
        tripStartDate: startDate,
        proposal: proposal,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          proposal.isApproved = true;
        });
        showSnackBar(
          context,
          '✨ Applied: ${counts['itinerary']} activities, ${counts['tasks']} tasks, ${counts['polls']} polls, and budget saved!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showSnackBar(context, 'Failed to commit proposal: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CoCircle Magic',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'AI Group Life Assistant • Review before applying',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Quick prompt chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return ActionChip(
                  label: Text(
                    prompt,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: _isLoading ? null : () => _handleSend(prompt),
                );
              },
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == AiRole.user;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment:
                        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser) ...[
                            const CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(0xFF6366F1),
                              child: Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? AppPallete.primary
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16).copyWith(
                                  bottomRight: isUser ? const Radius.circular(2) : null,
                                  bottomLeft: !isUser ? const Radius.circular(2) : null,
                                ),
                              ),
                              child: Text(
                                msg.content,
                                style: TextStyle(
                                  color: isUser ? Colors.white : theme.colorScheme.onSurface,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Proposal card if generated
                      if (msg.proposal != null) ...[
                        const SizedBox(height: 10),
                        _buildProposalCard(context, msg.proposal!),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'CoCircle Magic is drafting your plan...',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Ask CoCircle Magic to plan, decide, or split...',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isLoading ? null : () => _handleSend(),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                    ),
                    icon: const Icon(Icons.arrow_upward, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalCard(BuildContext context, CopilotProposal proposal) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 36),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: Color(0xFF6366F1), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  proposal.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              if (proposal.isApproved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Applied ✓',
                    style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          if (proposal.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              proposal.description,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),

          // Total budget badge
          if (proposal.totalEstimatedBudget != null && proposal.totalEstimatedBudget! > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Estimated Budget:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(
                    '₹${proposal.totalEstimatedBudget!.toStringAsFixed(0)} ${proposal.perPersonBudget != null ? "(₹${proposal.perPersonBudget!.toStringAsFixed(0)}/person)" : ""}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                  ),
                ],
              ),
            ),

          // Category budgets
          if (proposal.budgetItems.isNotEmpty) ...[
            const Text('Budget Breakdown:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: proposal.budgetItems.map((b) {
                return Chip(
                  label: Text('${b.category}: ₹${b.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11)),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],

          // Itinerary items
          if (proposal.itinerary.isNotEmpty) ...[
            Text('Activities (${proposal.itinerary.length}):', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 6),
            ...proposal.itinerary.take(4).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Color(0xFF6366F1)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Day ${item.dayOffset + 1} (${item.startHour}:${item.startMinute.toString().padLeft(2, '0')}) - ${item.title}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.estimatedCost != null && item.estimatedCost! > 0)
                      Text('₹${item.estimatedCost!.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              );
            }),
            if (proposal.itinerary.length > 4)
              Text('+ ${proposal.itinerary.length - 4} more activities', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 10),
          ],

          // Polls
          if (proposal.polls.isNotEmpty) ...[
            Text('Proposed Polls (${proposal.polls.length}):', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 4),
            ...proposal.polls.map((p) => Text('• ${p.question} (${p.options.join(", ")})', style: const TextStyle(fontSize: 12, color: Colors.blueGrey))),
            const SizedBox(height: 10),
          ],

          // Tasks
          if (proposal.tasks.isNotEmpty) ...[
            Text('Proposed Tasks (${proposal.tasks.length}):', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 4),
            ...proposal.tasks.map((t) => Text('• ${t.title} ${t.assignedRole != null ? "(${t.assignedRole})" : ""}', style: const TextStyle(fontSize: 12))),
            const SizedBox(height: 10),
          ],

          // Action button
          if (!proposal.isApproved)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _approveProposal(proposal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Approve & Add to Group', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
