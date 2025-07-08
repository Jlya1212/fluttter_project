import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbiting Nav App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const OrbitingNavApp(),
    );
  }
}

// --- The Single Creative Navigation Class ---

class OrbitingNavApp extends StatefulWidget {
  const OrbitingNavApp({super.key});

  @override
  State<OrbitingNavApp> createState() => _OrbitingNavAppState();
}

class _OrbitingNavAppState extends State<OrbitingNavApp> {
  // STATE
  int _currentIndex = 0;

  // Each map represents a "page" or a "planet" in our system.
  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Dashboard',
      'icon': Icons.dashboard_rounded,
      'color': Colors.redAccent,
    },
    {
      'title': 'Explore',
      'icon': Icons.explore_rounded,
      'color': Colors.greenAccent,
    },
    {
      'title': 'Mail',
      'icon': Icons.mail_rounded,
      'color': Colors.lightBlueAccent,
    },
    {
      'title': 'Profile',
      'icon': Icons.person_rounded,
      'color': Colors.orangeAccent,
    },
    {
      'title': 'Cloud',
      'icon': Icons.cloud_upload_rounded,
      'color': Colors.purpleAccent,
    },
  ];

  // CONFIGURATION
  static const double _orbitRadius = 120.0;
  static const double _sunSize = 100.0;
  static const double _planetSize = 50.0;
  final Duration _animationDuration = const Duration(milliseconds: 500);

  // This helper builds the planet/sun widgets.
  Widget _buildPlanet(int index, bool isSelected) {
    final page = _pages[index];
    final size = isSelected ? _sunSize : _planetSize;

    return GestureDetector(
      onTap: () {
        // When tapped, it becomes the new sun.
        if (!isSelected) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: page['color'],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: page['color'].withOpacity(0.5),
              blurRadius: isSelected ? 20 : 8,
              spreadRadius: isSelected ? 3 : 1,
            ),
          ],
        ),
        child: Icon(
          page['icon'],
          color: Colors.white,
          size: isSelected ? 40 : 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orbital Navigator'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // This is the main interactive navigation area.
            Container(
              width: double.infinity,
              height: 350,
              // Stack allows us to layer the orbit path and the planets.
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. The Orbit Path (drawn with a CustomPainter)
                  CustomPaint(
                    size: const Size.square(_orbitRadius * 2.2),
                    painter: OrbitPainter(),
                  ),

                  // 2. The Planets and the Sun
                  ...List.generate(_pages.length, (index) {
                    final bool isSelected = index == _currentIndex;

                    // Planets are positioned on a circle using trigonometry.
                    // The "sun" (selected item) stays in the center.
                    final angle = (index / _pages.length) * 2 * math.pi;
                    final alignment = isSelected
                        ? Alignment.center
                        : Alignment(math.cos(angle), math.sin(angle));

                    return AnimatedAlign(
                      duration: _animationDuration,
                      curve: Curves.easeInOutQuint,
                      alignment: alignment,
                      child: _buildPlanet(index, isSelected),
                    );
                  }),
                ],
              ),
            ),

            // This is the content area for the selected page.
            Column(
              children: [
                // AnimatedSwitcher provides a nice cross-fade for the title.
                AnimatedSwitcher(
                  duration: _animationDuration,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    // Important: Use a key to tell the switcher the widget is new.
                    _pages[_currentIndex]['title'],
                    key: ValueKey<int>(_currentIndex),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap a planet to navigate',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- A small helper painter class for the dotted orbit line ---
// Kept in the same file to adhere to the single-file spirit.

class OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw a dashed circle
    const double dashWidth = 10.0;
    const double dashSpace = 8.0;
    double startAngle = 0;
    final circumference = 2 * math.pi * radius;
    final totalDashes = (circumference / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < totalDashes; i++) {
      final start = startAngle + i * (dashWidth + dashSpace) / radius;
      final sweep = dashWidth / radius;
      path.addArc(Rect.fromCircle(center: center, radius: radius), start, sweep);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}