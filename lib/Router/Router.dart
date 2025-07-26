import 'package:flutter/material.dart';
import 'package:fluttter_project/models/task.dart';
import '../View/home_page.dart';
import '../View/TaskSchedule_Page.dart';
import '../View/TaskDetails_Page.dart';
class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());

      case DeliverySchedulePage.routeName:
        return MaterialPageRoute(builder: (_) => const DeliverySchedulePage());

      case TaskDetailsPage.routeName:
        final task = settings.arguments as Task;
        return MaterialPageRoute(
          builder: (_) => TaskDetailsPage(task: task),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
