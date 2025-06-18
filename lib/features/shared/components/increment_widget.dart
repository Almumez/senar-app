import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/extensions.dart';

import '../../../core/widgets/custom_radius_icon.dart';
import '../../../core/widgets/loading.dart';

class IncrementWidget extends StatelessWidget {
  const IncrementWidget({
    super.key,
    required this.count,
    this.increment,
    this.decrement,
    this.loadingType = '',
    this.isLoading,
  });

  final int count;
  final String loadingType;
  final bool? isLoading;

  final Function()? increment, decrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: count == 0 ? null : 110.w,
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
      decoration: BoxDecoration(color: Color(0xfff5f5f5), borderRadius: BorderRadius.circular(80.r)),
      child: count == 0
          ? CustomRadiusIcon(
              backgroundColor: context.primaryColor,
              size: 24.h,
              onTap: increment,
              child: Icon(Icons.add, color: context.primaryColorLight, size: 15.h),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomRadiusIcon(
                  backgroundColor: context.primaryColor,
                  size: 24.h,
                  onTap: increment,
                  child: loadingType == 'add' && isLoading!
                      ? CustomProgress(size: 18.h, color: context.primaryColorLight)
                      : Icon(Icons.add, color: context.primaryColorLight, size: 15.h),
                ),
                Text(count.toString(), style: context.mediumText.copyWith(fontSize: 14)).withPadding(horizontal: 10.w),
                CustomRadiusIcon(
                    backgroundColor: context.primaryColor,
                    size: 24.h,
                    onTap: decrement,
                    child: loadingType == 'sub' && isLoading!
                        ? CustomProgress(size: 18.h, color: context.primaryColorLight)
                        : Icon(Icons.remove, color: context.primaryColorLight, size: 20.h))
              ],
            ),
    );
  }
}
