import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/service_locator.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/custom_image.dart';
import '../../../core/widgets/flash_helper.dart';
import '../../../core/widgets/loading.dart';
import '../../../core/widgets/pick_image.dart';
import '../../../gen/locale_keys.g.dart';
import '../../features/shared/controller/upload_attachment/attachment_cubit.dart';
import '../../features/shared/controller/upload_attachment/attachment_state.dart';
import '../../models/attachment.dart';
import 'app_btn.dart';

class UploadImage extends StatefulWidget {
  final String title, model;
  final AttachmentModel data;
  final TextStyle? titleStyle;
  final bool showTitle; // إضافة خيار لإظهار العنوان
  final double borderRadius; // إضافة خيار لتعديل نصف قطر الحدود
  final double borderRadiusBottom; // إضافة خيار لتعديل نصف قطر الحدود السفلية

  // final Function(String) callback;
  const UploadImage({
    super.key,
    required this.title,
    // required this.callback,
    required this.model,
    required this.data,
    this.titleStyle,
    this.showTitle = true, // القيمة الافتراضية هي إظهار العنوان
    this.borderRadius = 14, // القيمة الافتراضية لنصف قطر الحدود
    this.borderRadiusBottom = 14, // القيمة الافتراضية لنصف قطر الحدود السفلية
  });

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  final bloc = sl<UploadAttachmentCubit>();

  upload() async {
    final result = await showModalBottomSheet(
      elevation: 0,
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) => PickImage(
        title: LocaleKeys.pick_image.tr(),
      ),
    );
    if (result != null) {
      setState(() {
        bloc.file = result;
      });
      bloc.uploadAttachment(model: widget.model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadAttachmentCubit, UploadAttachmentState>(
      bloc: bloc,
      listener: (context, state) {
        widget.data.loading = state.requestState.isLoading;
        if (state.requestState.isDone) {
          // حفظ الملف والمسار
          widget.data.file = state.file;
          widget.data.url = state.file!.path;
          widget.data.key = state.key;
          setState(() {});
        } else if (state.requestState.isError) {
          FlashHelper.showToast(state.msg);
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            if (!state.requestState.isLoading) {
              upload();
            }
          },
          child: Column(
            children: [
              Container(
                constraints: BoxConstraints(minHeight: 109.h),
                decoration: BoxDecoration(
                  color: context.borderColor.withValues(alpha: .5), 
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.borderRadius.r),
                    topRight: Radius.circular(widget.borderRadius.r),
                    bottomLeft: Radius.circular(widget.borderRadiusBottom.r),
                    bottomRight: Radius.circular(widget.borderRadiusBottom.r),
                  ),
                ),
                // height: widget.data.url == null ? 109.h : 205.h,
                width: context.w,
                child: widget.data.url == null ? selectImage(state, context) : selectedImage(state, context),
              ).center,
            ],
          ),
        );
      },
    );
  }

  Widget selectImage(UploadAttachmentState state, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        state.requestState.isLoading
            ? CustomProgress(size: 20, color: context.secondaryHeaderColor).center
            : Icon(Icons.image_outlined, color: context.secondaryHeaderColor).center,
        if (widget.showTitle) ...[
          SizedBox(height: 16.h),
          Text(
            "${LocaleKeys.upload.tr()} ${widget.title}",
            style: widget.titleStyle ?? context.mediumText.copyWith(color: context.secondaryHeaderColor),
          ),
        ],
      ],
    );
  }

  Widget selectedImage(UploadAttachmentState state, BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 5.h),
        CustomImage(
          widget.data.url,
          height: 135.h,
          width: 225.w,
          fit: BoxFit.cover,
          isFile: true,
          borderRadius: BorderRadius.circular(14.r),
          child: state.requestState.isLoading ? CustomProgress(size: 20, color: context.primaryColorLight) : null,
        ).center,
        Row(
          children: [
            Expanded(
              child: AppBtn(
                saveArea: false,
                loading: state.requestState.isLoading,
                icon: Icon(Icons.image_outlined, color: context.primaryColorDark, size: 16.h),
                height: 32.h,
                title: widget.showTitle ? LocaleKeys.change_image.tr() : LocaleKeys.change_image.tr(),
                backgroundColor: Colors.transparent,
                textColor: context.primaryColorDark,
                onPressed: () {
                  upload();
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AppBtn(
                saveArea: false,
                icon: Icon(CupertinoIcons.delete, color: context.errorColor, size: 16.h),
                height: 32.h,
                title: widget.showTitle ? LocaleKeys.delete_image.tr() : LocaleKeys.delete_image.tr(),
                backgroundColor: Colors.transparent,
                textColor: context.errorColor,
                onPressed: () {
                  widget.data.url = null;
                  widget.data.key = null;
                  widget.data.loading = false;
                  bloc.clear();
                },
              ),
            )
          ],
        ).withPadding(top: 5.h, horizontal: 16)
      ],
    );
  }
}
