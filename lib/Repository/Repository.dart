import 'package:fluttter_project/Models/User.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth; // Add this import
import '../Models/Task.dart';
import '../common/Result.dart';

abstract class Repository {
  Future<Result<List<Task>>> getTasksByStatus(TaskStatus status);
  Future<Result<User>> getUserByEmail(String email);

  // Add this new method for handling authentication
  Future<Result<auth.User>> login(String email, String password);
}
