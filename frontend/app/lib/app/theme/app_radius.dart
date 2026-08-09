import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r14 = 14.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double r28 = 28.0;
  static const double r32 = 32.0;

  // Semantic radius tokens
  static const double card = r20;
  static const double input = r14;
  static const double pill = r28;
  static const double badge = r16;

  // BorderRadius objects
  static final BorderRadius cardBorder = BorderRadius.circular(card);
  static final BorderRadius inputBorder = BorderRadius.circular(input);
  static final BorderRadius pillBorder = BorderRadius.circular(pill);
  static final BorderRadius badgeBorder = BorderRadius.circular(badge);
}
