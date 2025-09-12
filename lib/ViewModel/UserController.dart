import 'package:flutter/material.dart';
import '../Models/User.dart';
import '../Common/Result.dart';
import '../Repository/Repository.dart';

class UserController extends ChangeNotifier {
  final Repository repository;
  User? currentUser;

  UserController(this.repository);

  // Authenticate and fetch the profile
  Future<Result<User>> userLogin(String email, String password) async {
    final loginResult = await repository.login(email, password);

    if (loginResult.isSuccess) {
      final profileResult = await repository.getUserByEmail(email);

      if (profileResult.isSuccess) {
        currentUser = profileResult.data;
        notifyListeners();
        return Result.success(currentUser!);
      } else {
        return Result.failure(
            profileResult.errorMessage ?? "Could not fetch user profile.");
      }
    } else {
      return Result.failure(
          loginResult.errorMessage ?? "Invalid email or password.");
    }
  }

  Result<User> getCurrentUser() {
    if (currentUser != null) {
      return Result.success(currentUser!);
    }
    return Result.failure("No user is currently logged in");
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  void setCurrentUser(User user) {
    currentUser = user;
    notifyListeners();
  }
}
