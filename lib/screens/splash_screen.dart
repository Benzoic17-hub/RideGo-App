import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart'; // Your main app

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showLogo = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8)),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: const Offset(0.85, -0.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0),
    ));

    // Start animation
    Timer(const Duration(milliseconds: 300), () {
      setState(() => _showLogo = true);
      _controller.forward();
    });

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => WelcomeScreen(), // Your home screen
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE91E63), // Yango Red
              Color(0xFFFF5722), // Yango Orange
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                transform: Matrix4.translationValues(
                  _showLogo ? 0 : -100,
                  0,
                  0,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Main Logo
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE91E63), Color(0xFFFF5722)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.local_taxi,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // RideGo Text
                          const Text(
                            'RideGo',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE91E63),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fastest way home',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Loading dots at bottom
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(0),
                    _buildDot(1),
                    _buildDot(2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _controller.value > 0.5 ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _controller.value > index * 0.33
            ? const Color(0xFFE91E63)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
