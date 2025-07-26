import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskDetailsPage extends StatelessWidget {
  static const routeName = '/task-details';

  final Task task;

  const TaskDetailsPage({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task: ${task.taskCode}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${task.fromLocation}', style: _infoStyle),
            Text('To: ${task.toLocation}', style: _infoStyle),
            Text('Item: ${task.itemDescription}', style: _infoStyle),
            Text('Start Time: ${task.startTime}', style: _infoStyle),
            Text('Deadline: ${task.deadline}', style: _infoStyle),
            Text('Status: ${task.status.name}', style: _infoStyle),
            Text('Owner: ${task.ownerId}', style: _infoStyle),
          ],
        ),
      ),
    );
  }

  TextStyle get _infoStyle => const TextStyle(fontSize: 16, height: 1.5);
}
