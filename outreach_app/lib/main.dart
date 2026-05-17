import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/outreach_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const OutreachApp());
}

class OutreachApp extends StatelessWidget {
  const OutreachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OutreachProvider(),
      child: MaterialApp(
        title: 'Outreach Follow-up App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

