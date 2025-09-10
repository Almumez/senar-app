import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/buy_cylinder.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/components/increment_widget.dart';
import '../../addresses/controller/cubit.dart';
import '../controller/cubit.dart';
import '../controller/states.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/widgets/service_closed_dialog.dart';

class BuyCylinderView extends StatefulWidget {
  const BuyCylinderView({super.key});

  @override
  State<BuyCylinderView> createState() => _BuyCylinderViewState();
}

class _BuyCylinderViewState extends State<BuyCylinderView> {
  late final ClientDistributeGasCubit cubit;
  // Track the selected service index
  int _selectedServiceIndex = 0;
  // Track the selected additional option index
  int _selectedAdditionalIndex = -1;

  @override
  void initState() {
    sl.resetLazySingleton<ClientDistributeGasCubit>();
    cubit = sl<ClientDistributeGasCubit>();
    cubit.init(); // Initialize with default address and services
    super.initState();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    await cubit.fetchServices();
  }
  
  // Show dialog when no addresses are available
  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("إضافة عنوان", style: context.mediumText),
          content: Text(
            "يجب إضافة عنوان لإكمال الطلب. هل تريد إضافة عنوان جديد؟", 
            style: context.regularText
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("لاحقاً", style: context.mediumText.copyWith(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                push(NamedRoutes.pickLocation);
              },
              child: Text("إضافة عنوان", style: context.mediumText.copyWith(color: context.primaryColor)),
            ),
          ],
        );
      },
    );
  }
  
  // Check if addresses are available before calculating order
  Future<bool> _checkAddresses() async {
    final addressesCubit = sl<AddressesCubit>();
    
    // If addresses haven't been loaded yet, load them
    if (addressesCubit.addresses.isEmpty) {
      await addressesCubit.getAddresses();
    }
    
    // Return true if we have addresses, false otherwise
    return addressesCubit.addresses.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(title: LocaleKeys.buy_or_refill_gas.tr()),
        bottomNavigationBar: BlocConsumer<ClientDistributeGasCubit, ClientDistributeGasState>(
          bloc: cubit,
          listenWhen: (previous, current) => previous.calculationsState != current.calculationsState,
          listener: (context, state) {
            if (state.calculationsState.isDone && state.isRequestingOrder) {
              push(NamedRoutes.clientDistributingCreateOrder);
              // Restablecer la bandera después de navegar
              cubit.setRequestingOrder(false);
            } else if (state.calculationsState.isError) {
              // تحقق مما إذا كان نوع الخطأ هو "الخدمة غير متاحة"
              if (state.errorType.isServiceUnavailable) {
                // استدعاء نافذة الخدمة المغلقة
                final settingsService = sl<SettingsService>();
                if (settingsService.settings != null) {
                  ServiceClosedDialog.show(
                    context,
                    settingsService.settings!.closingService.openingTime
                  );
                }
              } else {
                // عرض رسالة الخطأ العادية
                FlashHelper.showToast(state.msg);
              }
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: AppBtn(
                loading: state.calculationsState.isLoading,
                enable: state.serviceChosen!,
                title: "طلب",
                onPressed: () async {
                  // Check if addresses are available before calculating order
                  bool hasAddresses = await _checkAddresses();
                  
                  if (hasAddresses) {
                    // Establecer la bandera para indicar que estamos solicitando una orden
                    cubit.setRequestingOrder(true);
                    cubit.calculateOrder();
                  } else {
                    _showAddAddressDialog();
                  }
                },
              ).withPadding(horizontal: 16.w, bottom: 16.h),
            );
          },
        ),
        body: PullToRefresh(
          onRefresh: _refresh,
          child: BlocBuilder<ClientDistributeGasCubit, ClientDistributeGasState>(
              bloc: cubit,
              builder: (context, state) {
                if (state.requestState.isError) {
                  return CustomErrorWidget(title: state.msg);
                } else if (state.requestState.isDone) {
                  return ListView(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    children: [
                      // Title "اختر" above service selector
                      Text(
                        "اختر",
                        style: context.boldText.copyWith(fontSize: 16)
                      ).withPadding(bottom: 16.h, horizontal: 16.w),
                      
                      // Service selector row (images side by side)
                      _buildServiceSelectorRow(cubit.services.where((service) => service.key != 'additional').toList(), context),
                      
                      // Selected service details
                      if (_selectedServiceIndex < cubit.services.length && 
                          cubit.services[_selectedServiceIndex].key != 'additional')
                        _buildSelectedServiceDetails(cubit.services[_selectedServiceIndex], context),
                      
                      // Additional options (always visible)
                      if (cubit.services.any((service) => service.key == 'additional'))
                        Column(
                          children: [
                            SizedBox(height: 5.h),
                            // Title "خيارات إضافية" above options selector
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                LocaleKeys.additional_options.tr(),
                                style: context.boldText.copyWith(fontSize: 16),
                              ),
                            ).withPadding(bottom: 16.h, horizontal: 16.w),
                            
                            // Get the additional service
                            Builder(
                              builder: (context) {
                                final additionalService = cubit.services.firstWhere(
                                  (service) => service.key == 'additional',
                                );
                                
                                return Column(
                                  children: [
                                    // Additional options selector row (images side by side)
                                    _buildAdditionalOptionsRow(additionalService, context),
                                    
                                    // Selected additional option details
                                    if (additionalService.sub.isNotEmpty && 
                                        _selectedAdditionalIndex >= 0 &&
                                        _selectedAdditionalIndex < additionalService.sub.length)
                                      _buildSelectedAdditionalDetails(additionalService, _selectedAdditionalIndex, context),
                                  ],
                                );
                              }
                            ),
                          ],
                        ),
                      
                      // Order summary
                      SelectedItemsSummary(cubit: cubit),
                    ],
                  );
                } else {
                  return Center(child: CustomProgress(size: 30.w));
                }
              }),
        ));
  }

  Widget _buildServiceSelectorRow(List<BuyCylinderServiceModel> services, BuildContext context) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          services.length,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedServiceIndex = index;
              });
            },
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.white, // White background for all cards
              ),
              padding: EdgeInsets.all(3.r), // Space for inner border
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: _selectedServiceIndex == index
                      ? context.primaryColor
                      : const Color(0xFFF5F5F5), // Gray border for inactive cards
                    width: _selectedServiceIndex == index ? 3 : 2, // Increased inactive border width to 2
                  ),
                ),
                padding: EdgeInsets.all(4.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: _selectedServiceIndex == index ? 1.0 : 0.6,
                      child: CustomImage(
                        services[index].image,
                        height: 60.h,
                        width: 60.h,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      services[index].title,
                      style: context.mediumText.copyWith(
                        fontSize: 12.sp,
                        color: _selectedServiceIndex == index 
                          ? context.primaryColor 
                          : context.borderColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedServiceDetails(BuyCylinderServiceModel model, BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 0, left: 16.w, right: 16.w, bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        // Border is removed here
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title/header is completely removed
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomImage(
                        model.sub[index].image,
                        height: 40.h,
                        width: 40.h,
                        borderRadius: BorderRadius.circular(4.r),
                      ).withPadding(end: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.sub[index].title, 
                            style: context.mediumText.copyWith(fontSize: 14.sp)
                          ).withPadding(bottom: 4.h),
                          Text(
                            "${model.sub[index].price} ${LocaleKeys.currency.tr()}",
                            style: context.mediumText.copyWith(
                              fontSize: 14.sp, 
                              color: Colors.black
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IncrementRow(model: model, index: index),
                ],
              ),
            ),
            itemCount: model.sub.length,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptionsRow(BuyCylinderServiceModel additionalService, BuildContext context) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: additionalService.sub.isEmpty
          ? Center(child: Text("لا توجد خيارات إضافية", style: context.mediumText))
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                additionalService.sub.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAdditionalIndex = index;
                    });
                  },
                  child: Container(
                    width: 100.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.white, // White background for all cards
                    ),
                    padding: EdgeInsets.all(3.r), // Space for inner border
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: _selectedAdditionalIndex == index
                            ? context.primaryColor
                            : const Color(0xFFF5F5F5), // Gray border for inactive cards
                          width: _selectedAdditionalIndex == index ? 3 : 2,
                        ),
                      ),
                      padding: EdgeInsets.all(4.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: _selectedAdditionalIndex == index ? 1.0 : 0.6,
                            child: CustomImage(
                              additionalService.sub[index].image,
                              height: 60.h,
                              width: 60.h,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            additionalService.sub[index].title,
                            style: context.mediumText.copyWith(
                              fontSize: 12.sp,
                              color: _selectedAdditionalIndex == index 
                                ? context.primaryColor 
                                : context.borderColor,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSelectedAdditionalDetails(BuyCylinderServiceModel additionalService, int selectedIndex, BuildContext context) {
    // Don't show any details if no option is selected
    if (selectedIndex < 0) return SizedBox.shrink();
    
    final selectedOption = additionalService.sub[selectedIndex];
    
    return Container(
      padding: EdgeInsets.only(top: 0, left: 16.w, right: 16.w, bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomImage(
                      selectedOption.image,
                      height: 40.h,
                      width: 40.h,
                      borderRadius: BorderRadius.circular(4.r),
                    ).withPadding(end: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedOption.title, 
                          style: context.mediumText.copyWith(fontSize: 14.sp)
                        ).withPadding(bottom: 4.h),
                        Text(
                          "${selectedOption.price} ${LocaleKeys.currency.tr()}",
                          style: context.mediumText.copyWith(
                            fontSize: 14.sp, 
                            color: Colors.black
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IncrementRow(model: additionalService, index: selectedIndex),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BuyOrRefillWidget extends StatelessWidget {
  final int i;
  final ClientDistributeGasCubit cubit;
  const BuyOrRefillWidget({
    super.key,
    required this.cubit,
    required this.i,
  });

  @override
  Widget build(BuildContext context) {
    BuyCylinderServiceModel model = cubit.services[i];
    if (model.key == 'additional') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(model.title, style: context.boldText.copyWith(fontSize: 16)).withPadding(bottom: 8.h),
          ...List.generate(
            model.sub.length,
            (index) => Container(
              padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
              child: Row(
                children: [
                  CustomImage(
                    model.sub[index].image,
                    height: 60.h,
                    width: 60.h,
                    borderRadius: BorderRadius.circular(4.r),
                  ).withPadding(end: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.sub[index].title, style: context.mediumText.copyWith(fontSize: 12)).withPadding(bottom: 10.h),
                        Text("${model.sub[index].price} ${LocaleKeys.currency.tr()}",
                            style: context.mediumText.copyWith(fontSize: 14, color: context.secondaryContainer)),
                      ],
                    ),
                  ),
                  IncrementRow(model: model, index: index),
                ],
              ),
            ).withPadding(bottom: 12.h),
          )
        ],
      ).withPadding(horizontal: 16.w);
    } else {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
        child: Column(
          children: [
            Row(
              children: [
                CustomImage(
                  model.image,
                  height: 60.h,
                  width: 60.h,
                  borderRadius: BorderRadius.circular(4.r),
                ).withPadding(end: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.title, style: context.mediumText.copyWith(fontSize: 12)).withPadding(bottom: 6.h),
                      Text(model.subTitle, style: context.regularText.copyWith(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ).withPadding(horizontal: 8.w),
            SizedBox(height: 16.h),
            ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.sub[index].title, style: context.mediumText.copyWith(fontSize: 12)).withPadding(bottom: 5.h),
                        Text("${model.sub[index].price} ${LocaleKeys.currency.tr()}",
                            style: context.mediumText.copyWith(fontSize: 14, color: context.secondaryColor)),
                      ],
                    ),
                    IncrementRow(model: model, index: index),
                  ],
                ),
              ),
              itemCount: model.sub.length,
            )
          ],
        ),
      ).withPadding(horizontal: 16.w);
    }
  }
}

class IncrementRow extends StatelessWidget {
  final int index;
  final BuyCylinderServiceModel model;

  const IncrementRow({
    super.key,
    required this.model,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientDistributeGasCubit, ClientDistributeGasState>(
      bloc: sl<ClientDistributeGasCubit>(),
      builder: (context, state) {
        return IncrementWidget(
          count: model.sub[index].count,
          increment: () {
            sl<ClientDistributeGasCubit>().incrementService(key: model.key, model: model.sub[index]);
          },
          decrement: () {
            sl<ClientDistributeGasCubit>().decrementService(key: model.key, model: model.sub[index]);
          },
        );
      },
    );
  }
}

class SelectedItemsSummary extends StatelessWidget {
  final ClientDistributeGasCubit cubit;

  const SelectedItemsSummary({
    super.key,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientDistributeGasCubit, ClientDistributeGasState>(
      bloc: cubit,
      builder: (context, state) {
        // Get all selected items (count > 0) from all services
        List<SelectedItemInfo> selectedItems = [];
        
        for (var service in cubit.services) {
          for (var subItem in service.sub) {
            if (subItem.count > 0) {
              selectedItems.add(
                SelectedItemInfo(
                  title: subItem.title,
                  price: double.tryParse(subItem.price.toString()) ?? 0.0,
                  count: subItem.count,
                  total: (double.tryParse(subItem.price.toString()) ?? 0.0) * subItem.count,
                  image: subItem.image,
                )
              );
            }
          }
        }
        
        if (selectedItems.isEmpty) {
          return SizedBox.shrink();
        }
        
        // Calculate total price
        double totalPrice = selectedItems.fold(0, (sum, item) => sum + item.total);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان ملخص بنفس أسلوب ومكان "اختر"
            Text(
              "ملخص",
              style: context.boldText.copyWith(fontSize: 16)
            ).withPadding(bottom: 16.h, horizontal: 16.w),
            
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...selectedItems.map((item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (item.image != null && item.image.isNotEmpty)
                              CustomImage(
                                item.image,
                                height: 40.h,
                                width: 40.h,
                                borderRadius: BorderRadius.circular(4.r),
                              ).withPadding(end: 8.w),
                            Text(
                              "${item.title} (${item.count}x)",
                              style: context.mediumText.copyWith(fontSize: 14.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Text(
                          "${item.total.toStringAsFixed(2)} ${LocaleKeys.currency.tr()}",
                          style: context.mediumText.copyWith(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )),
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 40.h,
                              width: 40.h,
                            ).withPadding(end: 8.w),
                            Text(
                              "اجمالي",
                              style: context.mediumText.copyWith(fontSize: 14.sp),
                            ),
                          ],
                        ),
                        Text(
                          "${totalPrice.toStringAsFixed(2)} ${LocaleKeys.currency.tr()}",
                          style: context.mediumText.copyWith(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class SelectedItemInfo {
  final String title;
  final double price;
  final int count;
  final double total;
  final String image;

  SelectedItemInfo({
    required this.title,
    required this.price,
    required this.count,
    required this.total,
    required this.image,
  });
}
