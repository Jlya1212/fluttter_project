import 'package:flutter/material.dart';
import 'package:fluttter_project/Common/TabNavigator.dart';
import 'package:fluttter_project/View/PartRequestDetails_Page.dart';
import 'package:provider/provider.dart';
import '../View/Home_Page.dart';
import '../View/TaskSchedule_Page.dart';
import '../View/Profile_Page.dart';
import '../ViewModel/UserController.dart';

class MainTabController extends StatefulWidget {
  const MainTabController({super.key});
  static const routeName = '/main';

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !(await _navigatorKeys[_currentIndex].currentState!.maybePop());
        return isFirstRouteInCurrentTab;

        
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            TabNavigator(
              navigatorKey: _navigatorKeys[0],
              tabName: 'home',
              rootPage: HomePage(jumpToSchedulePressed: () => switchToTab(1)),
            ),
            TabNavigator(
              navigatorKey: _navigatorKeys[1],
              tabName: 'schedule',
              rootPage: const DeliverySchedulePage(),
            ),
            TabNavigator(
              navigatorKey: _navigatorKeys[2],
              tabName: 'profile',
              rootPage: const ProfilePage(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
            BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Status Update'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          
          ],
        ),
      ),
    );
  }
  void switchToTab(int index) {
  setState(() {
    _currentIndex = index;
  });
}
}