import 'package:flutter/material.dart';
import 'package:fluttter_project/View/Login_Page.dart';
import 'package:fluttter_project/Common/MainTabController.dart';
import 'package:fluttter_project/View/DeliveryTimePromptPage.dart';
import 'package:fluttter_project/View/VirtualDriverNavigationPage.dart';
import 'package:fluttter_project/Models/Task.dart';

import '../View/DeliveryTimePromptPage.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case MainTabController.routeName:
        return MaterialPageRoute(builder: (_) => const MainTabController());

      case '/delivery-time-prompt':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DeliveryTimePromptPage(
            taskCode: args['taskCode'],
            onDeliveryTimeSelected: args['onDeliveryTimeSelected'],
            initialDeliveryTime: args['initialDeliveryTime'],
          ),
        );

      case '/virtual-driver-navigation':
        final task = settings.arguments as Task;
        return MaterialPageRoute(
          builder: (_) => VirtualDriverNavigationPage(task: task),
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
