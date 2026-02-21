import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import 'task_model.dart';

abstract class TaskRepository {
  Future<Either<Failure, TaskModel>> createTask(TaskModel task);
  Future<Either<Failure, void>> deleteTask(String taskId);
  Future<Either<Failure, void>> markTaskComplete({
    required String taskId,
    required String userId,
    required DateTime completedAt,
  });
  Stream<List<TaskModel>> getTasksStream(String tripId);
}
