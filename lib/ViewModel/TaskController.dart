// lib/ViewModel/TaskController.dart

import 'package:flutter/foundation.dart';
import '../Models/Task.dart';
import '../Repository/Repository.dart';

class TaskController extends ChangeNotifier {
  final Repository repository;

  TaskController(this.repository);

  List<Task> _allTasks = [];
  TaskStatus _currentFilter = TaskStatus.all;

  List<Task> get filteredTasks {
    if (_currentFilter == TaskStatus.all) return _allTasks;
    return _allTasks.where((t) => t.status == _currentFilter).toList();
  }

  List<Task> get allTasks => _allTasks;

  TaskStatus get currentFilter => _currentFilter;

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

  // --- MODIFIED FUNCTION ---
  // This no longer needs to be async, as it's updating the in-memory list directly.
  void updateTaskStatus(String taskCode, TaskStatus newStatus) {
    final taskIndex = _allTasks.indexWhere((task) => task.taskCode == taskCode);

    if (taskIndex != -1) {
      final oldTask = _allTasks[taskIndex];
      // Create a new Task instance with the updated status.
      _allTasks[taskIndex] = Task(
        taskName: oldTask.taskName,
        taskCode: oldTask.taskCode,
        fromLocation: oldTask.fromLocation,
        toLocation: oldTask.toLocation,
        itemDescription: oldTask.itemDescription,
        itemCount: oldTask.itemCount,
        startTime: oldTask.startTime,
        deadline: oldTask.deadline,
        status: newStatus, // Apply the new status
        ownerId: oldTask.ownerId,
        confirmationPhoto: oldTask.confirmationPhoto,
        confirmationSign: oldTask.confirmationSign,
      );
      // Notify listening widgets to rebuild.
      notifyListeners();
    }
  }

  void setFilter(TaskStatus status) {
    _currentFilter = status;
    notifyListeners();
  }
}