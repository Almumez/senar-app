import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user_model.dart';

import '../../core/routes/app_routes_fun.dart';
import '../../core/routes/routes.dart';
import '../../core/utils/enums.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/custom_image.dart';
import '../../gen/assets.gen.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  void navigateUser() {
    if (!UserModel.i.isAuth) {
      replacement(NamedRoutes.onboarding);
      return;
    }
    if (!UserModel.i.isActive) {
      replacement(NamedRoutes.login);
      return;
    }

    if (UserModel.i.accountType != UserType.freeAgent) {
      replacement(NamedRoutes.navbar);
      return;
    }

    if (!UserModel.i.completeRegistration) {
      replacement(NamedRoutes.login);
      return;
    }

    if (!UserModel.i.adminApproved) {
      replacement(NamedRoutes.successCompleteData);
      return;
    }

    replacement(NamedRoutes.navbar);
  }

  @override
  void initState() {
    log(UserModel.i.token);
    Timer(3.seconds, () => navigateUser());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          child: CustomImage(
            'assets/images/splash.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
