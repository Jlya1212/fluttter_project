import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'Models/Task.dart';
import 'Repository/FirebaseRepository.dart';
import 'Router/Router.dart';

// Import Firebase Core and the generated options file
import 'package:firebase_core/firebase_core.dart';
import 'ViewModel/TaskController.dart';
import 'ViewModel/UserController.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized before we run async code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create a single repo instance
  final repo = FirebaseRepository();

  // await seedTasks(repo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController(repo)),
        ChangeNotifierProvider(create: (_) => TaskController(repo)),
      ],
      child: const MyApp(),
    ),
  );
}

/* Future<void> seedTasks(FirebaseRepository repo) async {
  final drivers = ["Jane S", "John D"];

  final fromLocations = [
    "Central Warehouse",
    "North Hub",
    "South Depot",
  ];

  final toLocations = [
    "Auto Repair Shop A",
    "Car Service Center B",
    "Mechanic Garage C",
    "Parts Store D",
  ];

  final parts = [
    "Brake Pads",
    "Oil Filter",
    "Spark Plugs",
    "Air Filter",
    "Timing Belt",
    "Radiator",
    "Alternator",
    "Clutch Kit",
    "Headlights",
    "Battery",
  ];

  for (int i = 0; i < 20; i++) {
    final driverName = drivers[i % 2];
    final part = parts[i % parts.length];
    final from = fromLocations[i % fromLocations.length];
    final to = toLocations[i % toLocations.length];

    final task = Task(
      taskName: "Deliver $part",
      taskCode: "TST-${DateTime.now().millisecondsSinceEpoch}-$i",
      fromLocation: from,
      toLocation: to,
      itemDescription: "$part for customer order #${1000 + i}",
      itemCount: (i % 3) + 1, // 1–3 items
      startTime: DateTime.now().add(Duration(hours: i)), // staggered start
      deadline: DateTime.now().add(Duration(hours: i + 5)),
      status: TaskStatus.pending,
      ownerId: "system",
      customerName: "Customer ${String.fromCharCode(65 + i)}",
      partDetails: "$part (batch ${2024 + i})",
      destinationAddress: "${10 + i} Industrial Road, District ${i % 4 + 1}",
      estimatedDurationMinutes: 45 + (i % 4) * 15, // 45, 60, 75, 90
      specialInstructions: (i % 2 == 0)
          ? "Leave at front desk"
          : "Call before delivery",
      deliveryNotes: "N/A",
      assignDriverName: driverName,
    );

    final result = await repo.addTaskToDB(task);
    if (result.isSuccess) {
      print("✅ Task ${task.taskCode} added for $driverName ($part → $to)");
    } else {
      print("❌ Failed to add task: ${result.errorMessage}");
    }
  }
} */


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
