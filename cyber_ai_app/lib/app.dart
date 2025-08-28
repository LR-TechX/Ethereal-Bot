import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/splash/splash_screen.dart';
import 'theme/cyber_theme.dart';

class CyberAIApp extends StatelessWidget {
  const CyberAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = buildCyberTheme();
    return ProviderScope(
      child: MaterialApp(
        title: 'CyberAI',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const SplashScreen(),
      ),
    );
  }
}