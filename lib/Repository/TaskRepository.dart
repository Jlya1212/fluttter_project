// Define the base interface
import '../models/task.dart';
import '../common/Result.dart';

abstract class TaskRepository {
  Future<Result<List<Task>>> getTasksByStatus(TaskStatus status); // ✅ change this
  Future<Result<Task>> addTask(Task task);
  Future<Result<Task>> updateTask(Task task);
  Future<Result<Task>> deleteTask(String taskCode);
}
