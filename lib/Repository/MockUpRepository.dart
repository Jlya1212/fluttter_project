import 'dart:async';
import 'dart:typed_data';
import 'Repository.dart';
import '../Models/Task.dart';
import '../common/Result.dart';
import '../Models/User.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class MockUpRepository implements Repository {

  final List<Task> _tasks = [
    Task(
        taskName: 'Brake Pads Set',
        taskCode: 'BP-HON-001',
        fromLocation: 'Warehouse A - Bay 3',
        toLocation: 'AutoFix Workshop - Bay 3',
        itemDescription: '2019 Honda Civic',
        itemCount: 2,
        startTime: DateTime(2025, 9, 1, 8, 30),
        deadline: DateTime(2025, 9, 1, 9, 0),
        status: TaskStatus.pending,
        ownerId: 'Mike Rodriguez',
        customerName: 'John Smith',
        partDetails: 'Ceramic brake pads, front axle only - Premium grade',
        destinationAddress: '123 Main St, Downtown, NY 10001',
        estimatedDurationMinutes: 30,
        specialInstructions: 'Handle with care. Ceramic brake pads require special handling.',
        deliveryNotes: 'Contact mechanic Mike Rodriguez upon arrival at Bay 3'
    ),
    // ... other tasks
  ];

  final List<User> _users = [
    User(
      id: 'user001',
      username: '',
      email: 'johndoe',
      phone: '012-3456789',
      password: 'password123',
    ),
    User(
      id: 'user002',
      username: 'JaneSmith',
      email: 'janesmith@example.com',
      phone: '012-9876543',
      password: 'password456',
    ),
  ];

  @override
  Future<Result<List<Task>>> getTasksByStatus(TaskStatus status) async {
    try {
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
  Future<Result<User>> getUserByEmail(String email) async {
    try {
      final User user = _users.firstWhere((user) => user.email == email);
      return Result.success(user);
    } catch (e) {
      return Result.failure('User not found');
    }
  }
  @override
  Future<Result<void>> updateTaskStatus(String taskCode, TaskStatus newStatus) async {
    try {
      final taskIndex = _tasks.indexWhere((task) => task.taskCode == taskCode);
      if (taskIndex != -1) {
        final oldTask = _tasks[taskIndex];
        _tasks[taskIndex] = Task(
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
          customerName: oldTask.customerName,
          partDetails: oldTask.partDetails,
          destinationAddress: oldTask.destinationAddress,
          estimatedDurationMinutes: oldTask.estimatedDurationMinutes,
          specialInstructions: oldTask.specialInstructions,
          deliveryNotes: oldTask.deliveryNotes,
          photoBase64: oldTask.photoBase64,
        );
        return Result.success(null);
      } else {
        return Result.failure('Task not found with code: $taskCode');
      }
    } catch (e) {
      return Result.failure('Error updating task status: ${e.toString()}');
    }
  }
  // This method is now required by the Repository interface.
  // Since this is a mock repository, we'll just have it fail.
  @override
  Future<Result<auth.User>> login(String email, String password) async {
    // This mock implementation should not be used for real login.
    // It's here to satisfy the interface requirement.
    return Future.value(Result.failure("Login not implemented in Mock Repository."));
  }
  // ✅ Added to satisfy the Repository interface
  @override
  Future<Result<void>> confirmDelivery(
      String taskCode,
      Uint8List? mechanicSignature,
      Uint8List? deliverySignature,
      String? photoBase64,
      DateTime completionTime,
      ) async {
    try {
      final taskIndex = _tasks.indexWhere((task) => task.taskCode == taskCode);

      if (taskIndex != -1) {
        final oldTask = _tasks[taskIndex];
        _tasks[taskIndex] = Task(
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
          customerName: oldTask.customerName,
          partDetails: oldTask.partDetails,
          destinationAddress: oldTask.destinationAddress,
          estimatedDurationMinutes: oldTask.estimatedDurationMinutes,
          specialInstructions: oldTask.specialInstructions,
          deliveryNotes: oldTask.deliveryNotes,
          photoBase64: photoBase64,

        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure('Mock confirmDelivery failed: ${e.toString()}');
    }
  }

}