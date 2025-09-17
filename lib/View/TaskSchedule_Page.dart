import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../Common/TaskCard.dart';
import '../Models/Task.dart';
import '../Models/User.dart';
import '../ViewModel/TaskController.dart';
import '../ViewModel/UserController.dart';
import 'PartRequestDetails_Page.dart';


class DeliverySchedulePage extends StatefulWidget {
  const DeliverySchedulePage({Key? key, required this.maybePop}) : super(key: key);
  static const routeName = '/delivery-schedule';
  final VoidCallback maybePop;

  @override
  _DeliverySchedulePageState createState() => _DeliverySchedulePageState();
}

class _DeliverySchedulePageState extends State<DeliverySchedulePage> {
  late final TaskController _controller;
  late final UserController _userController;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<TaskController>(context, listen: false);
    _userController = Provider.of<UserController>(context, listen: false);

    // Now safely unwrap the Result<User>
    final result = _userController.getCurrentUser();
    if (result.isSuccess) {
      _currentUser = result.data;
      // Load tasks for this user
      _controller.loadTasksAndSetFilter(
        TaskStatus.all,
        _currentUser?.username,
      );
    } else {
      // No user logged in, handle gracefully
      debugPrint("No user logged in: ${result.errorMessage}");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, controller, child) {
        final tasks = controller.filteredTasks;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: () => widget.maybePop(),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
            title: const Text(
              'Delivery Schedule',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              // This code adds a sort popup to choose sort order by start time.
              PopupMenuButton<TaskSort>(
                tooltip: 'Sort by End time',
                icon: const Icon(Icons.sort, color: Colors.black),
                initialValue: controller.sort,
                onSelected: controller.setSort,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: TaskSort.startTimeAsc,
                    child: Text('End time ↑ (earliest first)'),
                  ),
                  PopupMenuItem(
                    value: TaskSort.startTimeDesc,
                    child: Text('End time ↓ (latest first)'),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, color: Colors.black),
              ),
            ],
          ),
          body: Column(
            children: [
              // Scrollable TabRow
              Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      _buildTab('All Orders', TaskStatus.all),
                      _buildTab('Pending', TaskStatus.pending),
                      _buildTab('Picked Up', TaskStatus.pickedUp),
                      _buildTab('In Progress', TaskStatus.inProgress),
                      _buildTab('Completed', TaskStatus.completed),
                    ],
                  ),
                ),
              ),
              // This code shows current sort hint under tabs.
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      controller.sort == TaskSort.startTimeAsc
                          ? 'Sorted by Start Time: Earliest first'
                          : 'Sorted by Start Time: Latest first',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(child: Text('No tasks found'))
                    : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Consumer<TaskController>(
                      builder: (context, controller, _) {
                        final latestTask = controller.getTaskByCode(task.taskCode) ?? task;
                        return TaskCard(
                          task: latestTask,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PartRequestDetailsPage(task: latestTask),
                              ),
                            );
                            controller.loadTasksAndSetFilter(
                              controller.currentFilter,
                              _currentUser?.username,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(String title, TaskStatus status) {
    // Reading controller here for tab state, but not listening to rebuild the whole page
    final controller = Provider.of<TaskController>(context);
    final isSelected = controller.currentFilter == status;
    final count = status == TaskStatus.all
        ? controller.allTasks.length
        : controller.allTasks.where((t) => t.status == status).length;

    return GestureDetector(
      onTap: () {
        // Use the controller from initState to call methods
        _controller.setFilter(status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.orange : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.orange : Colors.grey,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange.shade700 : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}