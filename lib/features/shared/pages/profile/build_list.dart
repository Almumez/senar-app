import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../models/user_model.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/logout_sheet.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/profile_item.dart';

logout() {
  if (!UserModel.i.isAuth) return push(NamedRoutes.login);

  showModalBottomSheet(
    context: navigator.currentContext!,
    builder: (context) => LogoutSheet(),
  );
}

// Function to show the coming soon popup
void showComingSoonPopup(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [
              BoxShadow(
                color: "#BDBDD3".color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70.w,
                height: 70.h,
                decoration: BoxDecoration(
                  color: Color(0xfff5f5f5),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: EdgeInsets.all(15.r),
                  child: SvgPicture.asset(
                    "assets/svg/notifications_in.svg",
                    height: 20.h,
                    width: 20.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "${LocaleKeys.coming_soon.tr()}",
                style: context.mediumText.copyWith(
                  fontSize: 20,
                  color: "#090909".color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: "#090909".color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text(
                  LocaleKeys.ok.tr(),
                  style: context.mediumText.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Function to switch between client and agent account types
void switchAccountType() {
  // This would be implemented with the proper API call to switch account types
  // For now, just show a dialog or navigate to a screen to handle this
  showDialog(
    context: navigator.currentContext!,
    builder: (context) => AlertDialog(
      title: Text(LocaleKeys.profile.tr()),
      content: Text('Switch account type functionality will be implemented here.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

class BuildProfileList {
  static List<ProfileItemModel> clientItems = [
    ProfileItemModel(
      image: Assets.svg.setting, 
      title: LocaleKeys.settings, 
      onTap: () => push(NamedRoutes.settings)
    ),
    
    ProfileItemModel(
      image: 'assets/svg/information.svg', 
      title: LocaleKeys.information, 
      onTap: () => push(NamedRoutes.information),
    ),
    
    if (UserModel.i.isAuth)
    ProfileItemModel(
      image: 'assets/svg/receipt-disscount.svg', 
      title: LocaleKeys.offers, 
      onTap: () => showComingSoonPopup(navigator.currentContext!, LocaleKeys.offers.tr()),
    ),
    
    if (UserModel.i.isAuth)
    ProfileItemModel(
      image: Assets.svg.walletIcon, 
      title: LocaleKeys.financial, 
      onTap: () => push(NamedRoutes.wallet)
    ),
    
    if (!UserModel.i.isAuth) 
      ProfileItemModel(
        image: 'assets/svg/user-add.svg', 
        title: LocaleKeys.join, 
        onTap: () => push(NamedRoutes.register, arg: {"type": UserType.freeAgent}),
      ),
    
    if (UserModel.i.isAuth) 
      ProfileItemModel(
        image: 'assets/svg/profile-2user.svg', 
        title: LocaleKeys.switch_account, 
        onTap: () => showComingSoonPopup(navigator.currentContext!, LocaleKeys.switch_account.tr()),
      ),
    
    ProfileItemModel(
      image: Assets.svg.logout, 
      title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, 
      onTap: () => logout(),
    ),
  ];

 
  static List<ProfileItemModel> freeAgentItems = [
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(
      image: 'assets/svg/information.svg', 
      title: LocaleKeys.information, 
      onTap: () => push(NamedRoutes.information),
    ),
    ProfileItemModel(
      image: Assets.svg.profitsIcon, 
      title: LocaleKeys.financial, 
      onTap: () => push(NamedRoutes.profits)
    ),
    ProfileItemModel(
      image: 'assets/svg/receipt-disscount.svg', 
      title: LocaleKeys.offers, 
      onTap: () => showComingSoonPopup(navigator.currentContext!, LocaleKeys.offers.tr()),
    ),
    ProfileItemModel(
      image: 'assets/svg/user-add.svg', 
      title: LocaleKeys.join, 
      onTap: () => push(NamedRoutes.register, arg: {"type": UserType.freeAgent}),
    ),
    ProfileItemModel(
      image: 'assets/svg/profile-2user.svg', 
      title: LocaleKeys.switch_account, 
      onTap: () => showComingSoonPopup(navigator.currentContext!, LocaleKeys.switch_account.tr()),
    ),
    ProfileItemModel(image: Assets.svg.logout, title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, onTap: () => logout(),),
  ];





 static List<ProfileItemModel> agentItems = [
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(image: Assets.svg.ordersCountIcon, title: LocaleKeys.orders_count, onTap: () => push(NamedRoutes.ordersCount)),
    ProfileItemModel(image: Assets.svg.logout, title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, onTap: () => logout(),),
  ];
  
  static List<ProfileItemModel> productAgentItems = [
    ProfileItemModel(image: Assets.svg.walletIcon, title: LocaleKeys.wallet, onTap: () => push(NamedRoutes.wallet)),
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(image: Assets.svg.ordersCountIcon, title: LocaleKeys.orders_count, onTap: () => push(NamedRoutes.ordersCount)),
    ProfileItemModel(image: Assets.svg.profitsIcon, title: LocaleKeys.profits, onTap: () => push(NamedRoutes.profits)),
    ProfileItemModel(image: Assets.svg.logout, title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, onTap: () => logout(),),
  ];
  static List<ProfileItemModel> technicianItems = [
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(image: Assets.svg.walletIcon, title: LocaleKeys.wallet, onTap: () => push(NamedRoutes.wallet)),
    ProfileItemModel(image: Assets.svg.logout, title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, onTap: () => logout(),),
  ];
}
