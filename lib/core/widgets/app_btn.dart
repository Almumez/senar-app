import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/extensions.dart';
import 'loading.dart';

class AppBtn extends StatelessWidget {
  final String? title;
  final void Function()? onPressed;
  final bool loading, enable;
  final Color? backgroundColor, textColor;
  final Widget? icon;
  final bool saveArea;
  final double? height, width, fontSize, radius;
  final TextStyle? textStyle;
  
  const AppBtn({
    super.key,
    this.title,
    this.onPressed,
    this.loading = false,
    this.backgroundColor,
    this.height,
    this.width,
    this.icon,
    this.textColor,
    this.enable = true,
    this.fontSize,
    this.saveArea = true,
    this.radius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: saveArea,
      child: ElevatedButton(
        onPressed: () {
          if (!loading && enable) onPressed?.call();
        },
        style: ButtonStyle(
          elevation: !enable || backgroundColor == Colors.transparent || loading ? WidgetStateProperty.all(0) : WidgetStateProperty.all(0),
          side: WidgetStateProperty.all(BorderSide(style: BorderStyle.solid, color: textColor ?? Colors.transparent, width: 1.0)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius ?? 50.0))),
          backgroundColor: WidgetStatePropertyAll(backgroundColor == Colors.transparent
              ? Colors.transparent
              : loading || !enable
                  ? (backgroundColor ?? context.primaryColor).withValues(alpha: 0.4)
                  : backgroundColor ?? context.primaryColor),
        ),
        child: Container(
          height: height ?? 56.h,
          width: width ?? context.w,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomProgress(size: 15.h, color: (textColor ?? context.primaryColorLight).withValues(alpha: loading ? 1 : 0)),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: (() {
                    if (title?.isNotEmpty == true) {
                      return Row(
                        children: [
                          if (icon != null) icon!.withPadding(end: 4.w),
                          Text(
                            title ?? "",
                            style: textStyle ?? context.mediumText.copyWith(
                              fontSize: fontSize ?? 14,
                              height: 0,
                              color: textColor ?? context.primaryColorLight,
                            ),
                          ),
                        ],
                      );
                    }
                  })(),
                ),
              ),
              SizedBox(width: 15.h),
            ],
          ),
        ),
      ),
    );
  }
}
