import 'package:flutter/foundation.dart';
import '../Models/Task.dart';
import '../Repository/Repository.dart';

class TaskController extends ChangeNotifier {
  final Repository repository;

  TaskController(this.repository);

  List<Task> _allTasks = [];
  TaskStatus _currentFilter = TaskStatus.all;
  TaskSort _sort = TaskSort.startTimeAsc;

  List<Task> get filteredTasks {
    List<Task> tasks;
    if (_currentFilter == TaskStatus.all) {
      tasks = List.from(_allTasks);
    } else {
      tasks = _allTasks.where((t) => t.status == _currentFilter).toList();
    }

    tasks.sort((a, b) {
      if (_sort == TaskSort.startTimeAsc) {
        return a.startTime.compareTo(b.startTime);
      } else {
        return b.startTime.compareTo(a.startTime);
      }
    });

    return tasks;
  }

  List<Task> get allTasks => _allTasks;

  TaskStatus get currentFilter => _currentFilter;
  TaskSort get sort => _sort;

  int get pendingTaskCount =>
      _allTasks.where((t) => t.status == TaskStatus.pending).length;

  int get inProgressTaskCount =>
      _allTasks.where((t) => t.status == TaskStatus.inProgress).length;

  int get completedTaskCount =>
      _allTasks.where((t) => t.status == TaskStatus.completed).length;

  Future<void> loadTasksAndSetFilter(TaskStatus status) async {
    try {
      final result = await repository.getTasksByStatus(TaskStatus.all);

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

  // New method to handle the full confirmation process
  void confirmDelivery(String taskCode, String signature, String photoUrl, DateTime completionTime) {
    final taskIndex = _allTasks.indexWhere((task) => task.taskCode == taskCode);

    if (taskIndex != -1) {
      final oldTask = _allTasks[taskIndex];
      _allTasks[taskIndex] = Task(
        taskName: oldTask.taskName,
        taskCode: oldTask.taskCode,
        fromLocation: oldTask.fromLocation,
        toLocation: oldTask.toLocation,
        itemDescription: oldTask.itemDescription,
        itemCount: oldTask.itemCount,
        startTime: oldTask.startTime,
        deadline: oldTask.deadline,
        status: TaskStatus.completed, // Set status to completed
        ownerId: oldTask.ownerId,
        confirmationSign: signature,   // Set signature
        confirmationPhoto: photoUrl,   // Set photo
        completionTime: completionTime, // Set completion time
        customerName: oldTask.customerName,
        partDetails: oldTask.partDetails,
        destinationAddress: oldTask.destinationAddress,
        estimatedDurationMinutes: oldTask.estimatedDurationMinutes,
        specialInstructions: oldTask.specialInstructions,
        deliveryNotes: oldTask.deliveryNotes,
      );
      notifyListeners();
    }
  }

  // Updated this method to preserve new fields
  void updateTaskStatus(String taskCode, TaskStatus newStatus) {
    final taskIndex = _allTasks.indexWhere((task) => task.taskCode == taskCode);

    if (taskIndex != -1) {
      final oldTask = _allTasks[taskIndex];
      _allTasks[taskIndex] = Task(
        taskName: oldTask.taskName,
        taskCode: oldTask.taskCode,
        fromLocation: oldTask.fromLocation,
        toLocation: oldTask.toLocation,
        itemDescription: oldTask.itemDescription,
        itemCount: oldTask.itemCount,
        startTime: oldTask.startTime,
        deadline: oldTask.deadline,
        status: newStatus,
        ownerId: oldTask.ownerId,
        confirmationPhoto: oldTask.confirmationPhoto,
        confirmationSign: oldTask.confirmationSign,
        completionTime: oldTask.completionTime,
        customerName: oldTask.customerName,
        partDetails: oldTask.partDetails,
        destinationAddress: oldTask.destinationAddress,
        estimatedDurationMinutes: oldTask.estimatedDurationMinutes,
        specialInstructions: oldTask.specialInstructions,
        deliveryNotes: oldTask.deliveryNotes,
      );
      notifyListeners();
    }
  }

  void setFilter(TaskStatus status) {
    _currentFilter = status;
    notifyListeners();
  }

  void setSort(TaskSort newSort) {
    if (_sort != newSort) {
      _sort = newSort;
      notifyListeners();
    }
  }
}

