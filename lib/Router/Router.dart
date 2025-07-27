import 'package:flutter/material.dart';
import 'package:fluttter_project/View/Login_Page.dart';
import 'package:fluttter_project/Common/MainTabController.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case MainTabController.routeName:
        return MaterialPageRoute(builder: (_) => const MainTabController());
      
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
