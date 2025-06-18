import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/locale_keys.g.dart';
import '../routes/app_routes_fun.dart';
import '../utils/extensions.dart';
import 'base_shimmer.dart';
import 'custom_image.dart';

class CustomProgress extends StatelessWidget {
  final double size;
  final double? strokeWidth;
  final Color? color;
  final double? value;
  final Color? backgroundColor;
  const CustomProgress({super.key, required this.size, this.strokeWidth, this.color, this.backgroundColor, this.value});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth ?? 2,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(color ?? context.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomProgress(size: 25.h).center;
  }
}

class LoadingImage extends StatelessWidget {
  final double? size;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  const LoadingImage({super.key, this.size, this.borderRadius, this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 70.h,
      height: size ?? 70.h,
      decoration: BoxDecoration(borderRadius: borderRadius, border: border),
      child: BaseShimmer(
        child: CustomImage(
          'Assets.svg.logo',
          color: '#f5f5f5'.color,
        ).center.withPadding(horizontal: 10.w),
      ),
    );
  }
}

class PaginationLoading extends StatelessWidget {
  final bool isLoading;
  const PaginationLoading({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: context.w,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        color: context.primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomProgress(size: 12.h, color: context.primaryColorLight).withPadding(end: 8.w),
            Text(
              LocaleKeys.loading.tr(),
              style: context.mediumText.copyWith(
                fontSize: 14,
                color: context.primaryColorLight,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class LoadingDialog {
  static bool _isOpend = false;
  static void show() {
    if (_isOpend) return;
    _isOpend = true;
    showDialog(
      context: navigator.currentContext!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: PopScope(canPop: false, child: CustomProgress(size: 25.h, color: context.primaryColorLight).center),
      ),
    );
  }

  static void hide() {
    if (_isOpend) {
      Navigator.pop(navigator.currentContext!);
      _isOpend = false;
    }
  }
}
