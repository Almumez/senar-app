import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../gen/locale_keys.g.dart';
import '../controller/cubit.dart';
import '../controller/state.dart';

class MyAddressWidgets extends StatefulWidget {
  final Function(String) callback;
  final String? initialId;
  const MyAddressWidgets({super.key, required this.callback, this.initialId});

  @override
  State<MyAddressWidgets> createState() => _MyAddressWidgetsState();
}

class _MyAddressWidgetsState extends State<MyAddressWidgets> {
  String selectedOption = '';

  late AddressesCubit cubit;

  @override
  void initState() {
    selectedOption = widget.initialId ?? '';
    sl.resetLazySingleton<AddressesCubit>();
    cubit = sl<AddressesCubit>();

    cubit.getAddresses();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressesCubit, AddressesState>(
      bloc: cubit,
      builder: (context, state) {
        if (state.getStateState.isDone) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/location-2.svg',
                        height: 22.h,
                        width: 22.w,
                      ),
                      SizedBox(width: 8.w),
                      Text("موقع", 
                        style: context.semiboldText.copyWith(fontSize: 16)
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => push(NamedRoutes.pickLocation),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: context.primaryColor,
                            size: 16.h,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "اضافه",
                            style: context.mediumText.copyWith(
                              fontSize: 14.sp,
                              color: context.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).withPadding(bottom: 16.h),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cubit.addresses.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.callback(cubit.addresses[index].id);
                        selectedOption = cubit.addresses[index].id;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 10.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r), 
                        border: selectedOption == cubit.addresses[index].id 
                            ? null 
                            : Border.all(
                                color: context.borderColor,
                                width: 1,
                              ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cubit.addresses[index].placeTitle, 
                                  style: context.mediumText.copyWith(
                                    fontSize: 13,
                                    color: selectedOption == cubit.addresses[index].id 
                                      ? context.primaryColor 
                                      : Colors.black,
                                  )
                                ).withPadding(bottom: 4.h),
                                Text(
                                  cubit.addresses[index].placeDescription, 
                                  style: context.regularText.copyWith(fontSize: 10),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.callback(cubit.addresses[index].id);
                                selectedOption = cubit.addresses[index].id;
                              });
                            },
                            child: Container(
                              width: 20.w,
                              height: 20.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectedOption == cubit.addresses[index].id
                                    ? context.primaryColor
                                    : Colors.transparent,
                                border: Border.all(
                                  color: selectedOption == cubit.addresses[index].id
                                      ? context.primaryColor
                                      : Colors.grey.shade400,
                                  width: 1.5,
                                ),
                              ),
                              margin: EdgeInsets.only(right: 8.w),
                            ),
                          ),
                        ],
                      ),
                    ).withPadding(bottom: 8.h),
                  );
                },
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
