import 'package:fluttter_project/Models/User.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth; // Add this import
import '../Models/Task.dart';
import '../common/Result.dart';
import 'dart:typed_data';

abstract class Repository {
  Future<Result<List<Task>>> getTasksByStatus(TaskStatus status , String AssignDriverName);
  Future<Result<User>> getUserByEmail(String email);

  // Add this new method for handling authentication
  Future<Result<auth.User>> login(String email, String password);

  Future<Result<void>> confirmDelivery(
      String taskCode,
      Uint8List? mechanicSignature,
      Uint8List? deliverySignature,
      String? photoBase64,
      DateTime completionTime,
      );
  // Add method for updating task status
  Future<Result<void>> updateTaskStatus(String taskCode, TaskStatus newStatus);

  // add task to db :
  Future<Result<bool>> addTaskToDB(Task task);
}