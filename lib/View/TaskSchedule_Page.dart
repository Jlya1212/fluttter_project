import 'package:flutter/material.dart';
import 'package:fluttter_project/Repository/MockUpRepository.dart';
import 'package:fluttter_project/View/PartRequestDetails_Page.dart';
import 'package:fluttter_project/ViewModel/TaskController.dart';
import 'package:provider/provider.dart';
import '../Common/TaskCard.dart';
import '../Models/Task.dart';

class DeliverySchedulePage extends StatefulWidget {
  const DeliverySchedulePage({Key? key, required this.maybePop}) : super(key: key);

  static const routeName = '/delivery-schedule';

  final VoidCallback maybePop;

  @override
  _DeliverySchedulePageState createState() => _DeliverySchedulePageState();
}

class _DeliverySchedulePageState extends State<DeliverySchedulePage> {
  late final TaskController _controller;


  @override
  void initState() {
    super.initState();
    // Get the TaskController from the Provider without listening to changes here.
    _controller = Provider.of<TaskController>(context, listen: false);
    // Load initial data.
    _controller.loadTasksAndSetFilter(TaskStatus.all);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to listen for changes in the TaskController
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
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, color: Colors.black),
              ),
            ],
          ),
          body: Column(
            children: [
              // TabRow
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    _buildTab('All Orders', TaskStatus.all),
                    _buildTab('Pending', TaskStatus.pending),
                    _buildTab('In Progress', TaskStatus.inProgress),
                    _buildTab('Completed', TaskStatus.completed),
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
                    return TaskCard(
                      task: task,
                      onTap: () async {
                        final newStatus = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PartRequestDetailsPage(task: task),
                          ),
                        );

                        if (newStatus != null && newStatus is TaskStatus) {
                          // Use the controller from the Consumer
                          controller.updateTaskStatus(task.taskCode, newStatus);
                        }
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
    final isSelected = _controller.currentFilter == status;
    final count = status == TaskStatus.all
        ? _controller.allTasks.length
        : _controller.allTasks.where((t) => t.status == status).length;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _controller.loadTasksAndSetFilter(status);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.orange : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                    color: isSelected ? Colors.orange : Colors.grey,
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
      ),
    );
  }
}
