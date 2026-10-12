import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Spacing scale (logical pixels). Use these instead of ad-hoc numbers.
class AppSpace {
  const AppSpace._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Horizontal gutter of every screen.
  static const gutter = 16.0;
}

/// Corner radii.
class AppRadius {
  const AppRadius._();

  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
}

/// Minimum comfortable touch target.
const double kTouchTarget = 48;

/// Text styles. Hierarchy: headline > title > body > caption > overline.
class AppText {
  const AppText._();

  static const headline = TextStyle(
    fontSize: 30,
    height: 1.1,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    color: AppColors.text,
  );

  static const title = TextStyle(
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
  );

  static const subtitle = TextStyle(
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const body = TextStyle(
    fontSize: 15,
    height: 1.35,
    color: AppColors.text,
  );

  static const caption = TextStyle(
    fontSize: 13,
    height: 1.3,
    color: AppColors.textMuted,
  );

  static const overline = TextStyle(
    fontSize: 12,
    letterSpacing: 0.9,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
  );

  static const value = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
  );
}
