import 'package:flutter/material.dart';
import 'package:fluttter_project/View/TaskSchedule_Page.dart';
import 'package:intl/intl.dart'; // if you're formatting datetime
import 'Common/TaskCard.dart'; // adjust the path if needed
import 'models/task.dart';       // make sure Task and TaskStatus are defined
import 'Router/Router.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery App',
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
    );
  }
}

