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
