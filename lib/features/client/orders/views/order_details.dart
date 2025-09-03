import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/app_btn.dart';
import '../components/view/distribution_order_details.dart';
import '../components/order_tracker_map.dart';
import 'rate_agent.dart';
import '../../../shared/controller/cancel_reasons/states.dart';
import '../../../../models/cancel_reasons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/select_item_sheet.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/controller/cancel_reasons/cubit.dart';
import '../components/view/maintenance_order_details.dart';
import '../components/view/product_order_details.dart';
import '../components/view/recharge_order_details.dart';
import '../controller/order_details/cubit.dart';
import '../controller/order_details/states.dart';
import '../../../../core/widgets/flash_helper.dart';

// إضافة استيراد مكون bottom sheet الدفع
import '../../../shared/components/payment_bottom_sheet.dart';
import '../components/cancel_order_sheet.dart';

class ClientOrderDetailsView extends StatefulWidget {
  final String id, type;
  const ClientOrderDetailsView({super.key, required this.id, required this.type});

  @override
  State<ClientOrderDetailsView> createState() => _ClientOrderDetailsViewState();
}

class _ClientOrderDetailsViewState extends State<ClientOrderDetailsView> {
  final cubit = sl<ClientOrderDetailsCubit>();

  @override
  void initState() {
    super.initState();
    cubit.getDetails(id: widget.id, type: widget.type);
  }

  // Construir la sección de estado del pedido
  Widget _buildOrderStatusSection(ClientOrderModel data) {
    final Map<String, Color> statusColors = {
      'pending': "#CE6518".color,
      'accepted': "#168836".color,
      'completed': "#168836".color,
      'canceled': "#E53935".color,
      'on_way': "#168836".color,
      'checked': "#168836".color,
    };
    
    final Map<String, String> statusIcons = {
      'pending': 'assets/svg/time.svg',
      'accepted': 'assets/svg/check_circle.svg',
      'completed': 'assets/svg/check_circle.svg',
      'canceled': 'assets/svg/cancel.svg',
      'on_way': 'assets/svg/delivery.svg',
      'checked': 'assets/svg/check_circle.svg',
    };
    
    final Map<String, String> statusMessages = {
      'pending': "",
      'accepted': "",
      'completed': LocaleKeys.service_completed.tr(),
      'canceled': LocaleKeys.cancel_order.tr(),
      'on_way': LocaleKeys.tracking_delivery.tr(),
      'checked': LocaleKeys.check_now.tr(),
    };
    
    if (data.status == 'pending' || data.status == 'accepted' || data.status == 'canceled') {
      return SizedBox.shrink();
    }
    
    return Container();
  }
  
  // Construir la sección de instrucciones similar a create_order.dart
  Widget _buildInstructionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildVerticalInstructionItem(
              context: context,
              svgAsset: 'assets/svg/clean.svg',
              text: "اسطوانة نظيفة",
            ),
            _buildVerticalInstructionItem(
              context: context,
              svgAsset: 'assets/svg/door.svg',
              text: "توصل للباب",
            ),
            _buildVerticalInstructionItem(
              context: context,
              svgAsset: 'assets/svg/warning.svg',
              text: "استلامك مسوؤليتك",
            ),
          ],
        ),
      ],
    ).withPadding(bottom: 20.h);
  }
  
  // Widget para instrucciones individuales (copiado de create_order.dart)
  Widget _buildVerticalInstructionItem({
    required BuildContext context, 
    required String svgAsset, 
    required String text
  }) {
    List<String> words = text.split(' ');
    
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgAsset,
            height: 24.h,
            width: 24.h,
            colorFilter: ColorFilter.mode(
              context.primaryColor,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 8.h),
          Column(
            children: words.map((word) => 
              Text(
                word,
                textAlign: TextAlign.center,
                style: context.mediumText.copyWith(
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              )
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildBody(ClientOrderModel data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _buildInstructionsSection(context),
          // Mostrar el estado del pedido (excepto para pending y accepted)
          _buildOrderStatusSection(data),

          // Mostrar el mapa de seguimiento cuando el estado del pedido es 'on_way'
          if (data.status == 'on_way')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "تتبع التوصيل",
                      style: context.mediumText.copyWith(fontSize: 14.sp),
                    ),
                    // أيقونات الاتصال والرسائل
                    Row(
                      children: [
                        // أيقونة الاتصال
                        InkWell(
                          onTap: () => _callAgent(data.agent.phoneNumber),
                          child: Container(
                            padding: EdgeInsets.all(8.h),
                            decoration: BoxDecoration(
                              color: Color(0xfff5f5f5),
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              'assets/svg/call.svg',
                              height: 20.h,
                              width: 20.w,
                              colorFilter: ColorFilter.mode(
                                context.primaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // أيقونة الرسائل
                        InkWell(
                          onTap: () => _openWhatsApp(data.agent.phoneNumber),
                          child: Container(
                            padding: EdgeInsets.all(8.h),
                            decoration: BoxDecoration(
                              color: Color(0xfff5f5f5),
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              'assets/svg/chatbox.svg',
                              height: 20.h,
                              width: 20.w,
                              colorFilter: ColorFilter.mode(
                                context.primaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).withPadding(horizontal: 16.w, bottom: 8.h,top: 16.h),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: OrderTrackerMap(orderId: data.id),
                  ),
                ).withPadding(horizontal: 16.w, bottom: 30.h),
              ],
            ),
            
          // Mostrar los detalles del pedido según el tipo
          _buildOrderDetails(data),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(ClientOrderModel data) {
    switch (data.type) {
      case 'distribution':
        return ClientDistributionOrderDetails(data: data);
      case "maintenance":
        return ClientMaintenanceOrderDetails(data: data);
      case "recharge":
        return ClientRechargeOrderDetails(data: data);
      case "accessory" || "factory":
        return ClientProductOrderDetails(data: data);
      default:
        return ClientMaintenanceOrderDetails(data: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PullToRefresh(
      onRefresh: () => cubit.getDetails(id: widget.id, type: widget.type),
      child: BlocBuilder<ClientOrderDetailsCubit, ClientOrderDetailsState>(
        bloc: cubit,
        builder: (context, state) {
          return Scaffold(
            appBar: CustomAppbar(title: LocaleKeys.order_details.tr()),
            bottomNavigationBar: ClientOrderDetailsActions(cubit: cubit),
            floatingActionButton: null,
            floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
            body: Builder(
              builder: (context) {
                if (state.detailsState.isDone) {
                  var data = cubit.data!;
                  return buildBody(data);
                } else if (state.detailsState.isError) {
                  return CustomErrorWidget(title: state.msg, onTap: () => cubit.getDetails(id: widget.id, type: widget.type));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          );
        },
      ),
    );
  }

  void _callAgent(String phoneNumber) async {
    if(phoneNumber.isEmpty) return;
    
    // Format the phone number by removing any spaces or special characters
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check if the number starts with '+' or add the '+' if needed
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = '+$formattedNumber';
    }
    
    final Uri phoneUri = Uri(scheme: 'tel', path: formattedNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        debugPrint('Could not launch $phoneUri');
      }
    } catch (e) {
      debugPrint('Error making call: $e');
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    if(phoneNumber.isEmpty) return;
    
    // Format the phone number by removing any spaces or special characters
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check if the number starts with '+' or add the '+' if needed
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = '+$formattedNumber';
    }
    
    // Create the WhatsApp URL
    final Uri whatsappUrl = Uri.parse('https://wa.me/$formattedNumber');
    
    // Launch WhatsApp
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        // Handle case where WhatsApp is not installed
        debugPrint('WhatsApp is not installed');
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }
}

class ClientOrderDetailsActions extends StatefulWidget {
  final ClientOrderDetailsCubit cubit;
  const ClientOrderDetailsActions({super.key, required this.cubit});

  @override
  State<ClientOrderDetailsActions> createState() => _ClientOrderDetailsActionsState();
}

class _ClientOrderDetailsActionsState extends State<ClientOrderDetailsActions> {
  final cancelCubit = sl<CancelReasonsCubit>();
  @override
  void initState() {
    super.initState();
  }

  bool showPaymentButton(ClientOrderModel? data) {
    if (data == null) return false;
    
    if (data.paymentMethod == 'cash') return false;

    bool isCheckedWithoutPayment = data.status == "checked" && (data.paymentMethod).isEmpty;

    bool isOnWayWithValidTypeAndUnpaid =
        data.status == 'on_way' && ['recharge', 'accessory', 'factory', 'distribution'].contains(data.type) && (data.price) != 0 && !(data.isPaid);

    return isCheckedWithoutPayment || isOnWayWithValidTypeAndUnpaid;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.cubit.data;
    final isDistribution = data?.type == 'distribution' || data?.type == 'accessory' || data?.type == 'factory';
    if (data?.status == 'pending') {
      return BlocBuilder<ClientOrderDetailsCubit, ClientOrderDetailsState>(
        bloc: widget.cubit,
        builder: (context, state) {
          return SafeArea(
              child: AppBtn(
            loading: state.cancelState.isLoading,
            title: "الغاء",
            textColor: context.errorColor,
            backgroundColor: context.scaffoldBackgroundColor,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => CancelOrderSheet(
                  reasonController: widget.cubit.cancelReasonController,
                ),
              ).then((confirmed) {
                if (confirmed == true) {
                  widget.cubit.cancel();
                  FlashHelper.showToast("تم الغاء الطلب");
                }
              });
            },
          ).withPadding(horizontal: 16.w, bottom: 16.h));
        },
      );
    }

    if (data?.status == 'completed' && data!.isRated == false) {
      return BlocBuilder<ClientOrderDetailsCubit, ClientOrderDetailsState>(
        bloc: widget.cubit,
        builder: (context, state) {
          return SafeArea(
              child: AppBtn(
            loading: state.rateState.isLoading,
            title: LocaleKeys.rate_agent.tr(),
            onPressed: () => push(NamedRoutes.rateAgent, arg: {
              "order_id": data.id,
              "callback": (RateData data) {
                widget.cubit.rate(data);
              }
            }),
          ).withPadding(horizontal: 16.w, bottom: 16.h));
        },
      );
    }

    if (!showPaymentButton(data)) return const SizedBox.shrink();

    return BlocBuilder<ClientOrderDetailsCubit, ClientOrderDetailsState>(
      bloc: widget.cubit,
      builder: (context, state) {
        if (isDistribution && data?.paymentMethod == 'visa') {
          return SafeArea(
            child: AppBtn(
              loading: state.payState.isLoading,
              title: isDistribution ? LocaleKeys.pay.tr() : LocaleKeys.choose_payment_method.tr(),
              onPressed: () {
                if (isDistribution) {
                  widget.cubit.paymentMethod = data?.paymentMethod;
                  if (widget.cubit.paymentMethod == 'visa') {
                    // استخدام bottom sheet للدفع بدلاً من الانتقال إلى صفحة جديدة
                    showPaymentBottomSheet(
                      context: context,
                      amount: widget.cubit.data?.totalPrice.toString() ?? "0",
                      onSuccess: (String paymentId) {
                        widget.cubit.paymentId = paymentId;
                        widget.cubit.pay();
                      },
                    );
                  }
                } else {
                  push(NamedRoutes.clientOrderDetailsSelectPayment, arg: {"cubit": widget.cubit}).then((value) {
                    if ((widget.cubit.paymentMethod == 'visa' && widget.cubit.paymentId != '') || widget.cubit.paymentMethod == 'cash') {
                      widget.cubit.pay();
                    }
                  });
                }
              },
            ).withPadding(horizontal: 16.w, bottom: 16.h),
          );
        } else {
          return SafeArea(
            child: AppBtn(
              loading: state.payState.isLoading,
              title: LocaleKeys.choose_payment_method.tr(),
              onPressed: () {
                push(NamedRoutes.clientOrderDetailsSelectPayment, arg: {"cubit": widget.cubit}).then((value) {
                  if ((widget.cubit.paymentMethod == 'visa' && widget.cubit.paymentId != '') || widget.cubit.paymentMethod == 'cash') {
                    widget.cubit.pay();
                  }
                });
              },
            ).withPadding(horizontal: 16.w, bottom: 16.h),
          );
        }
      },
    );
  }
}
