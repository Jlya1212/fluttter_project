import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../ViewModel/TaskController.dart';
import '../Models/Task.dart';
import 'PartRequestDetails_Page.dart';

class StatusUpdate extends StatefulWidget {
  const StatusUpdate({Key? key}) : super(key: key);

  @override
  State<StatusUpdate> createState() => _StatusUpdateState();
}

class _StatusUpdateState extends State<StatusUpdate> {
  String selectedFilter = 'All';
  bool _isLoading = true;

  final List<String> statusFilters = ['All', 'Pending', 'Picked Up', 'In Progress', 'Completed'];
  final List<String> statusOptions = ['Pending', 'Picked Up', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final taskController = Provider.of<TaskController>(context, listen: false);
    await taskController.loadTasksAndSetFilter(TaskStatus.all);
    setState(() {
      _isLoading = false;
    });
  }

  // Helper method to convert TaskStatus enum to display string
  String _getStatusDisplayName(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.pickedUp:
        return 'Picked Up';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.all:
        return 'All';
    }
  }

  // Helper method to convert display string to TaskStatus enum
  TaskStatus _getStatusFromDisplayName(String displayName) {
    switch (displayName) {
      case 'Pending':
        return TaskStatus.pending;
      case 'Picked Up':
        return TaskStatus.pickedUp;
      case 'In Progress':
        return TaskStatus.inProgress;
      case 'Completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.all;
    }
  }

  // Helper method to get time ago string
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  // Helper method to get status icon
  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.access_time;
      case TaskStatus.pickedUp:
        return Icons.check_circle_outline;
      case TaskStatus.inProgress:
        return Icons.local_shipping;
      case TaskStatus.completed:
        return Icons.check;
      case TaskStatus.all:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, taskController, child) {
        if (_isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
          );
        }

        final tasks = taskController.allTasks;
        final filteredTasks = selectedFilter == 'All'
            ? tasks
            : tasks.where((task) => _getStatusDisplayName(task.status) == selectedFilter).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false, // Remove back button since we're in a tab
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Updates',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Update delivery progress',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Live Updates',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${tasks.length} deliveries',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: Column(
            children: [
              // Status Filter Tabs
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: statusFilters.map((filter) {
                      bool isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.orange : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Delivery Items List
              Expanded(
                child: filteredTasks.isEmpty
                    ? const Center(
                  child: Text(
                    'No deliveries found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Item Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.taskName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task.taskCode,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task.itemDescription,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            task.toLocation,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            task.ownerId,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _getStatusDisplayName(task.status),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    Text(
                                      _getTimeAgo(task.startTime),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Update Status Section
                            const Text(
                              'Update Status:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Status Buttons
                            Row(
                              children: statusOptions.map((status) {
                                bool isSelected = task.status == _getStatusFromDisplayName(status);
                                IconData icon = _getStatusIcon(_getStatusFromDisplayName(status));

                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () async {
                                        final newStatus = _getStatusFromDisplayName(status);
                                        await taskController.updateTaskStatus(task.taskCode, newStatus);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected ? Colors.orange : Colors.grey.shade300,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              icon,
                                              color: isSelected ? Colors.orange : Colors.grey.shade600,
                                              size: 20,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              status,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isSelected ? Colors.orange : Colors.grey.shade600,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // View Full Details Button
                            GestureDetector(
                              onTap: () {
                                // Navigate to PartRequestDetails page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PartRequestDetailsPage(task: task),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.visibility,
                                      color: Colors.grey.shade600,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'View Full Details',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}