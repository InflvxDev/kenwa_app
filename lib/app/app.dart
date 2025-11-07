import 'package:flutter/material.dart';
import 'package:kenwa_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'theme/app_theme.dart';

class KenwaApp extends StatelessWidget {
  const KenwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kenwa Salud y Armonía',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const OnboardingPage(),
    );
  }
}
