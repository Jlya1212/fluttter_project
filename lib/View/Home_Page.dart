// lib/View/Home_Page.dart

import 'package:flutter/material.dart';
import 'package:fluttter_project/ViewModel/TaskController.dart';
import 'package:provider/provider.dart';

import '../Models/Task.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.jumpToSchedulePressed,
    required this.jumpToUpdatesPressed, // Add this
  });

  final VoidCallback jumpToSchedulePressed;
  final VoidCallback jumpToUpdatesPressed; // Add this

  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load the task data when the page is first loaded
    // Use addPostFrameCallback to ensure the context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskController>(context, listen: false)
          .loadTasksAndSetFilter(TaskStatus.all);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to listen to changes in TaskController
    return Consumer<TaskController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          appBar: _buildAppBar(controller),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummarySection(controller),
                const SizedBox(height: 24),
                _buildJobFunctionsSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  // Custom AppBar like in the screenshot
  AppBar _buildAppBar(TaskController controller) {
    return AppBar(
      backgroundColor: const Color(0xFFF4F6F8),
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_shipping,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job Management',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              Text(
                'Part Delivery Personnel',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.grey.shade600),
          onPressed: () {
            controller.loadTasksAndSetFilter(TaskStatus.all);
          },
        ),
      ],
    );
  }

  // "Today's Summary" section
  Widget _buildSummarySection(TaskController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Summary",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                icon: Icons.access_time,
                color: Colors.amber,
                label: 'Pending',
                count: controller.pendingTaskCount,
              ),
              _buildSummaryItem(
                icon: Icons.local_shipping,
                color: Colors.orange,
                label: 'En Route',
                count: controller.inProgressTaskCount,
              ),
              _buildSummaryItem(
                icon: Icons.check,
                color: Colors.green,
                label: 'Delivered',
                count: controller.completedTaskCount,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper for a single item in the summary (e.g., Pending, En Route)
  Widget _buildSummaryItem(
      {required IconData icon,
        required Color color,
        required String label,
        required int count}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  // "Job Functions" section
  Widget _buildJobFunctionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Functions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildFunctionCard(
          icon: Icons.calendar_today,
          color: Colors.blue,
          backgroundColor: Colors.blue.withOpacity(0.1),
          title: 'Delivery Schedule View',
          subtitle: 'View parts orders and destinations',
          onTap: widget.jumpToSchedulePressed,
        ),
        const SizedBox(height: 12),
        _buildFunctionCard(
          icon: Icons.update,
          color: Colors.orange,
          backgroundColor: Colors.orange.withOpacity(0.1),
          title: 'Status Updates',
          subtitle: 'Update delivery progress status',
          onTap: widget.jumpToUpdatesPressed,
        ),
      ],
    );
  }

  // Helper for the large tappable cards (e.g., Delivery Schedule)
  Widget _buildFunctionCard({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }
}