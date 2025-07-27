import 'package:flutter/material.dart';
import '../Models/User.dart';
import '../Common/Result.dart';
import '../Repository/Repository.dart';
class UserController extends ChangeNotifier {

  final Repository repository;
  User? currentUser;

  UserController(
    this.repository
    ) ;

  // pseudocode for user authentication
  // 1. get user by email :
  //    if user exists, check password then save user object into current user then return user object 
  //    else return false 
  Future<Result<User>> UserLogin(String email , String password) async {

    final result = await repository.getUserByEmail(email);

    if(result.isSuccess && result.data != null){
      if(result.data!.password == password){
        currentUser = result.data;
        return Result.success(currentUser!);
      }else {
        return Result.failure("Invalid password");
      }
    }
    return Result.failure("Invalid email");
  }

  // 2. get current user , since after user login the data is saved in currentUser which is in memory so not need using async / future :
  Result<User> getCurrentUser() {
    if (currentUser != null) {
      return Result.success(currentUser!);
    }
    return Result.failure("No user is currently logged in");
  }

  void setCurrentUser(User user) {
    currentUser = user;
    notifyListeners();
  }
  
}    