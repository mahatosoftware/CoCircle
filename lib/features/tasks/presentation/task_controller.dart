import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/snackbar.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../data/task_repository_impl.dart';
import '../domain/task_model.dart';
import '../domain/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(FirebaseFirestore.instance);
});

class TaskController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> createTask({
    required String tripId,
    required String title,
    required BuildContext context,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;

    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      showSnackBar(context, 'User not logged in');
      return;
    }

    state = const AsyncLoading();
    final task = TaskModel(
      id: const Uuid().v4(),
      tripId: tripId,
      title: trimmedTitle,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final result = await ref.read(taskRepositoryProvider).createTask(task);
    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        showSnackBar(context, failure.message);
      },
      (_) {
        state = const AsyncData(null);
        showSnackBar(context, 'Task created');
      },
    );
  }

  Future<void> deleteTask({
    required String taskId,
    required BuildContext context,
  }) async {
    final result = await ref.read(taskRepositoryProvider).deleteTask(taskId);
    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) => showSnackBar(context, 'Task deleted'),
    );
  }

  Future<void> markTaskComplete({
    required TaskModel task,
    required BuildContext context,
  }) async {
    if (task.isCompleted) return;

    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      showSnackBar(context, 'User not logged in');
      return;
    }

    final result = await ref.read(taskRepositoryProvider).markTaskComplete(
          taskId: task.id,
          userId: user.uid,
          completedAt: DateTime.now(),
        );

    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) => showSnackBar(context, 'Task completed'),
    );
  }
}

final taskControllerProvider = NotifierProvider<TaskController, AsyncValue<void>>(TaskController.new);

final tripTasksProvider = StreamProvider.family<List<TaskModel>, String>((ref, tripId) {
  return ref.watch(taskRepositoryProvider).getTasksStream(tripId).map((tasks) {
    final sorted = List<TaskModel>.from(tasks)
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        if (!a.isCompleted && !b.isCompleted) {
          return b.createdAt.compareTo(a.createdAt);
        }
        final aTime = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
    return sorted;
  });
});
