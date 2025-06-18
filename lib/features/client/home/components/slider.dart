import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/error_widget.dart';
import '../controller/cubit.dart';

class SliderWidget extends StatelessWidget {
  final ClientHomeCubit cubit;
  const SliderWidget({
    super.key,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (cubit.data != null) {
          return SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(top: 16.h, bottom: 20.h, start: 20.w),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                cubit.data!.sliders.length,
                (index) => GestureDetector(
                  onTap: () => push(NamedRoutes.story, arg: {"gallery_items": cubit.data!.sliders, "init_page": index}),
                  child: CustomImage(
                    cubit.data!.sliders[index].image,
                    height: 72.h,
                    width: 72.h,
                    borderRadius: BorderRadius.circular(36.h),
                    fit: BoxFit.cover,
                    border: Border.all(color: Color(0xFF000000)),
                  ).withPadding(horizontal: 4.w),
                ),
              ),
            ),
          );
        } else if (cubit.state.requestState.isError) {
          return CustomErrorWidget(title: cubit.state.msg);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
