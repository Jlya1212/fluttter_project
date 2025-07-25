import '../models/task.dart';
import '../Repository/TaskRepository.dart';
import '../common/Result.dart';

class TaskController {
  final TaskRepository repository;

  TaskController(this.repository);

  // 1. Create a new task
  Future<Result<void>> createTask(Task task) async {
    try {
      final result = await repository.addTask(task);
      if (result.isSuccess) {
        return Result.success(null);
      } else {
        return Result.failure(result.errorMessage ?? 'Unknown error');
      }
    } catch (e) {
      return Result.failure('Controller failed to create task: ${e.toString()}');
    }
  }

  // 2. Get tasks by status
  Future<Result<List<Task>>> getTasksByStatus(TaskStatus status) async {
    try {
      return await repository.getTasksByStatus(status);
    } catch (e) {
      return Result.failure('Controller failed to fetch tasks: ${e.toString()}');
    }
  }

  // 3. Update an existing task
  Future<Result<void>> updateTask(Task task) async {
    try {
      return await repository.updateTask(task);
    } catch (e) {
      return Result.failure('Controller failed to update task: ${e.toString()}');
    }
  }

  // 4. Delete a task by code
  Future<Result<void>> deleteTask(String taskCode) async {
    try {
      return await repository.deleteTask(taskCode);
    } catch (e) {
      return Result.failure('Controller failed to delete task: ${e.toString()}');
    }
  }
}
