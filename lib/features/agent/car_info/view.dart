import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/services/service_locator.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_btn.dart';
import '../../../core/widgets/flash_helper.dart';
import '../../../core/widgets/loading.dart';
import '../../../core/widgets/successfully_sheet.dart';
import '../../../core/widgets/upload_image.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/locale_keys.g.dart';
import '../../shared/components/appbar.dart';
import 'controller/cubit.dart';
import 'controller/state.dart';
import '../../../models/user_model.dart';
import '../../../core/utils/enums.dart';


class FreeAgentCarInfoView extends StatefulWidget {
  const FreeAgentCarInfoView({super.key});

  @override
  State<FreeAgentCarInfoView> createState() => _FreeAgentCarInfoViewState();
}

class _FreeAgentCarInfoViewState extends State<FreeAgentCarInfoView> {
  final cubit = sl<FreeAgentCarInfoCubit>();
  bool get isClient => UserModel.i.accountType == UserType.client;

  @override
  void initState() {
    super.initState();
    // إزالة استدعاء API - تظهر الواجهة مباشرة
  }

  @override
  Widget build(BuildContext context) {
    // عرض الفورم مباشرة للجميع بدون استدعاء API
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppbar(
        title: LocaleKeys.agent_documents.tr(),
      ),
      body: _buildFormContent(context),
      bottomNavigationBar: SafeArea(
        child: _buildSaveButton(context),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نص توضيحي
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: context.primaryColor,
                    size: 24.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      LocaleKeys.agent_documents_info.tr(),
                      style: context.regularText.copyWith(
                        fontSize: 14.sp,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // رخصة القيادة
            _buildDocumentSection(
              title: LocaleKeys.driving_license.tr(),
              subtitle: LocaleKeys.driving_license_desc.tr(),
              icon: "assets/svg/license.svg",
              data: cubit.license,
              context: context,
            ),
            // استمارة المركبة
            _buildDocumentSection(
              title: LocaleKeys.vehicle_registration_form.tr(),
              subtitle: LocaleKeys.vehicle_registration_form.tr(),
              icon: "assets/svg/car.svg",
              data: cubit.vehicleForm,
              context: context,
            ),
            // الهوية
            _buildDocumentSection(
              title: LocaleKeys.identity.tr(),
              subtitle: LocaleKeys.identity_desc.tr(),
              icon: "assets/svg/id_card.svg",
              data: cubit.identity,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return BlocConsumer<FreeAgentCarInfoCubit, FreeAgentCarInfoState>(
      bloc: cubit,
      listener: (context, state) {
        if (state.editState.isDone) {
          showModalBottomSheet(
            elevation: 0,
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            builder: (context) => SuccessfullySheet(
              title: LocaleKeys.documents_updated_successfully.tr(),
              subTitle: LocaleKeys.lang.tr() == 'en' 
                ? "Your documents have been successfully uploaded and are being reviewed by our team."
                : "تم رفع وثائقك بنجاح وجاري مراجعتها من قبل فريقنا.",
              onLottieFinish: () {
                Navigator.pop(context);
              },
            ),
          );
        } else if (state.editState.isError) {
          FlashHelper.showToast(state.msg);
        }
      },
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: AppBtn(
            loading: state.editState.isLoading,
            title: LocaleKeys.save_changes.tr(),
            backgroundColor: context.primaryColor,
            textColor: Colors.white,
            radius: 12.r,
            onPressed: () {
              if (cubit.validateSave) {
                cubit.editCarInfo();
              }
            },
          ),
        );
      },
    );
  }
  
  Widget _buildDocumentSection({
    required String title,
    required String subtitle,
    required String icon,
    required dynamic data,
    required BuildContext context,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      icon,
                      width: 24.w,
                      height: 24.w,
                      colorFilter: ColorFilter.mode(
                        context.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.semiboldText.copyWith(fontSize: 16.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: context.regularText.copyWith(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // مكون رفع الصورة
          UploadImage(
            title: "",
            model: 'FreeAgent',
            data: data,
            showTitle: false,
            borderRadius: 0,
            borderRadiusBottom: 12.r,
          ),
        ],
      ),
    );
  }
}
