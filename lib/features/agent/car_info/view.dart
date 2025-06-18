import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/service_locator.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_btn.dart';
import '../../../core/widgets/loading.dart';
import '../../../core/widgets/successfully_sheet.dart';
import '../../../core/widgets/upload_image.dart';
import '../../../gen/locale_keys.g.dart';
import '../../shared/components/appbar.dart';
import 'controller/cubit.dart';
import 'controller/state.dart';

class FreeAgentCarInfoView extends StatefulWidget {
  const FreeAgentCarInfoView({super.key});

  @override
  State<FreeAgentCarInfoView> createState() => _FreeAgentCarInfoViewState();
}

class _FreeAgentCarInfoViewState extends State<FreeAgentCarInfoView> {
  final cubit = sl<FreeAgentCarInfoCubit>();
  @override
  void initState() {
    super.initState();
    cubit.getCarInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.edit_car_info.tr()),
      bottomNavigationBar: SafeArea(
        child: BlocConsumer<FreeAgentCarInfoCubit, FreeAgentCarInfoState>(
          bloc: cubit,
          listener: (context, state) {
            if (state.editState.isDone) {
              showModalBottomSheet(
                elevation: 0,
                context: context,
                isScrollControlled: true,
                isDismissible: true,
                builder: (context) => SuccessfullySheet(
                  title: LocaleKeys.car_info_updated_successfully.tr(),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.getState.isDone) {
              return AppBtn(
                loading: state.editState.isLoading,
                title: LocaleKeys.save_changes.tr(),
                onPressed: () {
                  if (cubit.validateSave) {
                    cubit.editCarInfo();
                  }
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ).withPadding(horizontal: 16.w, vertical: 16.h),
      ),
      body: BlocBuilder<FreeAgentCarInfoCubit, FreeAgentCarInfoState>(
        buildWhen: (previous, current) => previous.getState != current.getState,
        bloc: cubit,
        builder: (context, state) {
          if (state.getState.isDone) {
            return SingleChildScrollView(
              child: Column(
                spacing: 16.h,
                children: [
                  UploadImage(
                    title: LocaleKeys.driving_license.tr(),
                    model: 'FreeAgent',
                    data: cubit.license,
                  ),
                  UploadImage(
                    title: LocaleKeys.vehicle_registration_form.tr(),
                    model: 'FreeAgent',
                    data: cubit.vehicleForm,
                  ),
                  UploadImage(
                    title: LocaleKeys.health_certificate.tr(),
                    model: 'FreeAgent',
                    data: cubit.healthCertificate,
                  )
                ],
              ).withPadding(horizontal: 16.w, vertical: 16.h),
            );
          } else {
            return Center(child: CustomProgress(size: 30.h));
          }
        },
      ),
    );
  }
}
