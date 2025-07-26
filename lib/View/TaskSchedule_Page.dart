import 'package:flutter/material.dart';
import 'package:fluttter_project/Repository/MockUpTaskRepository.dart';
import 'package:fluttter_project/ViewModel/TaskController.dart';
import 'package:intl/intl.dart';
import '../Common/TaskCard.dart';            
import '../models/task.dart';      

class DeliverySchedulePage extends StatefulWidget {
  const DeliverySchedulePage({Key? key}) : super(key: key);

  static const routeName = '/delivery-schedule';

  @override
  _DeliverySchedulePageState createState() => _DeliverySchedulePageState();
  
  }

class _DeliverySchedulePageState extends State<DeliverySchedulePage> {
  late final TaskController _controller;
  late final VoidCallback    _listener;

  @override
  void initState() {
    super.initState();
    _controller = TaskController(MockTaskRepository());
    _listener   = () => setState(() {});
    _controller.addListener(_listener);

    _controller.loadTasksAndSetFilter(TaskStatus.all);
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _controller.filteredTasks;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Delivery Schedule',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.black)),
        ],
      ),
      body: Column(
        children: [
          // 3.2 TabRow：All / Pending / InProgress / Completed
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTab('All Orders',     TaskStatus.all),
                _buildTab('Pending',        TaskStatus.pending),
                _buildTab('In Progress',    TaskStatus.inProgress),
                _buildTab('Completed',      TaskStatus.completed),
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
                      return TaskCard(
                        task: tasks[index],
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/task-details',
                          arguments: tasks[index],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Schedule
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),        label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule),             label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.update),               label: 'Status Update'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),       label: 'Profile'),
        ],
      ),
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
              bottom: BorderSide(color: isSelected ? Colors.orange : Colors.transparent, width: 2),
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
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
      
  }
}