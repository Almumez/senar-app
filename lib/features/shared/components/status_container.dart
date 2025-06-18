import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/extensions.dart';

class StatusContainer extends StatelessWidget {
  const StatusContainer({
    super.key,
    required this.title,
    required this.color,
  });

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.r), color: color.withValues(alpha: .1)),
      child: Text(
        title,
        style: context.mediumText.copyWith(fontSize: 14.sp, color: color),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}