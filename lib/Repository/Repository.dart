// Define the base interface
import 'package:fluttter_project/Models/User.dart';

import '../Models/Task.dart';
import '../common/Result.dart';

abstract class Repository {
  Future<Result<List<Task>>> getTasksByStatus(TaskStatus status); 
  Future<Result<User>> getUserByEmail(String email);
}
