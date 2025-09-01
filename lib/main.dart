import 'package:flutter/material.dart';

import 'package:fluttter_project/Repository/FirebaseRepository.dart';
import 'package:fluttter_project/ViewModel/TaskController.dart';
import 'package:fluttter_project/ViewModel/UserController.dart';
import 'package:provider/provider.dart';
import 'Router/Router.dart';

// Import Firebase Core and the generated options file
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized before we run async code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the generated options file
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // We now provide our app with the real FirebaseRepository
        ChangeNotifierProvider(create: (_) => UserController(FirebaseRepository())),
        ChangeNotifierProvider(create: (_) => TaskController(FirebaseRepository())),
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

