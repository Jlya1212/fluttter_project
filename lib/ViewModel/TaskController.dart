import 'package:flutter/foundation.dart';
import '../Models/Task.dart';
import '../Repository/Repository.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
      switch (_sort) {
        case TaskSort.startTimeAsc:
          return a.startTime.compareTo(b.startTime);
        case TaskSort.startTimeDesc:
          return b.startTime.compareTo(a.startTime);
        case TaskSort.deadlineAsc:
          return a.deadline.compareTo(b.deadline);
        case TaskSort.deadlineDesc:
          return b.deadline.compareTo(a.deadline);
      }
    });

    return tasks;
  }

  List<Task> get allTasks => _allTasks;

  TaskStatus get currentFilter => _currentFilter;
  TaskSort get sort => _sort;

  int get pendingTaskCount =>
      _allTasks.where((t) => t.status == TaskStatus.pending).length;

  int get pickedUpTaskCount =>
      _allTasks.where((t) => t.status == TaskStatus.pickedUp).length;

  int get inProgressTaskCount =>
      _allTasks.where((t) => t.status == TaskStatus.inProgress).length;

  int get completedTaskCount =>
      _allTasks.where((t) => t.status == TaskStatus.completed).length;


  Task? get nextTask {
    // Filter for tasks that are not yet completed
    final upcomingTasks = _allTasks
        .where((task) => task.status == TaskStatus.pending || task.status == TaskStatus.pickedUp)
        .toList();

    // Sort them by start time to find the earliest one
    upcomingTasks.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Return the first one, or null if there are no upcoming tasks
    return upcomingTasks.isNotEmpty ? upcomingTasks.first : null;
  }

  double get completionPercentage {
    if (_allTasks.isEmpty) {
      return 0.0;
    }
    return completedTaskCount / _allTasks.length;
  }

  Future<void> loadTasksAndSetFilter(TaskStatus status , String? assignDriverName,) async {
    try {
      final result = await repository.getTasksByStatus(TaskStatus.all , assignDriverName!);

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

  Future<void> confirmDelivery(
      String taskCode,
      Uint8List? mechanicSignature,
      Uint8List? deliverySignature,
      String? photoBase64,
      DateTime completionTime,
      ) async {

    final result = await repository.confirmDelivery(
      taskCode,
      mechanicSignature,
      deliverySignature,
      photoBase64,
      completionTime,
    );

    if (result.isSuccess) {
      int index = allTasks.indexWhere((t) => t.taskCode == taskCode);
      if (index != -1) {
        Task oldTask = allTasks[index];
        allTasks[index] = Task(
          taskName: oldTask.taskName,
          taskCode: oldTask.taskCode,
          fromLocation: oldTask.fromLocation,
          toLocation: oldTask.toLocation,
          itemDescription: oldTask.itemDescription,
          itemCount: oldTask.itemCount,
          startTime: oldTask.startTime,
          deadline: oldTask.deadline,
          status: TaskStatus.completed,
          ownerId: oldTask.ownerId,
          mechanicSignature: mechanicSignature,
          deliverySignature: deliverySignature,
          completionTime: completionTime,
          lastUpdated: DateTime.now(),
          customerName: oldTask.customerName,
          partDetails: oldTask.partDetails,
          destinationAddress: oldTask.destinationAddress,
          estimatedDurationMinutes: oldTask.estimatedDurationMinutes,
          specialInstructions: oldTask.specialInstructions,
          deliveryNotes: oldTask.deliveryNotes,
          photoBase64: photoBase64,
        );
        notifyListeners();
      }
    }

  }


  // Updated this method to preserve new fields
  Future<void> updateTaskStatus(String taskCode, TaskStatus newStatus) async {
    try {
      // Update in Firebase first
      final result = await repository.updateTaskStatus(taskCode, newStatus);
      if (result.isSuccess) {
        // Update local state
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
            mechanicSignature: oldTask.mechanicSignature,
            deliverySignature: oldTask.deliverySignature,
            completionTime: oldTask.completionTime,
            lastUpdated: DateTime.now(),
            customerName: oldTask.customerName,
            partDetails: oldTask.partDetails,
            destinationAddress: oldTask.destinationAddress,
            estimatedDurationMinutes: oldTask.estimatedDurationMinutes,
            specialInstructions: oldTask.specialInstructions,
            deliveryNotes: oldTask.deliveryNotes,
          );
          notifyListeners();
        }
      } else {
        print("Failed to update task status: ${result.errorMessage}");
      }
    } catch (e) {
      print('Controller failed to update task status: ${e.toString()}');
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

  Task? getTaskByCode(String code) {
    try {
      return _allTasks.firstWhere((t) => t.taskCode == code);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateTaskDeliveryTime(String taskCode, DateTime deliveryTime) async {
    try {
      final result = await repository.updateTaskDeliveryTime(taskCode, deliveryTime);
      if (result.isSuccess) {
        // Update local state
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
            status: oldTask.status,
            ownerId: oldTask.ownerId,
            mechanicSignature: oldTask.mechanicSignature,
            deliverySignature: oldTask.deliverySignature,
            completionTime: oldTask.completionTime,
            customerName: oldTask.customerName,
            partDetails: oldTask.partDetails,
            destinationAddress: oldTask.destinationAddress,
            estimatedDurationMinutes: oldTask.estimatedDurationMinutes,
            specialInstructions: oldTask.specialInstructions,
            deliveryNotes: oldTask.deliveryNotes,
            photoBase64: oldTask.photoBase64,
            assignDriverName: oldTask.assignDriverName,
            deliveryTime: deliveryTime,
          );
          notifyListeners();
        }
      } else {
        print("Failed to update task delivery time: ${result.errorMessage}");
      }
    } catch (e) {
      print('Controller failed to update task delivery time: ${e.toString()}');
    }
  }
}