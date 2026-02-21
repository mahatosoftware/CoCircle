import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../trips/presentation/trip_controller.dart';
import '../domain/task_model.dart';
import 'task_controller.dart';

class TaskListView extends ConsumerStatefulWidget {
  final String tripId;

  const TaskListView({super.key, required this.tripId});

  @override
  ConsumerState<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends ConsumerState<TaskListView> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

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
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tasks.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return const _TaskHeader();
                          }

                          final task = tasks[index - 1];
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

  Widget _buildBottomInput() {
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
                  controller: _controller,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add a task...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.1),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onSubmitted: (_) => _submitTask(),
                ),

              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _submitTask,
                icon: const Icon(Icons.send_rounded),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TaskHeader extends StatelessWidget {
  const _TaskHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(4, 0, 0, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tasks',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    final subtitle = task.isCompleted && completedAt != null
        ? 'Completed by ${completedByName ?? 'Member'} on ${DateFormat.MMMd().add_jm().format(completedAt)}'
        : 'Pending';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: task.isCompleted ? null : (_) => onMarkComplete(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: IconButton(
          tooltip: 'Delete task',
          onPressed: onDelete,
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}

