import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dima_project/auth_gate/auth_gate.dart';
import 'package:dima_project/global_providers/theme_provider.dart';
import 'package:provider/provider.dart';

class IntroAnimation extends StatefulWidget {
  const IntroAnimation({super.key});

  @override
  State<IntroAnimation> createState() => _IntroAnimationState();
}

class _IntroAnimationState extends State<IntroAnimation>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();

    // Controller per l'animazione Lottie (durata basata sul file: 153 frame a 60fps)
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2383), // 143/60*1000
    );

    // Avvia l'animazione Lottie
    _lottieController.forward();

    // Quando l'animazione Lottie è completata, passa immediatamente alla prossima schermata
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const AuthGate(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child:
            isDarkMode
                ? Lottie.asset(
                  'assets/animations/splash_animation_dark.json',
                  controller: _lottieController,
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                )
                : Lottie.asset(
                  'assets/animations/splash_animation.json',
                  controller: _lottieController,
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
      ),
    );
  }
}
