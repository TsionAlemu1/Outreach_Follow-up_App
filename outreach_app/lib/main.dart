import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/outreach_provider.dart';
import 'screens/home_screen.dart';

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
        title: 'Outreach Follow-up',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
