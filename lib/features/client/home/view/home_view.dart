import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../models/user_model.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/utils/url_launcher_utils.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../addresses/controller/cubit.dart';
import '../components/appbar.dart';
import '../components/request_gas.dart';
import '../components/slider.dart';
import '../controller/cubit.dart';
import '../controller/states.dart';

class HomeClientView extends StatefulWidget {
  const HomeClientView({super.key});

  @override
  State<HomeClientView> createState() => _HomeClientViewState();
}

class _HomeClientViewState extends State<HomeClientView> with SingleTickerProviderStateMixin {
  final cubit = sl<ClientHomeCubit>()..getHome();
  final addressesCubit = sl<AddressesCubit>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    if (UserModel.i.isAuth) {
      if (addressesCubit.addresses.isEmpty) {
        addressesCubit.getAddresses();
      }
    }
    
    // تهيئة الأنيميشن
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await cubit.getHome();
    if (UserModel.i.isAuth && addressesCubit.addresses.isEmpty) {
      await addressesCubit.getAddresses();
    }
  }

  // إظهار نافذة منبثقة "قريباً"
  void _showComingSoonPopup(BuildContext context, String title) {
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
                    child: SvgPicture.asset("assets/svg/notifications_in.svg",
                      height:   20.h,
                        width:  20.w,
                      fit:  BoxFit.cover,

                    ),
                  ),

                ),
                SizedBox(height: 20.h),
                Text(
                  "${LocaleKeys.coming_soon.tr()}",
                  style: context.boldText.copyWith(
                    fontSize: 20.sp,
                    color: "#090909".color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.h),
                // Text(
                //   LocaleKeys.service_not_available.tr(),
                //   style: context.mediumText.copyWith(
                //     fontSize: 16.sp,
                //     color: "#9E968F".color,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
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

  List<HomeItemModel> items = [
    HomeItemModel(
      title: LocaleKeys.factory.tr(),
      image: Assets.images.homeFactory.path,
      onTap: () => push(NamedRoutes.clientFactoryAccessory, arg: {"type": FactoryServiceType.factory}),
      isEnabled: false, // غير متاح
    ),
    HomeItemModel(
      title: LocaleKeys.suppliers.tr(),
      image: Assets.images.homeProvide.path,
      onTap: () => push(NamedRoutes.clientMaintenanceCompanies, arg: {"type": CompanyServiceType.supply}),
      isEnabled: false, // غير متاح
    ),
    HomeItemModel(
      title: LocaleKeys.maintenance.tr(),
      image: Assets.images.homeMaintenance.path,
      onTap: () => push(NamedRoutes.clientMaintenanceCompanies, arg: {"type": CompanyServiceType.maintenance}),
      isEnabled: false, // غير متاح
    ),
    HomeItemModel(
      title: LocaleKeys.accessories.tr(),
      image: Assets.images.homeAccessories.path,
      onTap: () => push(NamedRoutes.clientFactoryAccessory, arg: {"type": FactoryServiceType.accessory}),
      isEnabled: false, // غير متاح
    ),
    HomeItemModel(
      title: LocaleKeys.fill.tr(),
      image: Assets.images.homeFill.path,
      onTap: () => push(NamedRoutes.centralGasFilling),
      isEnabled: false, // غير متاح
    ),
    HomeItemModel(
      title: LocaleKeys.reset.tr(),
      image: Assets.images.homeRecycle.path,
      onTap: () => push(NamedRoutes.clientRefill),
      isEnabled: false, // غير متاح
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientHomeCubit, ClientHomeState>(
      bloc: cubit,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.scaffoldBackgroundColor,
          appBar: HomeAppbar(),
          body: PullToRefresh(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SliderWidget(cubit: cubit),
                  // Text(LocaleKeys.services.tr(), style: context.boldText.copyWith(fontSize: 20)).withPadding(horizontal: 20.w, bottom: 16.h),
                  RequestGasWidget().withPadding(bottom: 16.h).center,
                  Wrap(
                    children: List.generate(
                      items.length,
                      (index) => InkWell(
                        onTap: () => _showComingSoonPopup(context, items[index].title),
                        child: Opacity(
                          opacity: items[index].isEnabled ? 1.0 : 0.3, // opacity خفيف للكاردات غير المتاحة
                          child: Column(
                            children: [
                              Container(
                                height: 115.h,
                                width: 112.w,
                                padding:  EdgeInsets.all(15.r),
                                decoration: BoxDecoration(
                                  color: Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(width: 0, color: Colors.transparent),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage: AssetImage(
                                    items[index].image,
                                  ),
                                )
                              ),
                              Text(
                                items[index].title, 
                                style: context.mediumText.copyWith(
                                  fontSize: 20,
                                  color: items[index].isEnabled 
                                    ? null 
                                    : Colors.grey[600], // لون رمادي للنصوص غير المتاحة
                                ),
                              ),
                            ],
                          ),
                        ).withPadding(bottom: 16.h, horizontal: 4.w),
                      ),
                    ),
                  ).center
                ],
              ),
            ),
          ),
          floatingActionButton: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.primaryColor.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FloatingActionButton(
                    onPressed: () => UrlLauncherUtils.launchWhatsApp(),
                    backgroundColor: Colors.white,
                    elevation: 4,
                    mini: false,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: context.primaryColorLight.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      child: SvgPicture.asset(
                        "assets/svg/ai-dialogue.svg",
                        height: 30.h,
                        width: 30.w,
                        colorFilter: ColorFilter.mode(
                          context.primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        );
      },
    );
  }
}

class HomeItemModel {
  final String title, image;
  final Function()? onTap;
  final bool isEnabled;

  HomeItemModel({
    required this.title, 
    required this.image, 
    required this.onTap,
    this.isEnabled = true, // افتراضياً متاح
  });
}
