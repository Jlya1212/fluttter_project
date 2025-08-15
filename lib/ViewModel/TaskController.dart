// lib/ViewModel/TaskController.dart

import 'package:flutter/foundation.dart';
import '../Models/Task.dart';
import '../Repository/Repository.dart';

enum TaskSort { startTimeAsc, startTimeDesc }

class TaskController extends ChangeNotifier {
  final Repository repository;
  TaskController(this.repository);

  // 1) Canonical source of truth: ALL tasks.
  List<Task> _allTasksRaw = [];

  // 2) Current UI state: filter + sort.
  TaskStatus _currentFilter = TaskStatus.all;
  TaskSort _sort = TaskSort.startTimeAsc;

  // ---------------- Getters ----------------

  /// Tasks after applying current filter and sort.
  List<Task> get filteredTasks {
    final Iterable<Task> filtered = _currentFilter == TaskStatus.all
        ? _allTasksRaw
        : _allTasksRaw.where((t) => t.status == _currentFilter);

    // Return a sorted copy so we don't mutate the raw list order.
    final List<Task> sorted = List<Task>.from(filtered);
    sorted.sort((a, b) {
      final cmp = a.startTime.compareTo(b.startTime);
      return _sort == TaskSort.startTimeAsc ? cmp : -cmp;
    });
    return sorted;
  }

  /// Expose all tasks for tab badges to count properly.
  List<Task> get allTasks => _allTasksRaw;

  TaskStatus get currentFilter => _currentFilter;
  TaskSort get sort => _sort;

  int get pendingTaskCount =>
      _allTasksRaw.where((t) => t.status == TaskStatus.pending).length;

  int get inProgressTaskCount =>
      _allTasksRaw.where((t) => t.status == TaskStatus.inProgress).length;

  int get completedTaskCount =>
      _allTasksRaw.where((t) => t.status == TaskStatus.completed).length;

  // ---------------- Commands ----------------

  /// Load all tasks, then apply a UI filter.
  /// Assumption: repository can return all tasks when asked with TaskStatus.all.
  Future<void> loadTasksAndSetFilter(TaskStatus status) async {
    try {
      // Always fetch ALL tasks so counts and filters remain consistent.
      final result = await repository.getTasksByStatus(TaskStatus.all);

      if (result.isSuccess) {
        _allTasksRaw = result.data ?? [];
        _currentFilter = status;
        notifyListeners();
      } else {
        if (kDebugMode) {
          print("Load failed: ${result.errorMessage}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Controller failed to fetch tasks: ${e.toString()}');
      }
    }
  }

  /// Update a single task's status in-place.
  void updateTaskStatus(String taskCode, TaskStatus newStatus) {
    final idx = _allTasksRaw.indexWhere((task) => task.taskCode == taskCode);
    if (idx != -1) {
      final old = _allTasksRaw[idx];
      _allTasksRaw[idx] = Task(
        taskName: old.taskName,
        taskCode: old.taskCode,
        fromLocation: old.fromLocation,
        toLocation: old.toLocation,
        itemDescription: old.itemDescription,
        itemCount: old.itemCount,
        startTime: old.startTime,
        deadline: old.deadline,
        status: newStatus,
        ownerId: old.ownerId,
        confirmationPhoto: old.confirmationPhoto,
        confirmationSign: old.confirmationSign,
      );
      notifyListeners();
    }
  }

  /// Just switch the filter; data is already in memory.
  void setFilter(TaskStatus status) {
    _currentFilter = status;
    notifyListeners();
  }

  /// Set sort order and refresh listeners.
  void setSort(TaskSort newSort) {
    if (_sort != newSort) {
      _sort = newSort;
      notifyListeners();
    }
  }
}
