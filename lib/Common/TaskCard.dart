import 'package:flutter/material.dart';
import 'package:fluttter_project/View/PartRequestDetails_Page.dart';
import '../Models/Task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({
    Key? key,
    required this.task,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatusIndicator(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.taskName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          _buildStatusChip(),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        task.taskCode,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDate(task.startTime)} ${_formatTime(task.startTime)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getLocationBackgroundColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.fromLocation,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildUserIcon(),
                          const SizedBox(width: 8),
                          Text(
                            task.ownerId,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                          const Spacer(),
                          if (task.status != TaskStatus.completed)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  size: 12,
                                  color: Color(0xFF6C63FF),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _randomTimeCost(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6C63FF),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(width: 12),
                          _buildActionButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color color = _getStatusColor();
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusInfo = _getStatusInfo();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo['backgroundColor'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusInfo['text'],
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: statusInfo['textColor'],
        ),
      ),
    );
  }

  Widget _buildUserIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF34C759),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.person,
        size: 14,
        color: Colors.white,
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getActionIcon(),
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Color _getStatusColor() {
    switch (task.status) {
      case TaskStatus.pending:
        return const Color(0xFFFF9500);
      case TaskStatus.pickedUp:
        return const Color(0xFF007AFF);
      case TaskStatus.inProgress:
        return const Color(0xFF6C63FF);
      case TaskStatus.completed:
        return const Color(0xFF34C759);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  Color _getLocationBackgroundColor() {
    switch (task.status) {
      case TaskStatus.pending:
        return const Color(0xFFFFF4E6); // Light orange
      case TaskStatus.pickedUp:
        return const Color(0xFFE6F3FF); // Light blue
      case TaskStatus.inProgress:
        return const Color(0xFFF0EFFF); // Light purple
      case TaskStatus.completed:
        return const Color(0xFFE8F5E8); // Light green
      default:
        return const Color(0xFFF5F5F5); // Light gray
    }
  }

  IconData _getActionIcon() {
    switch (task.status) {
      case TaskStatus.pending:
        return Icons.play_arrow;
      case TaskStatus.pickedUp:
        return Icons.inventory_2;
      case TaskStatus.inProgress:
        return Icons.local_shipping;
      case TaskStatus.completed:
        return Icons.check;
      default:
        return Icons.more_horiz;
    }
  }

  Map<String, dynamic> _getStatusInfo() {
    switch (task.status) {
      case TaskStatus.pending:
        return {
          'text': 'Pending',
          'backgroundColor': const Color(0xFFFFF4E6),
          'textColor': const Color(0xFFB8860B),
        };
      case TaskStatus.pickedUp:
        return {
          'text': 'Picked Up',
          'backgroundColor': const Color(0xFFE6F3FF),
          'textColor': const Color(0xFF0066CC),
        };
      case TaskStatus.inProgress:
        return {
          'text': 'En Route',
          'backgroundColor': const Color(0xFFF0EFFF),
          'textColor': const Color(0xFF6C63FF),
        };
      case TaskStatus.completed:
        return {
          'text': 'Completed',
          'backgroundColor': const Color(0xFFE8F5E8),
          'textColor': const Color(0xFF2D7A2D),
        };
      default:
        return {
          'text': 'Unknown',
          'backgroundColor': const Color(0xFFF5F5F5),
          'textColor': const Color(0xFF666666),
        };
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _randomTimeCost() {
    final random = DateTime.now().millisecondsSinceEpoch % 60;
    return '${random + 15} min';
  }
}