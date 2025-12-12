import 'package:flutter/material.dart';

/// Premium animation utilities for butter-smooth UI
class AnimationUtils {
  /// Default animation duration
  static const Duration defaultDuration = Duration(milliseconds: 400);
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration slowDuration = Duration(milliseconds: 600);
  
  /// Spring curve for natural, bouncy feel
  static const Curve springCurve = Curves.easeOutBack;
  
  /// Smooth deceleration curve
  static const Curve smoothCurve = Curves.easeOutCubic;
  
  /// Elegant ease curve
  static const Curve elegantCurve = Curves.easeInOutCubic;
}

/// Staggered animation for list items
/// Use this to make items appear one after another
class StaggeredListAnimation extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration? duration;
  final Duration? delay;
  final Offset? slideOffset;

  const StaggeredListAnimation({
    super.key,
    required this.index,
    required this.child,
    this.duration,
    this.delay,
    this.slideOffset,
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    final staggerDelay = widget.delay ?? Duration(milliseconds: 50 * widget.index);
    
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset ?? const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start animation after stagger delay
    Future.delayed(staggerDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Animated card with press effect
class AnimatedPressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressScale;
  final Duration duration;
  final BorderRadius? borderRadius;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AnimatedPressCard({
    super.key,
    required this.child,
    this.onTap,
    this.pressScale = 0.98,
    this.duration = const Duration(milliseconds: 150),
    this.borderRadius,
    this.color,
    this.boxShadow,
    this.margin,
    this.padding,
  });

  @override
  State<AnimatedPressCard> createState() => _AnimatedPressCardState();
}

class _AnimatedPressCardState extends State<AnimatedPressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: widget.margin,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.color ?? Colors.white,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                boxShadow: widget.boxShadow?.map((shadow) {
                  return BoxShadow(
                    color: shadow.color,
                    blurRadius: shadow.blurRadius * _elevationAnimation.value,
                    spreadRadius: shadow.spreadRadius * _elevationAnimation.value,
                    offset: shadow.offset * _elevationAnimation.value,
                  );
                }).toList() ?? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08 * _elevationAnimation.value),
                    blurRadius: 15 * _elevationAnimation.value,
                    offset: Offset(0, 5 * _elevationAnimation.value),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Fade-in animation widget
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// Scale-in animation widget with spring effect
class ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double startScale;

  const ScaleInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.startScale = 0.8,
  });

  @override
  State<ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<ScaleInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _scaleAnimation = Tween<double>(
      begin: widget.startScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}
