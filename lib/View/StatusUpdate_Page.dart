import 'package:flutter/material.dart';

class StatusUpdate extends StatelessWidget {
  const StatusUpdate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Pending',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.orange,
      ),
    );
  }
}