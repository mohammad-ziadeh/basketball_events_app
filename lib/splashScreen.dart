import 'package:flutter/material.dart';
import 'package:fiba_3x3/services/auth_service.dart';
// ignore: unused_import
import 'package:fiba_3x3/main.dart';
import 'package:fiba_3x3/pages/landin_page/home.dart';
import 'package:fiba_3x3/pages/Auth/auth_main.dart';
import 'package:flutter_svg/svg.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const SplashScreen({super.key, required this.onToggleTheme});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final userData = await _authService.getUser();
    await Future.delayed(const Duration(seconds: 2));
    if (userData != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => Home(onToggleTheme: widget.onToggleTheme),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AuthMain(onToggleTheme: widget.onToggleTheme),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/3x3Logo.svg', height: 100),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
