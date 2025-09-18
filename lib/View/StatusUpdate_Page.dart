import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Models/User.dart';
import '../ViewModel/TaskController.dart';
import '../Models/Task.dart';
import '../ViewModel/UserController.dart';
import 'DeliveryTimePromptPage.dart';
import 'PartRequestDetails_Page.dart';
import 'DeliveryConfirmation_Page.dart';
import 'VirtualDriverNavigationPage.dart';
import '../Common/DeliveryTimeHelper.dart';

class StatusUpdate extends StatefulWidget {
  const StatusUpdate({Key? key}) : super(key: key);

  @override
  State<StatusUpdate> createState() => _StatusUpdateState();
}

class _StatusUpdateState extends State<StatusUpdate> {
  bool _isLoading = true;
  bool _showChecklistView = false; // Toggle between checklist and detailed view (default to detailed)
  late final UserController _userController;
  late User _currentUser;
  Timer? _minuteTicker;

  final List<String> statusOptions = ['Pending', 'Picked Up', 'En Route', 'Completed'];

  @override
  void initState() {
    super.initState();
    _userController = Provider.of<UserController>(context, listen: false);
    _initCurrentUserAndTasks();

    // Rebuild every minute to refresh "Updated X mins ago"
    _minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _initCurrentUserAndTasks() async {
    // 1. Get the current user
    final userResult = await _userController.getCurrentUser();
    if (userResult.isSuccess && userResult.data != null) {
      _currentUser = userResult.data!;
    } else {
      // handle error gracefully
      // you can show a snackbar or navigate back
      setState(() => _isLoading = false);
      return;
    }
    // 2. Load tasks for this user
    await _loadTasks();
  }

  @override
  void dispose() {
    _minuteTicker?.cancel();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final taskController = Provider.of<TaskController>(context, listen: false);
    await taskController.loadTasksAndSetFilter(TaskStatus.all, _currentUser.username);
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
        return 'En Route';
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
      case 'En Route':
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

  // Build pickup checklist summary section
  Widget _buildPickupChecklistSummary(List<Task> tasks) {
    final pickedUpTasks = tasks.where((task) => task.status == TaskStatus.pickedUp).length;
    final totalTasks = tasks.length;
    final pickupPercentage = totalTasks > 0 ? (pickedUpTasks / totalTasks) : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Pickup Checklist',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$pickedUpTasks of $totalTasks tasks picked up',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '${(pickupPercentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickupPercentage == 1.0 ? Colors.green : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pickupPercentage,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                pickupPercentage == 1.0 ? Colors.green : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build pickup checklist view with interactive checkboxes
  Widget _buildPickupChecklistView(List<Task> tasks) {
    // Filter to only show pending and picked up tasks
    final checklistTasks = tasks.where((task) =>
    task.status == TaskStatus.pending || task.status == TaskStatus.pickedUp
    ).toList();

    if (checklistTasks.isEmpty) {
      return const Center(
        child: Text(
          'No pickup tasks found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Progress bar for checklist page
        _buildPickupChecklistSummary(checklistTasks),

        // Checklist items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: checklistTasks.length,
            itemBuilder: (context, index) {
              final task = checklistTasks[index];
              final isPickedUp = task.status == TaskStatus.pickedUp;
              final canPickUp = task.status == TaskStatus.pending; // Only pending tasks can be picked up

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPickedUp ? Colors.green.shade200 : Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Interactive Checkbox
                      GestureDetector(
                        onTap: canPickUp ? () => _handlePickupTask(task) : null,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isPickedUp ? Colors.green : (canPickUp ? Colors.grey.shade300 : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isPickedUp ? Colors.green : (canPickUp ? Colors.grey.shade400 : Colors.grey.shade300),
                              width: 2,
                            ),
                          ),
                          child: isPickedUp
                              ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                              : canPickUp
                              ? null
                              : Icon(
                            Icons.lock,
                            color: Colors.grey.shade500,
                            size: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Task details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.taskName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isPickedUp ? Colors.green.shade700 : Colors.black87,
                                decoration: isPickedUp ? TextDecoration.lineThrough : null,
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
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${task.fromLocation} → ${task.toLocation}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Status indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPickedUp
                              ? Colors.green.shade100
                              : _getStatusColor(task.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusDisplayName(task.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPickedUp
                                ? Colors.green.shade700
                                : _getStatusColor(task.status),
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
    );
  }

  // Handle pickup task action
  Future<void> _handlePickupTask(Task task) async {
    final taskController = Provider.of<TaskController>(context, listen: false);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.inventory_2, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirm Pickup'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to mark this task as picked up?'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.taskName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('Order: ${task.taskCode}'),
                    Text('Items: ${task.itemCount}x ${task.itemDescription}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirm Pickup'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Update task status to picked up
      await taskController.updateTaskStatus(task.taskCode, TaskStatus.pickedUp);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${task.taskName}" marked as picked up'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Helper method to get status color
  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.pickedUp:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.purple;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.all:
        return Colors.grey;
    }
  }

  // Build status tab (TaskSchedule_Page style)
  Widget _buildStatusTab(String title, TaskStatus status, TaskController controller) {
    final isSelected = controller.currentFilter == status;
    final count = status == TaskStatus.all
        ? controller.allTasks.length
        : controller.allTasks.where((t) => t.status == status).length;

    return GestureDetector
      (
      onTap: () {
        controller.setFilter(status);
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
        final filteredTasks = taskController.filteredTasks;

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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Update delivery progress',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              // Sort popup (same options as schedule page)
              PopupMenuButton<TaskSort>(
                tooltip: 'Sort by time',
                icon: const Icon(Icons.sort, color: Colors.black),
                initialValue: taskController.sort,
                onSelected: taskController.setSort,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: TaskSort.startTimeAsc,
                    child: Text('Start time ↑ (earliest first)'),
                  ),
                  PopupMenuItem(
                    value: TaskSort.startTimeDesc,
                    child: Text('Start time ↓ (latest first)'),
                  ),
                  PopupMenuItem(
                    value: TaskSort.deadlineAsc,
                    child: Text('Deadline ↑ (closest first)'),
                  ),
                  PopupMenuItem(
                    value: TaskSort.deadlineDesc,
                    child: Text('Deadline ↓ (furthest first)'),
                  ),
                ],
              ),
              // Toggle button for checklist/detailed view
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showChecklistView = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: !_showChecklistView ? Colors.orange : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.list,
                              size: 16,
                              color: !_showChecklistView ? Colors.white : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Detailed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: !_showChecklistView ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showChecklistView = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _showChecklistView ? Colors.orange : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.checklist,
                              size: 16,
                              color: _showChecklistView ? Colors.white : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pickup',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _showChecklistView ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
          body: _showChecklistView
              ? _buildPickupChecklistView(tasks) // Show pickup checklist view
              : Column(
            children: [
              // Status Filter Tabs (TaskSchedule_Page style)
              Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusTab('All Orders', TaskStatus.all, taskController),
                      _buildStatusTab('Pending', TaskStatus.pending, taskController),
                      _buildStatusTab('Picked Up', TaskStatus.pickedUp, taskController),
                      _buildStatusTab('En Route', TaskStatus.inProgress, taskController),
                      _buildStatusTab('Completed', TaskStatus.completed, taskController),
                    ],
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
                                      // Show delivery time for En Route tasks
                                      if (task.status == TaskStatus.inProgress && task.deliveryTime != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              size: 16,
                                              color: Colors.orange.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Delivery Time: ${DateFormat('MMM dd, yyyy HH:mm').format(task.deliveryTime!)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.orange.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
                                      _getTimeAgo((task.lastUpdated ?? task.startTime)),
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

                            // Status Buttons + Set Time when transitioning to En Route
                            Row(
                              children: statusOptions.map((status) {
                                final TaskStatus optionStatus = _getStatusFromDisplayName(status);
                                final bool isSelected = task.status == optionStatus;
                                final IconData icon = _getStatusIcon(optionStatus);
                                final bool isDisabled = optionStatus.index < task.status.index; // prevent going backwards

                                // Dynamic accent color: completed -> green, others -> orange
                                final Color accentColor = optionStatus == TaskStatus.completed
                                    ? Colors.green
                                    : Colors.orange;

                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: isDisabled ? null : () async {
                                        final newStatus = _getStatusFromDisplayName(status);
                                        if (newStatus == TaskStatus.inProgress) {
                                          final selectedTime = await Navigator.push<DateTime>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DeliveryTimePromptPage(
                                                taskCode: task.taskCode,
                                                initialDeliveryTime: task.deliveryTime,
                                              ),
                                            ),
                                          );

                                          if (selectedTime != null) {
                                            await taskController.updateTaskStatus(task.taskCode, TaskStatus.inProgress);
                                            await taskController.updateTaskDeliveryTime(task.taskCode, selectedTime);
                                          }
                                        }
                                        else if (newStatus == TaskStatus.completed) {
                                          final result = await Navigator.of(context).push<Map<String, dynamic>>(
                                            MaterialPageRoute(
                                              builder: (context) => DeliveryConfirmationPage(task: task),
                                            ),
                                          );

                                          if (result != null) {
                                            await taskController.confirmDelivery(
                                              task.taskCode,
                                              result['mechanicSignature'],
                                              result['deliverySignature'],
                                              result['photoFile'],
                                              result['completionTime'],
                                            );
                                          }
                                        } else {
                                          await taskController.updateTaskStatus(task.taskCode, newStatus);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isDisabled
                                              ? Colors.grey.shade200
                                              : (isSelected ? Colors.white : Colors.grey.shade100),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isDisabled ? Colors.grey.shade300 : (isSelected ? accentColor : Colors.grey.shade300),
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              icon,
                                              color: isDisabled ? Colors.grey.shade400 : (isSelected ? accentColor : Colors.grey.shade600),
                                              size: 20,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              status,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDisabled ? Colors.grey.shade500 : (isSelected ? accentColor : Colors.grey.shade600),
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

                            // Navigation and Details Buttons
                            Row(
                              children: [
                                if (task.status == TaskStatus.inProgress) ...[
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigate to Virtual Driver Navigation
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VirtualDriverNavigationPage(task: task),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade600,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.navigation,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Start Navigation',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Edit Timer Button for En Route tasks
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        // Show edit timer dialog
                                        await DeliveryTimeHelper.showDeliveryTimePrompt(
                                          context,
                                          task.taskCode,
                                          isEditMode: true,
                                          initialDeliveryTime: task.deliveryTime,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade600,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Edit Timer',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: GestureDetector(
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
                                ),
                              ],
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