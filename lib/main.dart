// lib/main.dart

import 'package:flutter/material.dart';
import 'package:fluttter_project/Repository/MockUpRepository.dart';
import 'package:fluttter_project/ViewModel/TaskController.dart'; // Import TaskController
import 'package:fluttter_project/ViewModel/UserController.dart';
import 'package:provider/provider.dart';
import 'Router/Router.dart';

void main() {
  runApp(
    // Use MultiProvider to provide both controllers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController(MockUpRepository())),
        ChangeNotifierProvider(create: (_) => TaskController(MockUpRepository())),
      ],
      child: const MyApp(),
    ),
  );
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