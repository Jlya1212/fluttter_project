import 'package:flutter/material.dart';
import 'package:fluttter_project/Common/MainTabController.dart';
import 'package:provider/provider.dart';
import '../ViewModel/UserController.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorText;
  bool _isLoading = false; // Add a loading state
  late final UserController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<UserController>(context, listen: false);
  }

  Future<void> _handleLogin() async {
    // Prevent multiple login attempts while one is in progress
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final id = _idController.text.trim();
    final password = _passwordController.text;

    // Use the updated userLogin method
    final result = await _controller.userLogin(id, password);

    if (!mounted) return; // Check if the widget is still in the tree

    if (result.isSuccess) {
      Navigator.pushReplacementNamed(context, MainTabController.routeName);
    } else {
      setState(() {
        _errorText = result.errorMessage ?? 'Login failed';
      });
    }

    setState(() {
      _isLoading = false; // Reset loading state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D5DF6), Color(0xFFFF5F6D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_shipping, size: 48, color: Colors.deepPurple),
                const SizedBox(height: 16),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Parts ',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Delivery',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Job Management System',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: 'Personnel Email',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(),
                  ),
                ),

                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 24),

                // Show a progress indicator when loading
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                  onPressed: _handleLogin,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D5DF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}