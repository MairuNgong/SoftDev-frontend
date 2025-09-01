import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final VoidCallback onLogin;
  const LoginPage({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: FilledButton(
          onPressed: onLogin,          // ตรวจจริงค่อยแทนที่จุดนี้
          child: const Text('Sign in'),
        ),
      ),
    );
  }
}
