import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../Models/Task.dart';
import 'DeliveryConfirmation_Page.dart';

class VirtualDriverNavigationPage extends StatefulWidget {
  final Task task;

  const VirtualDriverNavigationPage({Key? key, required this.task}) : super(key: key);

  @override
  State<VirtualDriverNavigationPage> createState() => _VirtualDriverNavigationPageState();
}

class _VirtualDriverNavigationPageState extends State<VirtualDriverNavigationPage> {
  late final List<Offset> _route;
  int _currentIndex = 0;
  Timer? _timer;
  bool _isDriving = false;
  bool _hasShownArrivalDialog = false;

  // Mock data: KL to PJ (converted to relative coordinates 0-1)
  static const Offset _startLocation = Offset(0.2, 0.3);
  static const Offset _endLocation = Offset(0.8, 0.7);

  static const String _fromLocation = 'South Depot';
  static const String _destinationAddress = '15 Industrial Road, District 2';
  static const String _driverName = 'John D';
  static const double _avgSpeedKmh = 40.0;

  double _distanceKm = 0.0;
  int _etaMinutes = 0;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _route = _buildRoute(_startLocation, _endLocation, 32);
    _distanceKm = 40.0; // Fixed demo distance
    _etaMinutes = 60; // Fixed demo ETA
    _currentIndex = 0;
    _elapsed = 0;
    _hasShownArrivalDialog = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<Offset> _buildRoute(Offset a, Offset b, int n) {
    final List<Offset> pts = [];
    for (int i = 0; i < n; i++) {
      final t = i / (n - 1);
      final x = a.dx + (b.dx - a.dx) * t + math.sin(t * math.pi) * 0.1;
      final y = a.dy + (b.dy - a.dy) * t;
      pts.add(Offset(x, y));
    }
    return pts;
  }


  void _start() {
    if (_isDriving) return;
    setState(() {
      _isDriving = true;
      _hasShownArrivalDialog = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentIndex < _route.length - 1) {
        setState(() {
          _currentIndex++;
          _elapsed++;
        });
      } else {
        _stop();
        if (!_hasShownArrivalDialog) {
          _hasShownArrivalDialog = true;
          _showArrived();
        }
      }
    });
  }

  void _stop() {
    setState(() => _isDriving = false);
    _timer?.cancel();
  }

  void _showArrived() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text('Arrived at Destination'),
        content: Text('To: ${widget.task.toLocation}\n$_destinationAddress\nTime: $_elapsed mins\nDistance: ${_distanceKm.toStringAsFixed(1)} km'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(c).pop(); // Close dialog
            },
            child: const Text('OK'),
          )
        ],
      ),
    );

    // After dialog is closed, navigate to Delivery Confirmation page
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DeliveryConfirmationPage(task: widget.task),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Driver Navigation'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _MapPainter(
                    route: _route,
                    currentIndex: _currentIndex,
                    fromLocation: _fromLocation,
                    toLocation: widget.task.toLocation,
                    destinationAddress: _destinationAddress,
                    driverName: _driverName,
                    etaMinutes: _etaMinutes - _elapsed,
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _info(icon: Icons.access_time, title: 'ETA', value: _isDriving ? '${_etaMinutes - _elapsed} mins' : '$_etaMinutes mins', color: Colors.orange),
                    _info(icon: Icons.straighten, title: 'Distance', value: '${_distanceKm.toStringAsFixed(1)} km', color: Colors.blue),
                    _info(icon: Icons.person, title: 'Driver', value: _driverName, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isDriving ? null : _start,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(_isDriving ? 'Driving...' : 'Start'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isDriving ? _stop : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _info({required IconData icon, required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final List<Offset> route;
  final int currentIndex;
  final String fromLocation;
  final String toLocation;
  final String destinationAddress;
  final String driverName;
  final int etaMinutes;

  _MapPainter({
    required this.route,
    required this.currentIndex,
    required this.fromLocation,
    required this.toLocation,
    required this.destinationAddress,
    required this.driverName,
    required this.etaMinutes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = const Color(0xFFE8F4FD);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Grid
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Convert relative coordinates to absolute
    Offset toAbsolute(Offset relative) {
      return Offset(relative.dx * size.width, relative.dy * size.height);
    }

    // Draw route
    if (route.isNotEmpty) {
      final routePaint = Paint()
        ..color = Colors.blue.shade400
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (int i = 0; i < route.length; i++) {
        final point = toAbsolute(route[i]);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, routePaint);

      // Draw completed route in green
      if (currentIndex > 0) {
        final completedPaint = Paint()
          ..color = Colors.green
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke;

        final completedPath = Path();
        for (int i = 0; i <= currentIndex; i++) {
          final point = toAbsolute(route[i]);
          if (i == 0) {
            completedPath.moveTo(point.dx, point.dy);
          } else {
            completedPath.lineTo(point.dx, point.dy);
          }
        }
        canvas.drawPath(completedPath, completedPaint);
      }
    }

    // Draw markers
    if (route.isNotEmpty) {
      // Start marker
      final startPos = toAbsolute(route.first);
      final startPaint = Paint()..color = Colors.green;
      canvas.drawCircle(startPos, 8, startPaint);
      _drawLabel(canvas, startPos, fromLocation, Colors.green);

      // End marker
      final endPos = toAbsolute(route.last);
      final endPaint = Paint()..color = Colors.red;
      canvas.drawCircle(endPos, 8, endPaint);
      _drawLabel(canvas, endPos, '$toLocation\n$destinationAddress', Colors.red);

      // Driver marker
      if (currentIndex < route.length) {
        final driverPos = toAbsolute(route[currentIndex]);
        final driverPaint = Paint()..color = Colors.blue;
        canvas.drawCircle(driverPos, 8, driverPaint);
        _drawLabel(canvas, driverPos, 'Driver: $driverName\nETA: ${etaMinutes}mins', Colors.blue);
      }
    }
  }

  void _drawLabel(Canvas canvas, Offset position, String text, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout();

    final labelOffset = position + const Offset(12, -8);
    textPainter.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex ||
        oldDelegate.etaMinutes != etaMinutes;
  }
}


