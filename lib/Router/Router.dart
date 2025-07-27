import 'package:flutter/material.dart';
import 'package:fluttter_project/View/Login_Page.dart';
import 'package:fluttter_project/Models/Task.dart';
import 'package:fluttter_project/ViewModel/UserController.dart';
import '../View/home_page.dart';
import '../View/TaskSchedule_Page.dart';
import '../View/TaskDetails_Page.dart';
import '../View/Profile_Page.dart';
class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case DeliverySchedulePage.routeName:
        return MaterialPageRoute(builder: (_) => const DeliverySchedulePage());

      case TaskDetailsPage.routeName:
        final task = settings.arguments as Task;
        return MaterialPageRoute(
          builder: (_) => TaskDetailsPage(task: task),
        );
      case HomePage.routeName:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case LoginPage.routeName:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case ProfilePage.routeName:
        final userController = settings.arguments as UserController;
        return MaterialPageRoute(
          builder: (_) => ProfilePage(controller: userController),
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
