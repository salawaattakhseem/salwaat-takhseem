import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Text animation controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Pulse animation for the logo glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Logo animations
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Text animations
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _startAnimationSequence() async {
    // Start logo animation
    _logoController.forward();
    
    // Wait a bit, then start text animation
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    
    // Start subtle pulse after everything is visible
    await Future.delayed(const Duration(milliseconds: 800));
    _pulseController.repeat(reverse: true);
    
    // Navigate after animations complete
    await Future.delayed(const Duration(milliseconds: 1000));
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(
        context,
        authProvider.getDashboardRoute(),
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.creamBackground,
              AppColors.softBeige,
              AppColors.paleGold.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: Listenable.merge([_logoController, _pulseController]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Hero(
                          tag: 'app-logo',
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkBrown.withOpacity(0.25),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 15),
                                ),
                                BoxShadow(
                                  color: AppColors.lightBrown.withOpacity(0.2),
                                  blurRadius: 60,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Animated Text
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AppColors.darkBrown,
                                AppColors.mediumBrown,
                                AppColors.darkBrown,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'Salwaat Takhseem',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkBrown.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Book Your Slot',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Loading indicator
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textFade,
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.darkBrown.withOpacity(0.6),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}