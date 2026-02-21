import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../domain/task_model.dart';
import '../domain/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, TaskModel>> createTask(TaskModel task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).set(task.toJson());
      return right(task);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markTaskComplete({
    required String taskId,
    required String userId,
    required DateTime completedAt,
  }) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'isCompleted': true,
        'completedBy': userId,
        'completedAt': Timestamp.fromDate(completedAt),
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<TaskModel>> getTasksStream(String tripId) {
    return _firestore
        .collection('tasks')
        .where('tripId', isEqualTo: tripId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList());
  }
}
