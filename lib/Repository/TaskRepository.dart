// Define the base interface
import '../models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasksByStatus(TaskStatus status);
}
