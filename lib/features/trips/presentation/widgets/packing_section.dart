import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/auth_repository_impl.dart';
import '../../domain/packing_item_model.dart';
import '../trip_controller.dart';
import '../trip_planner_controller.dart';
import '../../../circles/presentation/circle_controller.dart';

class PackingSection extends ConsumerStatefulWidget {
  final String tripId;
  const PackingSection({super.key, required this.tripId});

  @override
  ConsumerState<PackingSection> createState() => _PackingSectionState();
}

class _PackingSectionState extends ConsumerState<PackingSection> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitItem(String currentUserId) {
    final title = _textController.text.trim();
    if (title.isEmpty) return;

    ref.read(tripPlannerControllerProvider.notifier).createPackingItem(
          tripId: widget.tripId,
          title: title,
          context: context,
        );

    _textController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final packingAsync = ref.watch(tripPackingProvider(widget.tripId));
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final currentUserAsync = ref.watch(authStateChangesProvider);
    final currentUserId = currentUserAsync.value?.uid ?? '';
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: packingAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'Packing list is empty. Add items below!',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                );
              }

              return tripAsync.when(
                data: (trip) {
                  final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
                  return membersAsync.when(
                    data: (members) {
                      final memberMap = {for (final m in members) m.uid: m.displayName};
                      final sortedItems = List<PackingItemModel>.from(items)
                        ..sort((a, b) {
                          if (a.isPacked != b.isPacked) {
                            return a.isPacked ? 1 : -1;
                          }
                          return b.createdAt.compareTo(a.createdAt);
                        });

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sortedItems.length,
                        itemBuilder: (context, index) {
                          final item = sortedItems[index];
                          final assigneeName = item.assignedTo != null
                              ? (memberMap[item.assignedTo!] ?? 'Member')
                              : null;

                          return _buildPackingItemRow(context, item, assigneeName, members, currentUserId, theme);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text(e.toString())),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
          ),
        ),
        _buildBottomInput(currentUserId),
      ],
    );
  }

  Widget _buildPackingItemRow(
    BuildContext context,
    PackingItemModel item,
    String? assigneeName,
    List<dynamic> members,
    String currentUserId,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: item.isPacked,
          onChanged: (val) {
            if (val != null) {
              ref.read(tripPlannerControllerProvider.notifier).togglePackingItem(
                    itemId: item.id,
                    isPacked: val,
                    context: context,
                  );
            }
          },
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: item.isPacked ? TextDecoration.lineThrough : null,
            color: item.isPacked ? Colors.grey : null,
          ),
        ),
        subtitle: _buildAssigneeBadge(context, item, assigneeName, members, currentUserId, theme),
        trailing: IconButton(
          onPressed: () {
            ref.read(tripPlannerControllerProvider.notifier).deletePackingItem(
                  itemId: item.id,
                  context: context,
                );
          },
          icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 20),
        ),
      ),
    );
  }

  Widget _buildAssigneeBadge(
    BuildContext context,
    PackingItemModel item,
    String? assigneeName,
    List<dynamic> members,
    String currentUserId,
    ThemeData theme,
  ) {
    if (assigneeName != null) {
      // Show assigned member with change option
      return GestureDetector(
        onTap: () => _showAssigneePicker(context, item, members),
        child: Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, size: 12, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                'Bringing: $assigneeName',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 12, color: Colors.grey),
            ],
          ),
        ),
      );
    }

    // Unassigned. Show Claim and Assign buttons
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              ref.read(tripPlannerControllerProvider.notifier).assignPackingItem(
                    itemId: item.id,
                    userId: currentUserId,
                    context: context,
                  );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pan_tool_outlined, size: 10, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    'Claim Item',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showAssigneePicker(context, item, members),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1_outlined, size: 10, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Assign',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssigneePicker(BuildContext context, PackingItemModel item, List<dynamic> members) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Assign Item'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: members.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.person_off_outlined),
                  title: const Text('Unassigned / No one'),
                  onTap: () {
                    ref.read(tripPlannerControllerProvider.notifier).assignPackingItem(
                          itemId: item.id,
                          userId: null,
                          context: context,
                        );
                    Navigator.pop(dialogCtx);
                  },
                );
              }

              final member = members[index - 1];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(member.displayName),
                onTap: () {
                  ref.read(tripPlannerControllerProvider.notifier).assignPackingItem(
                        itemId: item.id,
                        userId: member.uid,
                        context: context,
                      );
                  Navigator.pop(dialogCtx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInput(String currentUserId) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add an item to pack...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.1),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onSubmitted: (_) => _submitItem(currentUserId),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => _submitItem(currentUserId),
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
