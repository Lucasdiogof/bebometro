import 'package:flutter/material.dart';

import 'common.dart' show reduceMotion;

/// The app mark: the "B" bottle cap. Used for the launcher icon, the splash
/// screen and loading states.
class BrandCap extends StatelessWidget {
  const BrandCap({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/branding/logo_cap.png',
    width: size,
    height: size,
    filterQuality: FilterQuality.medium,
    semanticLabel: 'Bebômetro',
  );
}

/// The written logo, for headers and for the login/sign-up screens when they
/// exist.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.height = 32});

  final double height;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/branding/logo_wordmark.png',
    height: height,
    filterQuality: FilterQuality.medium,
    semanticLabel: 'Bebômetro',
  );
}

/// Bottle cap with a soft breathing pulse (static with reduced motion).
class BrandLoader extends StatefulWidget {
  const BrandLoader({super.key, this.size = 72});

  final double size;

  @override
  State<BrandLoader> createState() => _BrandLoaderState();
}

class _BrandLoaderState extends State<BrandLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
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
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: 0.94 + 0.06 * Curves.easeInOut.transform(_controller.value),
        child: child,
      ),
      child: BrandCap(size: widget.size),
    );
  }
}
