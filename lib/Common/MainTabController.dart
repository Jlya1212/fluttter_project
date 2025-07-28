import 'package:flutter/material.dart';
import 'package:fluttter_project/Common/TabNavigator.dart';
import '../View/Home_Page.dart';
import '../View/TaskSchedule_Page.dart';
import '../View/Profile_Page.dart';
import '../View/StatusUpdate_Page.dart';

class MainTabController extends StatefulWidget {
  const MainTabController({super.key});
  static const routeName = '/main';

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;
  final List<int> _tabHistoryStack = [0];

  void switchToTab(int index) {
    if (index != _currentIndex) {
      _tabHistoryStack.add(index);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<bool> _onWillPop() async {
    final NavigatorState currentTabNav =
        _navigatorKeys[_currentIndex].currentState!;

    final isFirstRouteInTab = !await currentTabNav.maybePop();

    if (isFirstRouteInTab) {
      if (_tabHistoryStack.length > 1) {
        _tabHistoryStack.removeLast();
        final previousTab = _tabHistoryStack.last;
        setState(() => _currentIndex = previousTab);
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, 
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            TabNavigator(
              navigatorKey: _navigatorKeys[0],
              tabName: 'home',
              rootPage: HomePage(
                jumpToSchedulePressed: () => switchToTab(1),
                jumpToUpdatesPressed: () => switchToTab(2),
              ),
            ),
            TabNavigator(
              navigatorKey: _navigatorKeys[1],
              tabName: 'schedule',
              rootPage: DeliverySchedulePage(maybePop: () => _onWillPop()),
            ),
            TabNavigator(
              navigatorKey: _navigatorKeys[2],
              tabName: 'Status Update',
              rootPage: const StatusUpdate(),
            ),
            TabNavigator(
              navigatorKey: _navigatorKeys[3],
              tabName: 'profile',
              rootPage: const ProfilePage(),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: switchToTab,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,

              selectedItemColor: Colors.deepPurple,
              unselectedItemColor: Colors.grey.shade500,

              showSelectedLabels: true,
              showUnselectedLabels: false,

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.schedule_outlined),
                  activeIcon: Icon(Icons.schedule),
                  label: 'Schedule',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.update_outlined),
                  activeIcon: Icon(Icons.update),
                  label: 'Updates',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
  // TODO : 
  // develop a stack call history for the new tab
  // pop function   
  // push function : everytimes the swtichToTab is called, the new tab will be pushed to the stack

