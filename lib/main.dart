import 'package:flutter/material.dart';
import 'package:fluttter_project/View/TaskSchedule.dart';
import 'package:intl/intl.dart'; // if you're formatting datetime
import 'View/TaskCard.dart'; // adjust the path if needed
import 'models/task.dart';       // make sure Task and TaskStatus are defined

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Schedule',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const DeliverySchedulePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

