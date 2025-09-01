import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  void _login() => setState(() => isLoggedIn = true);
  void _logout() => setState(() => isLoggedIn = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: isLoggedIn
          ? MainPage(onLogout: _logout)
          : LoginPage(onLogin: _login),
    );
  }
}
