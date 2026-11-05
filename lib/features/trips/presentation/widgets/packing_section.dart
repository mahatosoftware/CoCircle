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
  int _selectedCategoryIndex = 0;

  // Available Categories
  static const List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'tag': null, 'icon': Icons.all_inclusive_rounded, 'color': Colors.blue},
    {'label': 'Clothing', 'tag': '#clothing', 'icon': Icons.checkroom_rounded, 'color': Colors.teal},
    {'label': 'Electronics', 'tag': '#electronics', 'icon': Icons.power_rounded, 'color': Colors.purple},
    {'label': 'Documents', 'tag': '#documents', 'icon': Icons.assignment_rounded, 'color': Colors.red},
    {'label': 'Essentials', 'tag': '#essentials', 'icon': Icons.favorite_rounded, 'color': Colors.amber},
    {'label': 'General', 'tag': '#general', 'icon': Icons.backpack_rounded, 'color': Colors.grey},
  ];

  String _getCategoryFromTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('#clothing') || lower.contains('#clothes')) return '#clothing';
    if (lower.contains('#electronics') || lower.contains('#tech') || lower.contains('#electronic')) return '#electronics';
    if (lower.contains('#documents') || lower.contains('#docs') || lower.contains('#document')) return '#documents';
    if (lower.contains('#essentials') || lower.contains('#essential')) return '#essentials';
    return '#general';
  }

  String _cleanTitle(String title) {
    return title
        .replaceAll(RegExp(r'#(clothing|clothes|electronics|tech|electronic|documents|docs|document|essentials|essential|general)', caseSensitive: false), '')
        .trim();
  }

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

  Widget _buildCategoryTabBar(ThemeData theme, List<PackingItemModel> items) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryIndex == index;
          final color = category['color'] as Color;
          
          // Count items in this category
          final tag = category['tag'];
          final count = tag == null
              ? items.length
              : items.where((item) => _getCategoryFromTitle(item.title) == tag).length;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: isSelected,
              label: Row(
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 14,
                    color: isSelected ? Colors.white : color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    category['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ),
                ],
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategoryIndex = index);
                }
              },
              selectedColor: color,
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              checkmarkColor: Colors.white,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? color : Colors.grey.withValues(alpha: 0.15),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryBadge(PackingItemModel item, ThemeData theme) {
    final tag = _getCategoryFromTitle(item.title);
    if (tag == '#general') return const SizedBox.shrink();
    
    final category = _categories.firstWhere((c) => c['tag'] == tag, orElse: () => _categories.last);
    final color = category['color'] as Color;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        category['label'] as String,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
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

              return Column(
                children: [
                  _buildCategoryTabBar(theme, items),
                  Expanded(
                    child: tripAsync.when(
                      data: (trip) {
                        final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
                        return membersAsync.when(
                          data: (members) {
                            final memberMap = {for (final m in members) m.uid: m.displayName};
                            
                            // Filter items by category
                            final categoryTag = _categories[_selectedCategoryIndex]['tag'];
                            final filteredItems = categoryTag == null
                                ? items
                                : items.where((item) => _getCategoryFromTitle(item.title) == categoryTag).toList();

                            final sortedItems = List<PackingItemModel>.from(filteredItems)
                              ..sort((a, b) {
                                if (a.isPacked != b.isPacked) {
                                  return a.isPacked ? 1 : -1;
                                }
                                return b.createdAt.compareTo(a.createdAt);
                              });

                            if (sortedItems.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.backpack_outlined,
                                      size: 48,
                                      color: Colors.grey.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No items in ${_categories[_selectedCategoryIndex]['label']}',
                                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }

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
                    ),
                  ),
                ],
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
        title: Row(
          children: [
            Expanded(
              child: Text(
                _cleanTitle(item.title),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: item.isPacked ? TextDecoration.lineThrough : null,
                  color: item.isPacked ? Colors.grey : null,
                ),
              ),
            ),
            _buildCategoryBadge(item, theme),
          ],
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
    final theme = Theme.of(context);
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
              const SizedBox(width: 4),
              // Category Picker Dropdown
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.label_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'Select Category Tag',
                onSelected: (tag) {
                  final text = _textController.text;
                  if (tag.isNotEmpty && !text.toLowerCase().contains(tag.toLowerCase())) {
                    _textController.text = '$text $tag'.trim();
                    _textController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _textController.text.length),
                    );
                    _focusNode.requestFocus();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return _categories
                      .where((c) => c['tag'] != null) // skip "All"
                      .map((category) {
                    final tag = category['tag'] as String;
                    final label = category['label'] as String;
                    final icon = category['icon'] as IconData;
                    final color = category['color'] as Color;

                    return PopupMenuItem<String>(
                      value: tag,
                      child: Row(
                        children: [
                          Icon(icon, size: 18, color: color),
                          const SizedBox(width: 8),
                          Text(label, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
              const SizedBox(width: 4),
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
