import 'dart:async';
import 'TaskRepository.dart';
import '../models/task.dart';
import '../common/Result.dart';

class MockTaskRepository implements TaskRepository {
  // 1. This is the mock task list used as the in-memory data source
  final List<Task> _tasks = [
Task(
  taskName : 'Battery Replacement',
  taskCode: 'T001',
  fromLocation: 'Proton Service Center, Shah Alam',
  toLocation: 'Customer Address, Subang Jaya',
  itemDescription: 'Amaron Car Battery DIN55: 1',
  itemCount: 1,
  startTime: DateTime.now(),
  deadline: DateTime.now().add(Duration(hours: 4)),
  status: TaskStatus.inProgress,
  ownerId: 'user001',
  confirmationPhoto: null,
  confirmationSign: null,
),
Task(
  taskName : 'Engine Oil Change',
  taskCode: 'T002',
  fromLocation: 'Shell Workshop, Petaling Jaya',
  toLocation: 'MRT Station, Taman Tun Dr Ismail',
  itemDescription: 'Shell Helix Ultra 5W-40 Engine Oil (4L): 1',
  itemCount: 1,
  startTime: DateTime.now().subtract(Duration(hours: 2)),
  deadline: DateTime.now().add(Duration(hours: 3)),
  status: TaskStatus.pending,
  ownerId: 'user002',
  confirmationPhoto: null,
  confirmationSign: null,
),
Task(
  taskName : 'Brake Pad Replacement',
  taskCode: 'TSK001',
  fromLocation: 'Main Auto Warehouse, Puchong',
  toLocation: 'Customer Residence, Bangsar',
  itemDescription: 'Brembo Brake Pads Set: 2',
  itemCount: 2,
  startTime: DateTime(2024, 12, 29, 8, 0),
  deadline: DateTime(2024, 12, 29, 10, 0),
  status: TaskStatus.pending,
  ownerId: 'AutoFix Workshop',
),
Task(
  taskName : 'Tyre Replacement',
  taskCode: 'TSK002',
  fromLocation: 'Spare Parts Center, Kota Damansara',
  toLocation: 'Honda Service Center, Cheras',
  itemDescription: '2019 Honda Civic Tyre (Michelin Primacy 4): 4',
  itemCount: 4,
  startTime: DateTime(2024, 12, 29, 9, 30),
  deadline: DateTime(2024, 12, 29, 12, 0),
  status: TaskStatus.inProgress,
  ownerId: 'Mike Rodriguez',
),
Task(
  taskName : 'Transmission Fluid Delivery',
  taskCode: 'TSK003',
  fromLocation: 'Total Service Station, Kajang',
  toLocation: 'Client Garage, Serdang',
  itemDescription: 'Toyota ATF Transmission Fluid (1L): 4',
  itemCount: 4,
  startTime: DateTime(2024, 12, 29, 11, 15),
  deadline: DateTime(2024, 12, 29, 14, 0),
  status: TaskStatus.completed,
  ownerId: 'Sarah Johnson',
),
Task(
  taskName : 'Oil Filter Replacement',
  taskCode: 'TSK004',
  fromLocation: 'Ban Lee Heng Auto Parts, Pudu KL',
  toLocation: 'Quick Fix Garage, Setapak',
  itemDescription: 'Bosch Oil Filter Set: 6',
  itemCount: 6,
  startTime: DateTime(2024, 12, 29, 13, 45),
  deadline: DateTime(2024, 12, 29, 16, 30),
  status: TaskStatus.completed,
  ownerId: 'Tom Wilson',
),
Task(
  taskName : 'Tyre Delivery',
  taskCode: 'TSK005',
  fromLocation: 'Central Auto Depot, Klang',
  toLocation: 'Ford Dealership, Jalan Ampang',
  itemDescription: '2018 Ford F-150 Tyre Set (Goodyear Wrangler): 4',
  itemCount: 4,
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