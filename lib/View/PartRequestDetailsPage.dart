import 'package:flutter/material.dart';
import 'package:fluttter_project/models/task.dart';

class PartRequestDetailsPage extends StatefulWidget {
  final Task task;

  const PartRequestDetailsPage({Key? key, required this.task}) : super(key: key);

  @override
  _PartRequestDetailsPageState createState() => _PartRequestDetailsPageState();
}

class _PartRequestDetailsPageState extends State<PartRequestDetailsPage> {
  late TaskStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task.status;
  }

  void _updateStatus(TaskStatus newStatus) {
    setState(() {
      _currentStatus = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Part Request Details',
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
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
              label: Text(
                'HIGH',
                style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.red[100],
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
            const SizedBox(height: 20),
            if (_currentStatus == TaskStatus.completed)
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to Delivery Confirmation Page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete Delivery Confirmation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          const Text('Delivery Status Update', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusButton(TaskStatus.pending, 'Pending', Icons.timer_outlined),
              _statusButton(TaskStatus.inProgress, 'Picked Up', Icons.inventory_2_outlined),
              _statusButton(TaskStatus.completed, 'Delivered', Icons.check_circle_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(TaskStatus status, String label, IconData icon) {
    final bool isSelected = _currentStatus == status;
    return GestureDetector(
      onTap: () => _updateStatus(status),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange[100] : Colors.grey[200],
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(icon, color: isSelected ? Colors.orange : Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildPartDetailsSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Part Details & Quantities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _detailRow('Part Name:', widget.task.taskName),
          _detailRow('Part Number:', widget.task.taskCode),
          _detailRow('Quantity:', widget.task.itemCount.toString()),
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
          const Text('Destination Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _infoCard(
            title: 'Workshop & Bay',
            content: widget.task.toLocation,
            icon: Icons.store,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _infoCard(
            title: 'Assigned Mechanic',
            content: widget.task.ownerId,
            icon: Icons.person,
            color: Colors.blue,
            trailing: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.call, size: 16),
              label: const Text('Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
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
            const Text('Special Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _infoCard(
                title: 'Delivery Notes',
                content: 'Contact mechanic upon arrival.',
                icon: Icons.notes,
                color: Colors.green
            )
          ],
        )
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _infoCard({required String title, required String content, required IconData icon, required Color color, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}