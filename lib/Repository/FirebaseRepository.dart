import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'Repository.dart';
import '../Models/Task.dart';
import '../Models/User.dart';
import '../common/Result.dart';

class FirebaseRepository implements Repository {
  // Get instances of Firestore and Firebase Auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  @override
  Future<Result<User>> getUserByEmail(String email) async {
    // This is used after login to get the user's profile data
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        return Result.success(User.fromJson(userDoc.data()));
      }
      return Result.failure('User profile not found in database.');
    } catch (e) {
      return Result.failure('Error fetching user profile: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Task>>> getTasksByStatus(TaskStatus status) async {
    try {
      // Create a query against the "tasks" collection
      Query query = _firestore.collection('tasks');

      // If the filter is not "all", add a where clause
      if (status != TaskStatus.all) {
        query = query.where('status', isEqualTo: status.name);
      }

      final querySnapshot = await query.get();
      // Map the documents from Firestore into our Task objects
      final tasks = querySnapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return Result.success(tasks);
    } catch (e) {
      return Result.failure('Error fetching tasks: ${e.toString()}');
    }
  }

  // A new method for handling actual user login with Firebase Auth
  @override
  Future<Result<auth.User>> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return Result.success(credential.user!);
      }
      return Result.failure('Login failed: User not found.');
    } on auth.FirebaseAuthException catch (e) {
      // Handle specific auth errors like wrong password, user not found, etc.
      return Result.failure(e.message ?? 'An unknown login error occurred.');
    }
  }

  @override
  Future<Result<void>> updateTaskStatus(String taskCode, TaskStatus newStatus) async {
    try {
      // Find the task document by taskCode
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('taskCode', isEqualTo: taskCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _firestore.collection('tasks').doc(docId).update({
          'status': newStatus.name,
          'lastUpdated': Timestamp.fromDate(DateTime.now()),
        });
        return Result.success(null);
      } else {
        return Result.failure('Task not found with code: $taskCode');
      }
    } catch (e) {
      return Result.failure('Error updating task status: ${e.toString()}');
    }
  }
}

