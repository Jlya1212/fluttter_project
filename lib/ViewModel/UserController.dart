import 'package:flutter/material.dart';
import '../Models/User.dart';
import '../Common/Result.dart';
import '../Repository/Repository.dart';

class UserController extends ChangeNotifier {
  final Repository repository;
  User? currentUser;

  UserController(this.repository);

  // This method now performs a real Firebase login and then fetches the user profile.
  Future<Result<User>> userLogin(String email, String password) async {
    // Step 1: Authenticate with Firebase Auth
    final loginResult = await repository.login(email, password);

    if (loginResult.isSuccess) {
      // Step 2: If authentication is successful, fetch the user's profile
      // from the Firestore database to get details like username, phone, etc.
      final profileResult = await repository.getUserByEmail(email);

      if (profileResult.isSuccess) {
        currentUser = profileResult.data;
        notifyListeners(); // Notify listeners that the user has changed
        return Result.success(currentUser!);
      } else {
        // This case would be rare: user exists in Auth but not in the database
        return Result.failure(profileResult.errorMessage ?? "Could not fetch user profile.");
      }
    } else {
      // Authentication failed (wrong password, user not found, etc.)
      return Result.failure(loginResult.errorMessage ?? "Invalid email or password.");
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