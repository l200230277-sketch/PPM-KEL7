import 'package:flutter/material.dart';

import 'data/dummy_dramas.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyDramaApp());
}

class MyDramaApp extends StatefulWidget {
  const MyDramaApp({super.key});

  @override
  State<MyDramaApp> createState() => _MyDramaAppState();
}

class _MyDramaAppState extends State<MyDramaApp> {
  bool isAdmin = false;
  bool isLoggedIn = false;

  /// Setelah logout, langsung ke login (bukan splash lagi).
  bool _showSplash = true;

  void _onExploreFromSplash() {
    setState(() => _showSplash = false);
  }

  void _handleLogin(bool adminMode) {
    setState(() {
      isAdmin = adminMode;
      isLoggedIn = true;
    });
  }

  void _logout() {
    setState(() {
      isLoggedIn = false;
      isAdmin = false;
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyDrama',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F2D2E),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF005B6E)),
      ),
      home: isLoggedIn
          ? HomeScreen(
              isAdmin: isAdmin,
              initialData: initialDramas(),
              onLogout: _logout,
            )
          : _showSplash
              ? SplashScreen(onExplore: _onExploreFromSplash)
              : LoginScreen(onLogin: _handleLogin),
    );
  }
}
