import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../trips/presentation/trip_controller.dart';
import '../domain/task_model.dart';
import 'task_controller.dart';

enum TaskFilter { all, pending, completed }

class TaskListView extends ConsumerStatefulWidget {
  final String tripId;

  const TaskListView({super.key, required this.tripId});

  @override
  ConsumerState<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends ConsumerState<TaskListView> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  TaskFilter _filter = TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitTask() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    ref.read(taskControllerProvider.notifier).createTask(
          tripId: widget.tripId,
          title: title,
          context: context,
        );
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tripTasksProvider(widget.tripId));
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));

    return Column(
      children: [
        Expanded(
          child: tasksAsync.when(
            data: (tasks) {
              return tripAsync.when(
                data: (trip) {
                  final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
                  return membersAsync.when(
                    data: (members) {
                      final memberMap = {for (final m in members) m.uid: m.displayName};

                      final completedTasks = tasks.where((t) => t.isCompleted).length;
                      final totalTasks = tasks.length;
                      final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

                      final filteredTasks = tasks.where((t) {
                        switch (_filter) {
                          case TaskFilter.all:
                            return true;
                          case TaskFilter.pending:
                            return !t.isCompleted;
                          case TaskFilter.completed:
                            return t.isCompleted;
                        }
                      }).toList();

                      return CustomScrollView(
                        slivers: [
                          // Header + Progress Banner + Filter Chips
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Progress Card
                                  if (totalTasks > 0)
                                    Card(
                                      elevation: 0,
                                      color: Colors.grey.withValues(alpha: 0.06),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  'Trip Preparation Checklist',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                ),
                                                Text(
                                                  '$completedTasks of $totalTasks completed',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppPallete.primary, fontSize: 13),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: LinearProgressIndicator(
                                                value: completionRate,
                                                minHeight: 8,
                                                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  completionRate == 1.0 ? AppPallete.tertiary : AppPallete.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),

                                  // Filter Chips
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildFilterChip(TaskFilter.all, 'All (${tasks.length})'),
                                        const SizedBox(width: 8),
                                        _buildFilterChip(TaskFilter.pending, 'Pending (${tasks.where((t) => !t.isCompleted).length})'),
                                        const SizedBox(width: 8),
                                        _buildFilterChip(TaskFilter.completed, 'Completed ($completedTasks)'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),

                          // Tasks List or Empty State
                          if (filteredTasks.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: EmptyStateWidget(
                                icon: Icons.checklist_rounded,
                                title: _filter == TaskFilter.completed
                                    ? 'No completed tasks yet'
                                    : _filter == TaskFilter.pending
                                        ? 'All caught up!'
                                        : 'No tasks added yet',
                                description: _filter == TaskFilter.all
                                    ? 'Add checklists, prep to-dos, or gear checks below.'
                                    : 'Tasks matching this filter will show here.',
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final task = filteredTasks[index];
                                    return _TaskCard(
                                      task: task,
                                      completedByName: task.completedBy != null
                                          ? (memberMap[task.completedBy!] ?? 'Member')
                                          : null,
                                      onMarkComplete: () => ref
                                          .read(taskControllerProvider.notifier)
                                          .markTaskComplete(task: task, context: context),
                                      onDelete: () => _showDeleteConfirmation(context, ref, task),
                                    );
                                  },
                                  childCount: filteredTasks.length,
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 16),
                          ),
                        ],
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
        _buildBottomInput(),
      ],
    );
  }

  Widget _buildFilterChip(TaskFilter filter, String label) {
    final isSelected = _filter == filter;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _filter = filter);
      },
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

  Widget _buildBottomInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add a new trip task or to-do...',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.08),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _submitTask(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _submitTask,
                style: IconButton.styleFrom(
                  backgroundColor: AppPallete.primary,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, TaskModel task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(taskControllerProvider.notifier).deleteTask(
                    taskId: task.id,
                    context: context,
                  );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final String? completedByName;
  final VoidCallback onMarkComplete;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.completedByName,
    required this.onMarkComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final completedAt = task.completedAt;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isCompleted
              ? const Color(0xFFA7F3D0)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      color: task.isCompleted ? const Color(0xFFF0FDF4) : Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: task.isCompleted,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                activeColor: AppPallete.tertiary,
                onChanged: task.isCompleted ? null : (_) => onMarkComplete(),
              ),
            ),
            const SizedBox(width: 8),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey.shade600 : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (task.isCompleted)
                        StatusBadge.success(
                          label: completedByName != null ? 'Done by $completedByName' : 'Completed',
                          icon: Icons.check_circle_rounded,
                        )
                      else
                        StatusBadge.warning(label: 'Pending', icon: Icons.schedule_rounded),
                      if (completedAt != null && task.isCompleted) ...[
                        const SizedBox(width: 8),
                        Text(
                          DateFormat.MMMd().add_jm().format(completedAt),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Delete
            IconButton(
              tooltip: 'Delete task',
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
