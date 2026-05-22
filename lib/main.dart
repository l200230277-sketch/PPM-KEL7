import 'package:flutter/material.dart';

import 'models/user_session.dart';
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
  UserSession? _session;
  bool _showSplash = true;

  void _onExploreFromSplash() {
    setState(() => _showSplash = false);
  }

  void _handleLogin(UserSession session) {
    setState(() => _session = session);
  }

  void _logout() {
    setState(() {
      _session = null;
      _showSplash = false;
    });
  }

  void _updateSession(UserSession session) {
    setState(() => _session = session);
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
      home: _session != null
          ? HomeScreen(
              session: _session!,
              onLogout: _logout,
              onSessionUpdated: _updateSession,
            )
          : _showSplash
              ? SplashScreen(onExplore: _onExploreFromSplash)
              : LoginScreen(onLogin: _handleLogin),
    );
  }
}
