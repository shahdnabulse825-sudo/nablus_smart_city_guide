import 'package:flutter/material.dart';

const double kMobileBreakpoint = 700;

bool isMobile(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kMobileBreakpoint;

int responsiveGridColumns(BuildContext context, {int wide = 4, int narrow = 2}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 500) return narrow;
  if (width < kMobileBreakpoint) return 3;
  return wide;
}
