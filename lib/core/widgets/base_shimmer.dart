import '../utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BaseShimmer extends StatelessWidget {
  final Widget child;
  const BaseShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      highlightColor: context.hintColor.withValues(alpha: .05),
      baseColor: context.hintColor.withValues(alpha: .2),
      child: child,
    );
  }
}
