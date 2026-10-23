import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with SingleTickerProviderStateMixin {
  
  double _heading = 0;
  Position? _position;
  bool _isNightMode = true;
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _initCompass();
    _getLocation();
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  void _initCompass() {
    FlutterCompass.events!.listen((event) {
      setState(() {
        _heading = event.heading!;
      });
    });
  }

  Future<void> _getLocation() async {
    await Permission.location.request();
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _position = position;
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  String _getDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'شمال';
    if (heading >= 22.5 && heading < 67.5) return 'شمال شرق';
    if (heading >= 67.5 && heading < 112.5) return 'شرق';
    if (heading >= 112.5 && heading < 157.5) return 'جنوب شرق';
    if (heading >= 157.5 && heading < 202.5) return 'جنوب';
    if (heading >= 202.5 && heading < 247.5) return 'جنوب غرب';
    if (heading >= 247.5 && heading < 292.5) return 'غرب';
    return 'شمال غرب';
  }

  String _getDirectionShort(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'N';
    if (heading >= 22.5 && heading < 67.5) return 'NE';
    if (heading >= 67.5 && heading < 112.5) return 'E';
    if (heading >= 112.5 && heading < 157.5) return 'SE';
    if (heading >= 157.5 && heading < 202.5) return 'S';
    if (heading >= 202.5 && heading < 247.5) return 'SW';
    if (heading >= 247.5 && heading < 292.5) return 'W';
    return 'NW';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isNightMode
                ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
                : [const Color(0xFF87CEEB), const Color(0xFFE0F6FF), const Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildDegreeText(),
                const SizedBox(height: 10),
                _buildDirectionText(),
                const SizedBox(height: 40),
                _buildCompass(),
                const SizedBox(height: 40),
                _buildInfoCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'بوصلة برو',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'الإصدار 1.0.0',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              _isNightMode ? Icons.dark_mode : Icons.light_mode,
              color: const Color(0xFF00E5FF),
              size: 28,
            ),
            onPressed: () {
              setState(() {
                _isNightMode = !_isNightMode;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDegreeText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Text(
        '${_heading.toStringAsFixed(0)}°',
        style: const TextStyle(
          fontSize: 90,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00E5FF),
          shadows: [
            Shadow(
              color: Color(0xFF00E5FF),
              blurRadius: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionText() {
    return Column(
      children: [
        Text(
          _getDirection(_heading),
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD700)),
          ),
          child: Text(
            _getDirectionShort(_heading),
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompass() {
    return SizedBox(
      height: 320,
      width: 320,
      child: AnimatedBuilder(
        animation: _pulseController!,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 320 + (_pulseController!.value * 10),
                height: 320 + (_pulseController!.value * 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.3 - (_pulseController!.value * 0.1)),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00E5FF),
                    width: 5,
                  ),
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1E3A5F).withOpacity(0.8),
                      const Color(0xFF0A0E1A),
                    ],
                  ),
                ),
              ),
              ...List.generate(36, (index) {
                final angle = index * 10.0;
                final isMain = index % 9 == 0;
                final isSemi = index % 3 == 0;
                return Transform.rotate(
                  angle: angle * math.pi / 180,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.only(top: isMain ? 15 : 20),
                      width: isMain ? 4 : 2,
                      height: isMain ? 25 : isSemi ? 18 : 12,
                      color: isMain
                          ? const Color(0xFF00E5FF)
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                );
              }),
              ..._buildDirectionLabels(),
              Transform.rotate(
                angle: (-_heading * math.pi / 180),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(240, 240),
                      painter: NeedlePainter(
                        color: const Color(0xFFFF4757),
                        isNorth: true,
                      ),
                    ),
                    CustomPaint(
                      size: const Size(240, 240),
                      painter: NeedlePainter(
                        color: Colors.white,
                        isNorth: false,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD700),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4757),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildDirectionLabels() {
    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final angles = [0, 45, 90, 135, 180, 225, 270, 315];
    
    return List.generate(8, (index) {
      final angle = angles[index] * math.pi / 180;
      final radius = 110.0;
      final x = radius * math.sin(angle);
      final y = -radius * math.cos(angle);
      
      Color color = Colors.white.withOpacity(0.8);
      if (index == 0) color = const Color(0xFFFF4757);
      if (index == 4) color = Colors.white;
      
      return Transform.translate(
        offset: Offset(x, y),
        child: Text(
          directions[index],
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('خط العرض', _position?.latitude.toStringAsFixed(4) ?? '--'),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildInfoItem('خط الطول', _position?.longitude.toStringAsFixed(4) ?? '--'),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildInfoItem('الارتفاع', '${_position?.altitude.toStringAsFixed(0) ?? '--'}م'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class NeedlePainter extends CustomPainter {
  final Color color;
  final bool isNorth;

  NeedlePainter({required this.color, required this.isNorth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    if (isNorth) {
      path.moveTo(centerX, 30);
      path.lineTo(centerX - 18, centerY);
      path.lineTo(centerX + 18, centerY);
    } else {
      path.moveTo(centerX, size.height - 30);
      path.lineTo(centerX - 18, centerY);
      path.lineTo(centerX + 18, centerY);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}