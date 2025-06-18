import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/address_sheet.dart';
import '../../../../core/widgets/app_btn.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/appbar.dart';
import '../controller/cubit.dart';
import '../controller/state.dart';

class AddressesView extends StatefulWidget {
  const AddressesView({super.key});

  @override
  State<AddressesView> createState() => _AddressesViewState();
}

class _AddressesViewState extends State<AddressesView> {
  late AddressesCubit cubit;

  get groupValue => null;

  @override
  void initState() {
    sl.resetLazySingleton<AddressesCubit>();
    cubit = sl<AddressesCubit>();

    cubit.getAddresses();
    super.initState();
  }

  Future<void> _refresh() async {
    await cubit.getAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(title: LocaleKeys.saved_addresses.tr()),
        bottomNavigationBar: BlocBuilder<AddressesCubit, AddressesState>(
            bloc: cubit,
            builder: (context, state) {
              if (state.getStateState.isDone) {
                return SafeArea(
                  child: AppBtn(
                    title: LocaleKeys.add_new_address.tr(),
                    icon: Icon(Icons.add, color: context.primaryColorLight),
                    onPressed: () => push(NamedRoutes.pickLocation),
                  ).withPadding(horizontal: 24.w, bottom: 16.h),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
        body: PullToRefresh(
          onRefresh: _refresh,
          child: BlocBuilder<AddressesCubit, AddressesState>(
            bloc: cubit,
            builder: (context, state) {
              if (state.getStateState.isDone) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cubit.addresses.isNotEmpty)
                      Text("• ${LocaleKeys.my_address.tr()}", style: context.semiboldText.copyWith(fontSize: 16)).withPadding(vertical: 15.h),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cubit.addresses.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cubit.addresses[index].placeTitle, style: context.mediumText.copyWith(fontSize: 16)).withPadding(bottom: 10.h),
                                      Text(cubit.addresses[index].placeDescription, style: context.regularText.copyWith(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => push(NamedRoutes.pickLocation, arg: {"data": cubit.addresses[index]}),
                                  child: CustomImage(Assets.svg.edit, color: context.secondaryColor),
                                ).withPadding(end: 10.w),
                                InkWell(
                                  onTap: () => showModalBottomSheet(
                                    elevation: 0,
                                    context: context,
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    builder: (context) => DeleteAddressSheet(id: cubit.addresses[index].id),
                                  ),
                                  child: CustomImage(Assets.svg.delete),
                                ).withPadding(end: 10.w),
                                SizedBox(
                                  height: 24.h, // Adjust the size as needed
                                  width: 24.h,
                                  child: Radio(
                                    value: cubit.addresses[index].id,
                                    groupValue: cubit.defaultAddressId,
                                    onChanged: (_) => cubit.setDefaultAddress(id: cubit.addresses[index].id),
                                  ),
                                )
                              ],
                            ),
                          ).withPadding(bottom: 10.h);
                        },
                      ),
                    ),
                  ],
                ).withPadding(horizontal: 16.w);
              } else if (state.getStateState.isError) {}
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}
