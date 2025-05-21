import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dima_project/auth_gate/auth_gate.dart';

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
      duration: const Duration(milliseconds: 1530), // 153/60*1000
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
    return Scaffold(
      backgroundColor: const Color(0xFF221743),
      body: Center(
        child: Lottie.asset(
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
