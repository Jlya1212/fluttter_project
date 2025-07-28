import 'package:flutter/material.dart';
import 'package:fluttter_project/Models/Task.dart';

class PartRequestDetailsPage extends StatefulWidget {
  final Task task;

  const PartRequestDetailsPage({Key? key, required this.task}) : super(key: key);

  @override
  _PartRequestDetailsPageState createState() => _PartRequestDetailsPageState();
}

class _PartRequestDetailsPageState extends State<PartRequestDetailsPage> {
  late TaskStatus _currentStatus;
  late TaskStatus _originalStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task.status;

  }

  void _navigateBack() {
    Navigator.of(context).pop(_currentStatus);
  }

  void _handleConfirmation() {
    Navigator.of(context).pop(TaskStatus.completed);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // A soft off-white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),

          onPressed: _navigateBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Part Request Details',
              style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '#${widget.task.taskCode}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              label: const Text(
                'HIGH',
                style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFFFFEBEE),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusUpdateSection(),
            const SizedBox(height: 20),
            _buildPartDetailsSection(),
            const SizedBox(height: 20),
            _buildDestinationInfoSection(),
            const SizedBox(height: 20),
            _buildSpecialInstructionsSection(),
            const SizedBox(height: 24),
            if (_currentStatus == TaskStatus.completed)
              ElevatedButton.icon(
                onPressed: _handleConfirmation, //This is required to change when delivery confirmation page done
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
                  elevation: 4,
                  shadowColor: Colors.orange.withOpacity(0.4),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Status Update', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              _buildStatusChip(_currentStatus)
            ],
          ),
          const SizedBox(height: 20),

          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _statusButton(TaskStatus.pending, 'Pending', Icons.pending_actions_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _statusButton(TaskStatus.pickedUp, 'Picked Up', Icons.inventory_2_outlined)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _statusButton(TaskStatus.inProgress, 'En Route', Icons.local_shipping_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _statusButton(TaskStatus.completed, 'Delivered', Icons.check_circle_outline)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(TaskStatus status, String label, IconData icon) {
    final bool isSelected = _currentStatus == status;
    return InkWell(
      onTap: () => setState(() => _currentStatus = status),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.orange.shade800 : Colors.grey.shade700, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.orange.shade900 : Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartDetailsSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Part Details & Quantities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 16),
          _detailRow('Part Name:', widget.task.taskName),
          const Divider(),
          _detailRow('Part Number:', widget.task.taskCode),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quantity:', style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(
                    widget.task.itemCount.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          _detailRow('Vehicle:', widget.task.itemDescription),
        ],
      ),
    );
  }

  Widget _buildDestinationInfoSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Destination Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 16),
          _infoCard(
            title: 'Workshop & Bay',
            content: widget.task.toLocation,
            icon: Icons.store_mall_directory_outlined,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 12),
          _infoCard(
            title: 'Assigned Mechanic',
            content: widget.task.ownerId,
            icon: Icons.person_outline,
            color: Colors.teal,

          ),
        ],
      ),
    );
  }

  Widget _buildSpecialInstructionsSection() {
    return _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Special Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
            const SizedBox(height: 16),
            _infoCard(
                title: 'Delivery Notes',
                content: 'Contact mechanic Mike Rodriguez upon arrival at Bay 3',
                icon: Icons.info_outline,
                color: Colors.blueAccent)
          ],
        ));
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF333333))),
        ],
      ),
    );
  }

  Widget _infoCard(
      {required String title,
        required String content,
        required IconData icon,
        required Color color,
        Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
              ],
            ),
          ),
          if (trailing != null) trailing,
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
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        statusText = 'Pending';
        break;
      case TaskStatus.pickedUp:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        statusText = 'Picked Up';
        break;
      case TaskStatus.inProgress:
        backgroundColor = Colors.indigo.shade100;
        textColor = Colors.indigo.shade800;
        statusText = 'En Route';
        break;
      case TaskStatus.completed:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        statusText = 'Delivered';
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        statusText = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}