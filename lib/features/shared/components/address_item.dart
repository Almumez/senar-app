import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/utils/extensions.dart';
import '../../../gen/locale_keys.g.dart';

class OrderDetailsAddressItem extends StatelessWidget {
  const OrderDetailsAddressItem({
    super.key,
    required this.title,
    required this.description,
    this.lable,
  });
  final String? lable;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 64.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SvgPicture.asset(
                'assets/svg/location.svg',
                height: 20.h,
                width: 20.w,
                colorFilter: ColorFilter.mode(
                  context.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title, 
                  style: context.mediumText.copyWith(fontSize: 14.sp)
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
