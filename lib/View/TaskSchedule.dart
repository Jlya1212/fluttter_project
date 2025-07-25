import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // if you're formatting datetime
import 'TaskCard.dart'; // adjust the path if needed
import '../models/task.dart';       // make sure Task and TaskStatus are defined


class DeliverySchedulePage extends StatelessWidget {
  const DeliverySchedulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sampleTasks = _createSampleTasks();
    

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
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
          // Tab bar
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTab('All Orders', 3, true),
                _buildTab('Pending', 2, false),
                _buildTab('Picked Up', 1, false),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Task list
          Expanded(
            child: ListView.builder(
              itemCount: sampleTasks.length,
              itemBuilder: (context, index) {
                return TaskCard(
                  task: sampleTasks[index],
                  onTap: () {
                    _showTaskDetails(context, sampleTasks[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Schedule tab selected
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int count, bool isSelected) {
    return Expanded(
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
    );
  }

  List<Task> _createSampleTasks() {
    return [
      // should be replaced with actual task data : 

      Task(
        taskCode: 'TSK001',
        fromLocation: 'Main Warehouse',
        toLocation: 'Customer Location A',
        itemDescription: 'Brake Pads Set',
        itemCount: 2,
        startTime: DateTime(2024, 12, 29, 8, 0),
        deadline: DateTime(2024, 12, 29, 10, 0),
        status: TaskStatus.pending,
        ownerId: 'AutoFix Workshop',
      ),
      Task(
        taskCode: 'TSK002',
        fromLocation: 'Parts Center',
        toLocation: 'Honda Service Center',
        itemDescription: '2019 Honda Civic',
        itemCount: 1,
        startTime: DateTime(2024, 12, 29, 9, 30),
        deadline: DateTime(2024, 12, 29, 12, 0),
        status: TaskStatus.inProgress,
        ownerId: 'Mike Rodriguez',
      ),
      Task(
        taskCode: 'TSK003',
        fromLocation: 'Service Station',
        toLocation: 'Client Garage',
        itemDescription: 'Transmission Fluid',
        itemCount: 4,
        startTime: DateTime(2024, 12, 29, 11, 15),
        deadline: DateTime(2024, 12, 29, 14, 0),
        status: TaskStatus.completed,
        ownerId: 'Sarah Johnson',
      ),
      Task(
        taskCode: 'TSK004',
        fromLocation: 'Auto Parts Store',
        toLocation: 'Quick Fix Garage',
        itemDescription: 'Oil Filter Set',
        itemCount: 6,
        startTime: DateTime(2024, 12, 29, 13, 45),
        deadline: DateTime(2024, 12, 29, 16, 30),
        status: TaskStatus.completed,
        ownerId: 'Tom Wilson',
      ),
      Task(
        taskCode: 'TSK005',
        fromLocation: 'Central Depot',
        toLocation: 'Ford Dealership',
        itemDescription: '2018 Ford F-150',
        itemCount: 1,
        startTime: DateTime(2024, 12, 29, 15, 20),
        deadline: DateTime(2024, 12, 29, 18, 0),
        status: TaskStatus.inProgress,
        ownerId: 'Lisa Chen',
      ),
    ];
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Task: ${task.taskCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item: ${task.itemDescription}'),
              Text('Count: ${task.itemCount}'),
              Text('From: ${task.fromLocation}'),
              Text('To: ${task.toLocation}'),
              Text('Status: ${task.status}'),
              Text('Owner: ${task.ownerId}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
