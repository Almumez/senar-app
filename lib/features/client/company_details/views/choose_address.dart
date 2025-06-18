import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/extensions.dart';
import '../../addresses/components/my_addresses.dart';
import '../../../shared/components/appbar.dart';
import '../../../../gen/locale_keys.g.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_btn.dart';
import '../controller/cubit.dart';
import '../controller/states.dart';

class ChooseAddressView extends StatefulWidget {
  const ChooseAddressView({super.key});

  @override
  State<ChooseAddressView> createState() => _ChooseAddressViewState();
}

class _ChooseAddressViewState extends State<ChooseAddressView> {
  final cubit = sl<CompanyDetailsCubit>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.delivery_address_and_time.tr()),
      bottomNavigationBar:
          BlocBuilder<CompanyDetailsCubit, CompanyDetailsState>(
        bloc: cubit,
        builder: (context, state) {
          if (state.requestState.isDone && cubit.data != null) {
            return SafeArea(
              child: AppBtn(
                loading: state.completeOrderState == RequestState.loading,
                enable: cubit.addressSelected(),
                title: LocaleKeys.complete_order.tr(),
                onPressed: () => cubit.completeOrder(),
              ).withPadding(horizontal: 16.w, bottom: 16.h),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: SingleChildScrollView(
        child: MyAddressWidgets(
          initialId: cubit.addressId,
          callback: (val) {
            cubit.chooseAddress(val);
          },
        ).withPadding(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}
