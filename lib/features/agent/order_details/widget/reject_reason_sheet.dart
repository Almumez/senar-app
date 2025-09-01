import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../gen/locale_keys.g.dart';
import '../cubit/order_details_cubit.dart';
import '../cubit/order_details_state.dart';

class RejectReasonSheet extends StatefulWidget {
  final AgentOrderDetailsCubit cubit;
  const RejectReasonSheet({super.key, required this.cubit});

  @override
  State<RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<RejectReasonSheet> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.reject_order.tr(),
                style: context.semiboldText.copyWith(fontSize: 18),
              ),
              IconButton(
                icon: Icon(Icons.close, color: context.hintColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            LocaleKeys.reject_reason.tr(),
            style: context.mediumText,
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: context.borderColor),
            ),
            child: TextField(
              controller: _reasonController,
              maxLines: 4,
              style: context.regularText,
              decoration: InputDecoration(
                hintText: LocaleKeys.enter_reject_reason.tr(),
                hintStyle: context.regularText.copyWith(color: context.hintColor),
                contentPadding: EdgeInsets.all(12.w),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          BlocBuilder<AgentOrderDetailsCubit, AgentOrderDetailsState>(
            bloc: widget.cubit,
            buildWhen: (previous, current) => previous.rejectOrder != current.rejectOrder,
            builder: (context, state) {
              return AbsorbPointer(
                absorbing: state.rejectOrder.isLoading,
                child: Opacity(
                  opacity: state.rejectOrder.isLoading ? 0.7 : 1.0,
                  child: Row(
                    children: [
                      Expanded(
                        child: AppBtn(
                          onPressed: state.rejectOrder.isLoading ? null : () => Navigator.pop(context),
                          textColor: context.primaryColor,
                          backgroundColor: Colors.transparent,
                          title: LocaleKeys.cancel.tr(),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: AppBtn(
                          onPressed: state.rejectOrder.isLoading ? null : () {
                            widget.cubit.rejectOrder(_reasonController.text);
                          },
                          textColor: Colors.white,
                          backgroundColor: Colors.black,
                          loading: state.rejectOrder.isLoading,
                          title: LocaleKeys.reject.tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
} 