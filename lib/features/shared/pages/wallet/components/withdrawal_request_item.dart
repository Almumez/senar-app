import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../../../models/wallet.dart';

class WithdrawalRequestItem extends StatelessWidget {
  final WithdrawalRequestModel data;
  
  const WithdrawalRequestItem({
    super.key,
    required this.data,
  });

  Color _getStatusColor() {
    switch (data.status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (data.status.toLowerCase()) {
      case 'approved':
        return 'تمت الموافقة';
      case 'pending':
        return 'قيد الانتظار';
      case 'rejected':
        return 'مرفوض';
      default:
        return data.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${LocaleKeys.amount.tr()}: ${data.amount} ${LocaleKeys.currency.tr()}',
                style: context.mediumText.copyWith(fontSize: 16.sp),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  _getStatusText(),
                  style: context.mediumText.copyWith(
                    fontSize: 12.sp,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                data.formattedCreatedAt,
                style: context.regularText.copyWith(
                  fontSize: 12.sp,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          if (data.note != null && data.note!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              '${LocaleKeys.description.tr()}: ${data.note}',
              style: context.regularText.copyWith(
                fontSize: 12.sp,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }
} 