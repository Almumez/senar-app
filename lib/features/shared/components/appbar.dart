import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/extensions.dart';

import '../../../core/widgets/custom_radius_icon.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool withBack;
  final List<Widget>? actions;
  const CustomAppbar({
    super.key,
    required this.title,
    this.withBack = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: context.mediumText.copyWith(fontSize: 20),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      actions: actions,
      leading: withBack
          ? CustomRadiusIcon(
              onTap: () => Navigator.pop(context),
              backgroundColor: '#f5f5f5'.color,
              child: Icon(Icons.arrow_back),
            ).withPadding(start: 16.w)
          : null,
      leadingWidth: 75.w,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
