import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'compass_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CompassApp());
}

class CompassApp extends StatelessWidget {
  const CompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بوصلة برو',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00E5FF),
        scaffoldBackgroundColor: const Color(0xFF0F2027),
        useMaterial3: true,
      ),
      home: const CompassScreen(),
    );
  }
}