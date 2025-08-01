import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/utils/pull_to_refresh.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/url_launcher_utils.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/user_model.dart';
import '../../orders/widget/agent_order_widget.dart';
import '../controller/home_cubit.dart';
import '../controller/home_states.dart';

class FreeAgentHomeView extends StatefulWidget {
  const FreeAgentHomeView({super.key});

  @override
  State<FreeAgentHomeView> createState() => _FreeAgentHomeViewState();
}

class _FreeAgentHomeViewState extends State<FreeAgentHomeView> with SingleTickerProviderStateMixin {
  final cubit = sl<AgentHomeCubit>();
  final ScrollController _scrollController = ScrollController();
  bool isAutomatic = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    cubit.fetchOrders();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
        cubit.fetchOrders(isPagination: true);
      }
    });
    
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    UserModel.i.fullname, 
                    style: context.mediumText.copyWith(fontSize: 20),
                  ),
                ),
                Text(
                  LocaleKeys.available.tr(),
                  style: context.mediumText.copyWith(fontSize: 14),
                ).withPadding(end: 16.w),
                BlocBuilder<AgentHomeCubit, AgentHomeState>(
                  bloc: cubit,
                  builder: (context, state) {
                    return Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        activeColor: context.primaryColorLight.withValues(alpha: state.activeState.isLoading ? .5 : 1),
                        activeTrackColor: context.primaryColorDark.withValues(alpha: state.activeState.isLoading ? .5 : 1),
                        inactiveThumbColor: context.primaryColorLight.withValues(alpha: state.activeState.isLoading ? .5 : 1),
                        inactiveTrackColor: '#f5f5f5'.color.withValues(alpha: state.activeState.isLoading ? .5 : 1),
                        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                        value: UserModel.i.isAvailable,
                        onChanged: (v) {
                          if (state.activeState.isLoading) return;
                          cubit.changeAvailability();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            Transform.translate(
              offset: Offset(0, -14.h),
              child: Row(
                children: [
                  Expanded(child: Container()),
                  Text(
                    "تلقائي",
                    style: context.mediumText.copyWith(fontSize: 14),
                  ).withPadding(end: 16.w),
                  Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      activeColor: context.primaryColorLight,
                      activeTrackColor: context.primaryColorDark,
                      inactiveThumbColor: context.primaryColorLight,
                      inactiveTrackColor: '#f5f5f5'.color,
                      trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                      value: isAutomatic,
                      onChanged: (v) {
                        setState(() {
                          isAutomatic = v;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        titleSpacing: 16.w,
      ),
      body: PullToRefresh(
        onRefresh: cubit.reload,
        child: BlocBuilder<AgentHomeCubit, AgentHomeState>(
          bloc: cubit,
          builder: (context, state) {
            if (state.getOrdersState == RequestState.loading && cubit.items.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            if (state.getOrdersState == RequestState.error && cubit.items.isEmpty) {
              return Center(child: CustomErrorWidget(title: state.msg));
            }
            
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: cubit.items.isEmpty && state.getOrdersState == RequestState.done ? 1 : 
                         cubit.items.length + (state.paginationState == RequestState.loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (cubit.items.isEmpty && state.getOrdersState == RequestState.done) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Text(
                        LocaleKeys.no_orders.tr(), 
                        style: context.mediumText.copyWith(fontSize: 14)
                      )
                    ),
                  );
                }
                
                if (index == cubit.items.length) {
                  return Center(child: CircularProgressIndicator());
                }
                final item = cubit.items[index];
                return AgentOrderWidget(item: item, onBack: () => cubit.reload()).withPadding(bottom: 20.h);
              },
            );
          },
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
  }
}
