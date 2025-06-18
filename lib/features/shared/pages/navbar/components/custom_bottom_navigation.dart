// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gasapp/core/services/service_locator.dart';
import 'package:gasapp/core/utils/extensions.dart';
import 'package:gasapp/core/widgets/custom_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gasapp/core/widgets/nav.dart';
import 'package:gasapp/features/shared/pages/navbar/cubit/navbar_cubit.dart';
import 'package:gasapp/gen/assets.gen.dart';
import 'package:gasapp/gen/locale_keys.g.dart';

class CustomNavigationBarItems extends StatefulWidget {
  const CustomNavigationBarItems({
    super.key,
  });

  @override
  State<CustomNavigationBarItems> createState() => _CustomNavigationBarItemsState();
}

class _CustomNavigationBarItemsState extends State<CustomNavigationBarItems> {
  final cubit = sl<NavbarCubit>();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavbarCubit, int>(
      bloc: cubit,
      builder: (context, state) {
        return Container(
  margin: EdgeInsets.symmetric(horizontal: 60.w), // تقليل الهامش لتقريب الأيقونات
  child: BottomNavyBar(
    backgroundColor: Colors.white,
    selectedIndex: state,
    onItemSelected: cubit.changeTap,
    itemPadding: EdgeInsets.zero, // Removed horizontal padding here
    mainAxisAlignment: MainAxisAlignment.center,
    items: List.generate(
      4,
      (i) => BottomNavyBarItem(
        activeColor: Colors.black,
        inactiveColor: Colors.black,
        textAlign: TextAlign.center,
        title: const SizedBox.shrink(),
        icon: Container(
          padding: EdgeInsets.symmetric(horizontal: 0.w), // إزالة المسافة الأفقية تمامًا
          child: SvgPicture.asset(
            [
              i == state ? Assets.svg.homeIn : Assets.svg.homeOut,
              i == state ? Assets.svg.ordersIn : Assets.svg.ordersOut,
              i == state ? Assets.svg.notificationsIn : Assets.svg.notificationsOut,
              i == state ? Assets.svg.profileIn : Assets.svg.profileOut,
            ][i],
            width: 24.r,  // زيادة حجم الأيقونات
            height: 24.r, // زيادة حجم الأيقونات
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
      ),
    ),
  ),
);
      },
    );

    // Container(
    //   height: kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom,
    //   decoration: BoxDecoration(
    //     color: context.primaryColorLight,
    //     borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.black.withOpacity(0.1), // Shadow color
    //         spreadRadius: 0, // Spread of the shadow
    //         blurRadius: 10, // Blurring effect
    //         offset: Offset(0, 0), // X and Y offset
    //       ),
    //     ],
    //   ),
    //   child: SafeArea(
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceAround,
    //       children: [
    //         NavBarItem(
    //           path: Assets.svg.homeIn,
    //           notSelectedPath: Assets.svg.homeOut,
    //           title: LocaleKeys.home.tr(),
    //           index: 0,
    //           onTap: () {
    //             context.read<NavbarCubit>().changeTab(0);
    //             setState(() {});
    //           },
    //         ),
    //         NavBarItem(
    //           path: Assets.svg.ordersIn,
    //           notSelectedPath: Assets.svg.ordersOut,
    //           title: LocaleKeys.orders.tr(),
    //           index: 1,
    //           onTap: () {
    //             context.read<NavbarCubit>().changeTab(1);
    //             //  context.read<ThemeCubit>().changeTheme(true);
    //             setState(() {});
    //           },
    //         ),
    //         NavBarItem(
    //           path: Assets.svg.notificationsIn,
    //           notSelectedPath: Assets.svg.notificationsOut,
    //           title: LocaleKeys.notifications.tr(),
    //           index: 2,
    //           onTap: () {
    //             context.read<NavbarCubit>().changeTab(2);
    //             // context.read<ThemeCubit>().changeTheme(false);
    //             setState(() {});
    //           },
    //         ),
    //         NavBarItem(
    //           path: Assets.svg.profileIn,
    //           notSelectedPath: Assets.svg.profileOut,
    //           title: LocaleKeys.profile.tr(),
    //           index: 3,
    //           onTap: () {
    //             context.read<NavbarCubit>().changeTab(3);
    //             // context.read<ThemeCubit>().changeTheme(false);
    //             setState(() {});
    //           },
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}

// class NavBarItem extends StatelessWidget {
//   const NavBarItem({super.key, required this.path, required this.title, required this.index, required this.onTap, required this.notSelectedPath});
//   final String path;
//   final String notSelectedPath;
//   final String title;
//   final int index;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 5),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             context.read<NavbarCubit>().tabController.index == index
//                 ? Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 14.w,
//                       vertical: 13.h,
//                     ),
//                     decoration: BoxDecoration(color: context.primaryColorDark.withValues(alpha: .1), borderRadius: BorderRadius.circular(100.r)),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CustomImage(
//                           path,
//                           width: 25.w,
//                           height: 25.h,
//                         ),
//                         6.w.horizontalSpace,
//                         Text(
//                           title,
//                           style: context.boldText.copyWith(color: context.primaryColorDark, fontWeight: FontWeight.w700, fontSize: 13.sp),
//                         ),
//                       ],
//                     ),
//                   )
//                 : CustomImage(
//                     notSelectedPath,
//                     width: 25.w,
//                     height: 25.h,
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
