import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../Repository/TaskRepository.dart';
import '../common/Result.dart';

class TaskController extends ChangeNotifier {
  final TaskRepository repository;

  TaskController(this.repository);

  List<Task> _allTasks = [];
  TaskStatus _currentFilter = TaskStatus.all;

  List<Task> get filteredTasks {
    if (_currentFilter == TaskStatus.all) return _allTasks;
    return _allTasks.where((t) => t.status == _currentFilter).toList();
  }

  List<Task> get allTasks => _allTasks;

  TaskStatus? get currentFilter => _currentFilter;

  Future<void> loadTasksAndSetFilter(TaskStatus status) async {
    try {

      final result = await repository.getTasksByStatus(status);
      
      if (result.isSuccess) {
        _allTasks = result.data ?? [];
        _currentFilter = status;
        notifyListeners();
      } else {
        print("Load failed: ${result.errorMessage}");
      }
    } catch (e) {
      print('Controller failed to fetch tasks: ${e.toString()}');
    }
  }

  void setFilter(TaskStatus status) {
    _currentFilter = status;
    notifyListeners();
  }

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
      return Result.failure(
        'Controller failed to create task: ${e.toString()}',
      );
    }
  }

  // 3. Update an existing task
  Future<Result<void>> updateTask(Task task) async {
    try {
      return await repository.updateTask(task);
    } catch (e) {
      return Result.failure(
        'Controller failed to update task: ${e.toString()}',
      );
    }
  }
}
