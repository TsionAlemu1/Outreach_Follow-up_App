import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../navigation_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.splashGradientStart,
              AppColors.splashGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              
              // Animated Logo & Text
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // White Circular Logo
                          Container(
                            width: 180,
                            height: 180,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                // Kneeling Praying Icon Placeholder (Drawn cleanly with CustomPainter or Icons)
                                CustomPaint(
                                  size: const Size(60, 60),
                                  painter: PrayerIconPainter(),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'ኪ. ሎ.',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const Text(
                                  'fellowship',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          
                          // App Title
                          Text(
                            'OUTREACH\nFOLLOWUP',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.black, // Matching dark black title in the Figma screenshot
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              letterSpacing: 1.2,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const NavigationShell()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'GET STARTED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter to draw a clean representation of the Kneeling Person from the Figma logo
class PrayerIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Draw Head
    canvas.drawCircle(Offset(size.width * 0.53, size.height * 0.28), 6, paint);

    // Draw kneeling body path
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.38)
      // Shoulder & back
      ..quadraticBezierTo(size.width * 0.42, size.height * 0.42, size.width * 0.42, size.height * 0.55)
      // Thigh down to knees
      ..lineTo(size.width * 0.42, size.height * 0.70)
      ..lineTo(size.width * 0.58, size.height * 0.78)
      // Feet back
      ..lineTo(size.width * 0.44, size.height * 0.78)
      // Inner knee angle
      ..lineTo(size.width * 0.48, size.height * 0.65)
      // Torso front
      ..lineTo(size.width * 0.56, size.height * 0.50)
      ..close();

    canvas.drawPath(path, paint);

    // Hands joined in prayer
    final handsPath = Path()
      ..moveTo(size.width * 0.52, size.height * 0.44)
      ..lineTo(size.width * 0.62, size.height * 0.40)
      ..lineTo(size.width * 0.62, size.height * 0.34)
      ..quadraticBezierTo(size.width * 0.57, size.height * 0.38, size.width * 0.52, size.height * 0.44)
      ..close();
      
    canvas.drawPath(handsPath, paint);

    // Draw stylized base lines
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(size.width * 0.32, size.height * 0.2), Offset(size.width * 0.68, size.height * 0.2), linePaint);
    canvas.drawLine(Offset(size.width * 0.32, size.height * 0.8), Offset(size.width * 0.68, size.height * 0.8), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
