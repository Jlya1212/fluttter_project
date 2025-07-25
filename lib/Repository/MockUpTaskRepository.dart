import 'dart:async';
import 'TaskRepository.dart';
import '../models/task.dart';
import '../common/Result.dart';

class MockTaskRepository implements TaskRepository {
  // 1. This is the mock task list used as the in-memory data source
  final List<Task> _tasks = [
    Task(
      taskCode: 'T001',
      fromLocation: 'Workshop A',
      toLocation: 'Customer B',
      itemDescription: 'Car Battery',
      itemCount: 1,
      startTime: DateTime.now(),
      deadline: DateTime.now().add(Duration(hours: 4)),
      status: TaskStatus.inProgress,
      ownerId: 'user001',
      confirmationPhoto: null,
      confirmationSign: null,
    ),
    Task(
      taskCode: 'T002',
      fromLocation: 'Garage C',
      toLocation: 'Station D',
      itemDescription: 'Engine Oil',
      itemCount: 1,
      startTime: DateTime.now().subtract(Duration(hours: 2)),
      deadline: DateTime.now().add(Duration(hours: 3)),
      status: TaskStatus.pending,
      ownerId: 'user002',
      confirmationPhoto: null,
      confirmationSign: null,
    ),
    
      Task(
        taskCode: 'TSK001',
        fromLocation: 'Main Warehouse',
        toLocation: 'Customer Location A',
        itemDescription: 'Brake Pads Set',
        itemCount: 2,
        startTime: DateTime(2024, 12, 29, 8, 0),
        deadline: DateTime(2024, 12, 29, 10, 0),
        status: TaskStatus.pending,
        ownerId: 'AutoFix Workshop',
      ),
      Task(
        taskCode: 'TSK002',
        fromLocation: 'Parts Center',
        toLocation: 'Honda Service Center',
        itemDescription: '2019 Honda Civic',
        itemCount: 1,
        startTime: DateTime(2024, 12, 29, 9, 30),
        deadline: DateTime(2024, 12, 29, 12, 0),
        status: TaskStatus.inProgress,
        ownerId: 'Mike Rodriguez',
      ),
      Task(
        taskCode: 'TSK003',
        fromLocation: 'Service Station',
        toLocation: 'Client Garage',
        itemDescription: 'Transmission Fluid',
        itemCount: 4,
        startTime: DateTime(2024, 12, 29, 11, 15),
        deadline: DateTime(2024, 12, 29, 14, 0),
        status: TaskStatus.completed,
        ownerId: 'Sarah Johnson',
      ),
      Task(
        taskCode: 'TSK004',
        fromLocation: 'Auto Parts Store',
        toLocation: 'Quick Fix Garage',
        itemDescription: 'Oil Filter Set',
        itemCount: 6,
        startTime: DateTime(2024, 12, 29, 13, 45),
        deadline: DateTime(2024, 12, 29, 16, 30),
        status: TaskStatus.completed,
        ownerId: 'Tom Wilson',
      ),
      Task(
        taskCode: 'TSK005',
        fromLocation: 'Central Depot',
        toLocation: 'Ford Dealership',
        itemDescription: '2018 Ford F-150',
        itemCount: 1,
        startTime: DateTime(2024, 12, 29, 15, 20),
        deadline: DateTime(2024, 12, 29, 18, 0),
        status: TaskStatus.inProgress,
        ownerId: 'Lisa Chen',
      ),
  ];

  // 2. This method filters tasks by their status
  @override
  Future<Result<List<Task>>> getTasksByStatus(TaskStatus status) async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      if (status == TaskStatus.all) {
        return Result.success(_tasks);
      } else {
        final filtered = _tasks.where((task) => task.status == status).toList();
        return Result.success(filtered);
      }
    } catch (e) {
      return Result.failure('Failed to fetch tasks: ${e.toString()}');
    }
  }

  @override
  Future<Result<Task>> addTask(Task task) async {
    try {
      await Future.delayed(Duration(milliseconds: 100));
      _tasks.add(task);
      return Result.success(task); // return added object
    } catch (e) {
      return Result.failure('Failed to add task: ${e.toString()}');
    }
  }

  @override
  Future<Result<Task>> updateTask(Task updatedTask) async {
    try {
      await Future.delayed(Duration(milliseconds: 100));
      final index = _tasks.indexWhere((t) => t.taskCode == updatedTask.taskCode);
      if (index == -1) {
        return Result.failure('Task not found');
      }
      _tasks[index] = updatedTask;
      return Result.success(updatedTask);
    } catch (e) {
      return Result.failure('Failed to update task: ${e.toString()}');
    }
  }

  @override
  Future<Result<Task>> deleteTask(String taskCode) async {
    try {
      await Future.delayed(Duration(milliseconds: 100));
      final index = _tasks.indexWhere((t) => t.taskCode == taskCode);
      if (index == -1) {
        return Result.failure('Task not found');
      }
      final removedTask = _tasks.removeAt(index);
      return Result.success(removedTask);
    } catch (e) {
      return Result.failure('Failed to delete task: ${e.toString()}');
    }
  }

}