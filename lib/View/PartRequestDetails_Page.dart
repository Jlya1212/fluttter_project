import 'package:flutter/material.dart';
import 'package:fluttter_project/Models/Task.dart';
import 'package:fluttter_project/View/DeliveryConfirmation_Page.dart';
import 'package:fluttter_project/ViewModel/TaskController.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PartRequestDetailsPage extends StatefulWidget {
  final Task task;

  const PartRequestDetailsPage({Key? key, required this.task}) : super(key: key);

  @override
  _PartRequestDetailsPageState createState() => _PartRequestDetailsPageState();
}

class _PartRequestDetailsPageState extends State<PartRequestDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, controller, child) {
        final task = controller.allTasks.firstWhere(
              (t) => t.taskCode == widget.task.taskCode,
          orElse: () => widget.task,
        );

        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop(task.status);
            return false;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: _buildAppBar(context, task),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Always show the status update section
                  _buildStatusUpdateSection(context, controller, task),
                  const SizedBox(height: 20),

                  // If completed, show the confirmation details
                  if (task.status == TaskStatus.completed) ...[
                    _buildDeliveryConfirmationSection(task),
                    const SizedBox(height: 20),
                  ],

                  _buildPartDetailsSection(task),
                  const SizedBox(height: 20),
                  _buildDestinationInfoSection(task),
                  const SizedBox(height: 20),
                  _buildSpecialInstructionsSection(task),
                  const SizedBox(height: 24),

                  if (task.status == TaskStatus.pickedUp || task.status == TaskStatus.inProgress)
                    ElevatedButton.icon(
                      onPressed: () => _handleConfirmation(context, controller, task),
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text(
                        'Complete Delivery Confirmation',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, Task task) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(task.status),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Part Request Details',
            style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '#${task.taskCode}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirmation(BuildContext context, TaskController controller, Task task) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => DeliveryConfirmationPage(task: task),
      ),
    );

    if (result != null) {
      controller.confirmDelivery(
        task.taskCode,
        result['signature'],
        result['photoUrl'],
        result['completionTime'],
      );
    }
  }

  void _onStatusButtonTapped(BuildContext context, TaskController controller, Task task, TaskStatus newStatus) {
    // Prevent any action if the task is already completed
    if (task.status == TaskStatus.completed) return;

    if (newStatus == TaskStatus.completed) {
      _handleConfirmation(context, controller, task);
    } else {
      controller.updateTaskStatus(task.taskCode, newStatus);
    }
  }

  Widget _buildStatusUpdateSection(BuildContext context, TaskController controller, Task task) {
    final isCompleted = task.status == TaskStatus.completed;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Status Update', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              _buildStatusChip(task.status)
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _statusButton(context, controller, task, TaskStatus.pending, 'Pending', Icons.pending_actions_outlined, isCompleted: isCompleted)),
              const SizedBox(width: 12),
              Expanded(child: _statusButton(context, controller, task, TaskStatus.pickedUp, 'Picked Up', Icons.inventory_2_outlined, isCompleted: isCompleted)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statusButton(context, controller, task, TaskStatus.inProgress, 'En Route', Icons.local_shipping_outlined, isCompleted: isCompleted)),
              const SizedBox(width: 12),
              Expanded(child: _statusButton(context, controller, task, TaskStatus.completed, 'Delivered', Icons.check_circle_outline, isCompleted: isCompleted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(BuildContext context, TaskController controller, Task task, TaskStatus status, String label, IconData icon, {required bool isCompleted}) {
    final bool isSelected = task.status == status;

    // Define colors for the completed but not selected state
    Color completedBackgroundColor = Colors.green.withOpacity(0.08);
    Color completedContentColor = Colors.green.shade800;

    // Determine current state colors
    Color backgroundColor = Colors.grey.shade100;
    Color contentColor = Colors.grey.shade700;
    Color borderColor = Colors.grey.shade200;
    FontWeight fontWeight = FontWeight.w500;

    if (isCompleted) {
      backgroundColor = completedBackgroundColor;
      contentColor = completedContentColor;
      borderColor = Colors.transparent;
      if (isSelected) { // The 'Delivered' button when completed
        backgroundColor = Colors.orange.withOpacity(0.15);
        contentColor = Colors.orange.shade900;
        borderColor = Colors.orange;
        fontWeight = FontWeight.bold;
      }
    } else if (isSelected) {
      backgroundColor = Colors.orange.withOpacity(0.15);
      contentColor = Colors.orange.shade900;
      borderColor = Colors.orange;
      fontWeight = FontWeight.bold;
    }


    return InkWell(
      onTap: isCompleted ? null : () => _onStatusButtonTapped(context, controller, task, status),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            if(isCompleted && !isSelected) // Show a solid circle for completed steps
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completedContentColor,
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              )
            else // Default icon display
              Icon(icon, color: contentColor, size: 28),

            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: fontWeight, color: contentColor)),
          ],
        ),
      ),
    );
  }


  Widget _buildDeliveryConfirmationSection(Task task) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Confirmation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery Completed', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                    if (task.completionTime != null)
                      Text(DateFormat('yyyy-MM-dd hh:mm a').format(task.completionTime!), style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildConfirmationDetailItem(
            icon: Icons.draw,
            iconColor: Colors.blue.shade700,
            title: 'Digital Signature',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.confirmationSign ?? 'No signature captured.',
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildConfirmationDetailItem(
            icon: Icons.camera_alt,
            iconColor: Colors.purple.shade700,
            title: 'Delivery Photo',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    task.confirmationPhoto ?? 'https://via.placeholder.com/400x200?text=No+Photo',
                    height: 150,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (context, error, stack) => const Icon(Icons.error),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Parts delivered and documented at ${task.toLocation}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildTag(text: 'Confirmed By\n${task.ownerId}', backgroundColor: Colors.blue, textColor: Colors.blue.shade800),
              const SizedBox(width: 12),
              _buildTag(text: 'Workshop\n${task.toLocation.split(' - ').last}', backgroundColor: Colors.orange, textColor: Colors.orange.shade800),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationDetailItem({required IconData icon, required Color iconColor, required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildTag({required String text, required Color backgroundColor, required Color textColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildPartDetailsSection(Task task) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Part Details & Quantities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 16),
          _detailRow('Part Name:', task.taskName),
          const Divider(),
          _detailRow('Part Number:', task.taskCode),
          const Divider(),
          _detailRowWithBadge('Quantity:', task.itemCount.toString()),
          const Divider(),
          _detailRow('Vehicle:', task.itemDescription),
          if (task.customerName != null) ...[
            const Divider(),
            _detailRow('Customer:', task.customerName!),
          ],
          if (task.partDetails != null) ...[
            const SizedBox(height: 16),
            _infoCard(
              title: 'Part Details',
              content: task.partDetails!,
              icon: Icons.settings,
              color: Colors.blueGrey.shade50, textColor: Colors.blueGrey.shade800,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDestinationInfoSection(Task task) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Destination Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 16),
          _infoCard(
            title: 'Workshop & Bay',
            content: task.toLocation,
            icon: Icons.store_mall_directory_outlined,
            color: const Color(0xFFFBE9E7),
            textColor: const Color(0xFFD84315),
          ),
          const SizedBox(height: 12),
          _infoCard(
            title: 'Assigned Mechanic',
            content: task.ownerId,
            icon: Icons.person_outline,
            color: const Color(0xFFE3F2FD),
            textColor: const Color(0xFF1565C0),
          ),
          if (task.destinationAddress != null) ...[
            const SizedBox(height: 12),
            _infoCard(
              title: 'Address',
              content: task.destinationAddress!,
              icon: Icons.location_on_outlined,
              color: const Color(0xFFE8F5E9),
              textColor: const Color(0xFF2E7D32),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _smallInfoCard(
                  'Required By',
                  DateFormat('hh:mm a').format(task.deadline),
                  const Color(0xFFFCE4EC),
                  const Color(0xFFAD1457),
                ),
              ),
              const SizedBox(width: 12),
              if (task.estimatedDurationMinutes != null)
                Expanded(
                  child: _smallInfoCard(
                    'Est. Duration',
                    '${task.estimatedDurationMinutes} minutes',
                    const Color(0xFFF3E5F5),
                    const Color(0xFF6A1B9A),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _infoCard(
            title: 'Pickup Location',
            content: task.fromLocation,
            icon: Icons.warehouse_outlined,
            color: const Color(0xFFFFFDE7),
            textColor: const Color(0xFFF9A825),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialInstructionsSection(Task task) {
    bool hasInstructions = task.specialInstructions != null && task.specialInstructions!.isNotEmpty;
    bool hasNotes = task.deliveryNotes != null && task.deliveryNotes!.isNotEmpty;
    if (!hasInstructions && !hasNotes) return const SizedBox.shrink();
    return _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Special Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
            if(hasInstructions) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.specialInstructions!,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF333333), height: 1.5),
                ),
              ),
            ],
            if (hasNotes) ...[
              const SizedBox(height: 16),
              _infoCard(
                title: 'Delivery Notes',
                content: task.deliveryNotes!,
                icon: Icons.info_outline,
                color: const Color(0xFFFFF3E0),
                textColor: const Color(0xFFE65100),
              )
            ]
          ],
        ));
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF333333)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRowWithBadge(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 15)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20)
            ),
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
      {required String title,
        required String content,
        required IconData icon,
        required Color color,
        required Color textColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12)),
                const SizedBox(height: 4),
                Text(content, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallInfoCard(String title, String content, Color bgColor, Color fgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: fgColor.withOpacity(0.8), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    Color backgroundColor;
    Color textColor;
    String statusText;
    switch (status) {
      case TaskStatus.pending:
        backgroundColor = Colors.orange.shade100; textColor = Colors.orange.shade800; statusText = 'Pending'; break;
      case TaskStatus.pickedUp:
        backgroundColor = Colors.blue.shade100; textColor = Colors.blue.shade800; statusText = 'Picked Up'; break;
      case TaskStatus.inProgress:
        backgroundColor = Colors.indigo.shade100; textColor = Colors.indigo.shade800; statusText = 'En Route'; break;
      case TaskStatus.completed:
        backgroundColor = Colors.green.shade100; textColor = Colors.green.shade800; statusText = 'Delivered'; break;
      default:
        backgroundColor = Colors.grey.shade100; textColor = Colors.grey.shade800; statusText = 'Unknown';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Text(statusText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}

