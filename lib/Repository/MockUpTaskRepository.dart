import 'dart:async';
import 'TaskRepository.dart';
import '../models/task.dart';

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
  ];

  // 2. This method filters tasks by their status
  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    await Future.delayed(Duration(milliseconds: 300)); // simulate delay
    return _tasks.where((task) => task.status == status).toList();
  }

  // Optional: Add methods for test modification
  void addTask(Task task) {
    _tasks.add(task);
  }

  void clearTasks() {
    _tasks.clear();
  }
}
