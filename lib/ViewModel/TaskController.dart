import 'package:flutter/foundation.dart';
import '../Models/Task.dart';
import '../Repository/Repository.dart';

class TaskController extends ChangeNotifier {
  final Repository repository;

  TaskController(this.repository);

  List<Task> _allTasks = [];
  TaskStatus _currentFilter = TaskStatus.all;

  List<Task> get filteredTasks {
    if (_currentFilter == TaskStatus.all) return _allTasks;
    return _allTasks.where((t) => t.status == _currentFilter).toList();
  }

  List<Task> get allTasks => _allTasks;

  TaskStatus? get currentFilter => _currentFilter;

  Future<void> loadTasksAndSetFilter(TaskStatus status) async {
    try {

      final result = await repository.getTasksByStatus(status);
      
      if (result.isSuccess) {
        _allTasks = result.data ?? [];
        _currentFilter = status;
        notifyListeners();
      } else {
        print("Load failed: ${result.errorMessage}");
      }
    } catch (e) {
      print('Controller failed to fetch tasks: ${e.toString()}');
    }
  }

  void setFilter(TaskStatus status) {
    _currentFilter = status;
    notifyListeners();
  }


}
