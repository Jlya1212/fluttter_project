import 'package:flutter/material.dart';
import 'package:fluttter_project/Repository/MockUpRepository.dart';
import 'package:fluttter_project/View/Home_Page.dart';
import 'package:fluttter_project/View/TaskSchedule_Page.dart';
import 'package:provider/provider.dart';
import '../Models/User.dart';
import '../ViewModel/UserController.dart';
import '../Common/Result.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const String routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3; // Profile tab is active

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<UserController>(context);
    final Result<User> result = controller.getCurrentUser();

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: result.isSuccess
            ? _buildProfileInfo(result.data!)
            : _buildError(context, result.errorMessage ?? "Unknown error"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex, // track active tab
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index); // update tab

          switch (index) {
            case 0:
              Navigator.pushNamed(context, HomePage.routeName);
              break;
            case 1:
              Navigator.pushNamed(context, DeliverySchedulePage.routeName);
              break;
            case 2:
              Navigator.pushNamed(context, '/status');
              break;
            case 3:
              Navigator.pushNamed(context, ProfilePage.routeName);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Status Update'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("User Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text("👤 Name: ${user.username}"),
        Text("📧 Email: ${user.email}"),
        Text("📞 Phone: ${user.phone}"),
        const SizedBox(height: 24),
        const Text("🎉 You are logged in!", style: TextStyle(color: Colors.green)),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("⚠️ $message", style: const TextStyle(fontSize: 16, color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Go to Login"),
          ),
        ],
      ),
    );
  }
}
