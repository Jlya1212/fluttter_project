import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'Repository.dart';
import '../Models/Task.dart';
import '../Models/User.dart';
import '../common/Result.dart';
import 'dart:typed_data';

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
  Future<Result<List<Task>>> getTasksByStatus(
      TaskStatus status, String? assignDriverName,) async {
    try {
      Query query = _firestore.collection('tasks');

      // filter by status (skip if 'all')
      if (status != TaskStatus.all) {
        query = query.where('status', isEqualTo: status.name);
      }

      // filter by assigned driver name (skip if null/empty)
      if (assignDriverName != null && assignDriverName.isNotEmpty) {
        query = query.where('assignDriverName', isEqualTo: assignDriverName);
      }

      final querySnapshot = await query.get();

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
  Future<Result<void>> confirmDelivery(
      String taskCode,
      Uint8List? mechanicSignature,
      Uint8List? deliverySignature,
      String? photoBase64,
      DateTime completionTime,
      ) async {
    try {
      final query = await _firestore
          .collection('tasks')
          .where('taskCode', isEqualTo: taskCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return Result.failure('Task not found for taskCode: $taskCode');
      }

      final taskDoc = query.docs.first.reference;

      // 🔹 Build update map conditionally
      final Map<String, dynamic> updates = {
        'completionTime': Timestamp.fromDate(completionTime),
        'status': TaskStatus.completed.name,
      };

      if (mechanicSignature != null) {
        updates['mechanicSignature'] = Blob(mechanicSignature);
      }
      if (deliverySignature != null) {
        updates['deliverySignature'] = Blob(deliverySignature);
      }
      if (photoBase64 != null) {
        updates['photoBase64'] = photoBase64;
      }

      await taskDoc.update({
        'mechanicSignature': mechanicSignature != null ? Blob(mechanicSignature) : null,
        'deliverySignature': deliverySignature != null ? Blob(deliverySignature) : null,
        'photoBase64': photoBase64,
        'completionTime': Timestamp.fromDate(completionTime),
        'status': TaskStatus.completed.name,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      });


      return Result.success(null);
    } catch (e) {
      return Result.failure('Error confirming delivery: ${e.toString()}');
    }
  }
  @override
  Future<Result<bool>> addTaskToDB(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.taskCode).set(task.toJson());
      return Result.success(true);
    } catch (e) {
      return Result.failure("Failed to add task: ${e.toString()}");
    }
  }

  Future<Result<void>> updateTaskDeliveryTime(String taskCode, DateTime deliveryTime) async {
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
          'deliveryTime': Timestamp.fromDate(deliveryTime),
          'lastUpdated': Timestamp.fromDate(DateTime.now()),
        });
        return Result.success(null);
      } else {
        return Result.failure('Task not found with code: $taskCode');
      }
    } catch (e) {
      return Result.failure('Error updating task delivery time: ${e.toString()}');
    }
  }


}

