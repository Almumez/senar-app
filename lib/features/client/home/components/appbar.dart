import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/user_model.dart';
import '../../addresses/controller/cubit.dart';
import '../../addresses/controller/state.dart';

class HomeAppbar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppbar({
    super.key,
  });

  @override
  State<HomeAppbar> createState() => _HomeAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(90.h);
}

class _HomeAppbarState extends State<HomeAppbar> {
  final cubit = sl<AddressesCubit>();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: kToolbarHeight + 90.h,
      titleSpacing: 10,
      title: BlocBuilder<AddressesCubit, AddressesState>(
        bloc: cubit,
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          UserModel.i.isAuth
                              ? UserModel.i.fullname.split(' ').firstOrNull ?? ''
                              : LocaleKeys.guest.tr(),
                          style: context.mediumText.copyWith(fontSize: 20),
                        ).withPadding(horizontal: 20.w, bottom: 10.h,top: 10.h,),
                        if (UserModel.i.isAuth)
                          InkWell(
                            onTap: () => push(NamedRoutes.addresses)
                                .then((_) => cubit.getAddresses(withLoading: false)),
                            child: Row(
                              spacing: 3.w,
                              children: [
                                CustomImage(
                                  Assets.svg.location,
                                  height: 14.sp,
                                  width: 14.sp,
                                ).withPadding(end: 4.w),
                                Flexible(
                                  child: Text(
                                    cubit.defaultAddress?.placeTitle.isNotEmpty ==
                                            true
                                        ? cubit.defaultAddress!.placeTitle
                                        : LocaleKeys.add_address.tr(),
                                    style: context.mediumText.copyWith(fontSize: 14),
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down_outlined)
                              ],
                            ),
                          ).withPadding(horizontal: 20.w)                      ],
                    ),
                  ),
                  CustomImage(
                    "assets/images/splash.png",
                    height: 70.w,
                    width: 70.w,
                  ).withPadding(horizontal: 20.w,top: 18.h,),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
