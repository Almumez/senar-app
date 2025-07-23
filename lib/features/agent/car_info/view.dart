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
      backgroundColor: Colors.white,
      appBar: CustomAppbar(
        title: LocaleKeys.edit_car_info.tr(),
      ),
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
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: AppBtn(
                  loading: state.editState.isLoading,
                  title: LocaleKeys.save_changes.tr(),
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  radius: 30.r,
                  onPressed: () {
                    if (cubit.validateSave) {
                      cubit.editCarInfo();
                    }
                  },
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
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
                  _buildUploadCard(
                    title: LocaleKeys.driving_license.tr(),
                    data: cubit.license,
                    context: context,
                  ),
                  SizedBox(height: 16.h),
                  _buildUploadCard(
                    title: LocaleKeys.vehicle_registration_form.tr(),
                    data: cubit.vehicleForm,
                    context: context,
                  ),
                  SizedBox(height: 16.h),
                  _buildUploadCard(
                    title: LocaleKeys.health_certificate.tr(),
                    data: cubit.healthCertificate,
                    context: context,
                  )
                ],
              ).withPadding(horizontal: 16.w, vertical: 16.h),
            );
          } else {
            return Center(
              child: CustomProgress(
                size: 30.h,
                color: Colors.black,
              ),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildUploadCard({
    required String title,
    required dynamic data,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: UploadImage(
        title: title,
        model: 'FreeAgent',
        data: data,
        titleStyle: context.mediumText.copyWith(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }
}
