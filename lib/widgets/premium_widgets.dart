import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../config/theme.dart';

/// Premium UI widgets for enhanced user experience

/// Confetti celebration widget - shows confetti on success
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final ConfettiController controller;

  const ConfettiOverlay({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: widget.controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.darkBrown,
              AppColors.mediumBrown,
              AppColors.lightBrown,
              AppColors.paleGold,
              Colors.white,
            ],
            numberOfParticles: 30,
            gravity: 0.2,
            emissionFrequency: 0.05,
            maxBlastForce: 20,
            minBlastForce: 8,
          ),
        ),
      ],
    );
  }
}

/// Custom refresh indicator with branded animation
class BrandedRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const BrandedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.darkBrown,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      displacement: 60,
      child: child,
    );
  }
}

/// Animated counter that counts up from 0 to target value
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 1000),
    this.prefix,
    this.suffix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = IntTween(begin: _previousValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_animation.value}${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}

/// Gradient border container
class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final BorderRadius borderRadius;
  final List<Color>? gradientColors;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const GradientBorderContainer({
    super.key,
    required this.child,
    this.borderWidth = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.gradientColors,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [
      AppColors.darkBrown,
      AppColors.lightBrown,
      AppColors.paleGold,
      AppColors.darkBrown,
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius,
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius.topLeft.x - borderWidth),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Animated gradient border (animated shimmer effect)
class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final BorderRadius borderRadius;
  final Duration duration;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
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
        return Container(
          decoration: BoxDecoration(
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: 0,
              endAngle: 2 * pi,
              colors: const [
                AppColors.darkBrown,
                AppColors.lightBrown,
                AppColors.paleGold,
                AppColors.lightBrown,
                AppColors.darkBrown,
              ],
              transform: GradientRotation(_controller.value * 2 * pi),
            ),
            borderRadius: widget.borderRadius,
          ),
          child: Container(
            margin: EdgeInsets.all(widget.borderWidth),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(widget.borderRadius.topLeft.x - widget.borderWidth),
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Bounce animation wrapper
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final bool animate;
  final Duration duration;
  final double scale;

  const BounceAnimation({
    super.key,
    required this.child,
    this.animate = true,
    this.duration = const Duration(milliseconds: 600),
    this.scale = 1.1,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: widget.scale)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.scale, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    if (widget.animate) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Shimmer loading effect
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Success checkmark animation
class AnimatedCheckmark extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;

  const AnimatedCheckmark({
    super.key,
    this.size = 60,
    this.color,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1, curve: Curves.easeOut),
      ),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color ?? AppColors.success,
              boxShadow: [
                BoxShadow(
                  color: (widget.color ?? AppColors.success).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _CheckmarkPainter(
                progress: _checkAnimation.value,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Checkmark path
    final startX = size.width * 0.25;
    final startY = size.height * 0.5;
    final midX = size.width * 0.45;
    final midY = size.height * 0.7;
    final endX = size.width * 0.75;
    final endY = size.height * 0.35;

    path.moveTo(startX, startY);
    
    if (progress <= 0.5) {
      final t = progress * 2;
      path.lineTo(
        startX + (midX - startX) * t,
        startY + (midY - startY) * t,
      );
    } else {
      path.lineTo(midX, midY);
      final t = (progress - 0.5) * 2;
      path.lineTo(
        midX + (endX - midX) * t,
        midY + (endY - midY) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ============================================================================
// SUCCESS DIALOG
// ============================================================================

/// Show a beautiful success dialog with animated checkmark
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
  });

  /// Static helper to show the dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimatedCheckmark(size: 80),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed ?? () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BRANDED LOADING SPINNER
// ============================================================================

/// Custom branded loading spinner with logo-style animation
class BrandedLoadingSpinner extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const BrandedLoadingSpinner({
    super.key,
    this.size = 50,
    this.color,
    this.strokeWidth = 4,
  });

  @override
  State<BrandedLoadingSpinner> createState() => _BrandedLoadingSpinnerState();
}

class _BrandedLoadingSpinnerState extends State<BrandedLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _arcAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _arcAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.9),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 0.1),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _SpinnerPainter(
              rotation: _rotationAnimation.value,
              arcLength: _arcAnimation.value,
              color: widget.color ?? AppColors.darkBrown,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        );
      },
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final double rotation;
  final double arcLength;
  final Color color;
  final double strokeWidth;

  _SpinnerPainter({
    required this.rotation,
    required this.arcLength,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background arc
    final bgPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Animated arc
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, rotation, arcLength * 2 * pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.arcLength != arcLength;
  }
}

// ============================================================================
// ANIMATED PROGRESS RING
// ============================================================================

/// Animated circular progress indicator
class AnimatedProgressRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Widget? child;
  final Duration duration;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.progressColor,
    this.child,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _progressAnimation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = oldWidget.progress;
      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  progress: _progressAnimation.value,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: widget.backgroundColor ?? Colors.grey[200]!,
                  progressColor: widget.progressColor ?? AppColors.darkBrown,
                ),
              ),
              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -pi / 2, // Start from top
      progress * 2 * pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Helper to show a loading dialog with branded spinner
class LoadingDialog {
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandedLoadingSpinner(size: 50),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

// ============================================================================
// ENHANCED RIPPLE BUTTON
// ============================================================================

/// Button with enhanced ripple effect and scale animation
class EnhancedRippleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? rippleColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const EnhancedRippleButton({
    super.key,
    required this.child,
    this.onTap,
    this.rippleColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  });

  @override
  State<EnhancedRippleButton> createState() => _EnhancedRippleButtonState();
}

class _EnhancedRippleButtonState extends State<EnhancedRippleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTap?.call();
          },
          onTapCancel: () => _controller.reverse(),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          splashColor: widget.rippleColor ?? AppColors.lightBrown.withOpacity(0.3),
          highlightColor: widget.rippleColor?.withOpacity(0.1) ?? AppColors.lightBrown.withOpacity(0.1),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ANIMATED ICON
// ============================================================================

/// Icon that animates when changing (morph effect)
class AnimatedIconWidget extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Duration duration;

  const AnimatedIconWidget({
    super.key,
    required this.icon,
    this.size = 24,
    this.color,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            icon,
            size: size,
            color: color ?? AppColors.darkBrown,
          ),
        );
      },
    );
  }
}

/// Icon that animates between two states (e.g., checked/unchecked)
class AnimatedToggleIcon extends StatelessWidget {
  final bool isActive;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Duration duration;

  const AnimatedToggleIcon({
    super.key,
    required this.isActive,
    required this.activeIcon,
    required this.inactiveIcon,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Icon(
        isActive ? activeIcon : inactiveIcon,
        key: ValueKey(isActive),
        size: size,
        color: isActive 
            ? (activeColor ?? AppColors.darkBrown) 
            : (inactiveColor ?? AppColors.textLight),
      ),
    );
  }
}

/// Icon with bounce animation on tap
class BouncingIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final VoidCallback? onTap;

  const BouncingIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color,
    this.onTap,
  });

  @override
  State<BouncingIcon> createState() => _BouncingIconState();
}

class _BouncingIconState extends State<BouncingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reset();
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _animation,
        child: Icon(
          widget.icon,
          size: widget.size,
          color: widget.color ?? AppColors.darkBrown,
        ),
      ),
    );
  }
}
