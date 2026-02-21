import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../trips/presentation/trip_controller.dart';
import '../domain/task_model.dart';
import 'task_controller.dart';

class TaskListView extends ConsumerWidget {
  final String tripId;

  const TaskListView({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tripTasksProvider(tripId));
    final tripAsync = ref.watch(tripDetailsProvider(tripId));

    return tasksAsync.when(
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
                      return _TaskHeader(
                        onCreatePressed: () => _showCreateTaskDialog(context, ref),
                      );
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
    );
  }

  void _showCreateTaskDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Task title',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            final title = controller.text.trim();
            if (title.isEmpty) return;
            ref.read(taskControllerProvider.notifier).createTask(
                  tripId: tripId,
                  title: title,
                  context: context,
                );
            Navigator.of(dialogContext).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isEmpty) return;
              ref.read(taskControllerProvider.notifier).createTask(
                    tripId: tripId,
                    title: title,
                    context: context,
                  );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Create'),
          ),
        ],
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
  final VoidCallback onCreatePressed;

  const _TaskHeader({required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tasks',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            tooltip: 'Create task',
            onPressed: onCreatePressed,
            icon: const Icon(Icons.add_task_outlined),
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
