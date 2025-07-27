import 'package:flutter/material.dart';

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabName;
  final Widget rootPage;

  const TabNavigator({
    super.key,
    required this.navigatorKey,
    required this.tabName,
    required this.rootPage,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (_) => rootPage,
        );
      },
    );
  }
}
