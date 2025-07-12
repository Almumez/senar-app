import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/widgets/flash_helper.dart';
import '../../../../../gen/assets.gen.dart';

import '../../../../../core/routes/app_routes_fun.dart';
import '../../../../../core/routes/routes.dart';
import '../../../../../core/services/service_locator.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/utils/pull_to_refresh.dart';
import '../../../../../core/widgets/error_widget.dart';
import '../../../../../core/widgets/loading.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../components/appbar.dart';
import '../components/transaction_item.dart';
import '../components/wallet_card.dart';
import '../components/withdrawal_request_item.dart';
import '../controller/wallet_cubit.dart';
import '../controller/wallet_states.dart';

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  final cubit = sl<WalletCubit>()
    ..getWallet()
    ..getWithdrawalRequests();
  final _amountController = TextEditingController();
  
  Future<void> _refresh() async {
    await cubit.getWallet();
    await cubit.getWithdrawalRequests();
  }
  
  void _showRequestMoneyPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: "#BDBDD3".color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wallet,
                    color: context.primaryColor,
                    size: 35.r,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  LocaleKeys.request_money.tr(),
                  style: context.mediumText.copyWith(
                    fontSize: 18.sp,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: LocaleKeys.amount.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(LocaleKeys.cancel.tr()),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_amountController.text.trim().isNotEmpty) {
                            _requestWithdrawal(double.parse(_amountController.text.trim()));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(LocaleKeys.request.tr()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _requestWithdrawal(double amount) async {
    LoadingDialog.show();
    final result = await cubit.requestWithdrawal(amount);
    LoadingDialog.hide();
    Navigator.pop(context);
    
    if (result.success) {
      FlashHelper.showToast(result.msg);
    } else {
      FlashHelper.showToast(result.msg);
    }
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.wallet.tr()),
      body: PullToRefresh(
        onRefresh: _refresh,
        child: BlocBuilder<WalletCubit, WalletState>(
          bloc: cubit,
          builder: (context, state) {
            if (state.getWaletState.isError) {
              return CustomErrorWidget(title: state.msg);
            } else if (state.getWaletState.isDone) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WalletCard(amount: "${cubit.data?.balance ?? ''}").withPadding(bottom: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _showRequestMoneyPopup,
                            child: DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                radius: Radius.circular(8.r),
                                padding: EdgeInsets.zero,
                                dashPattern: [8, 4],
                              ),
                              child: SizedBox(
                                height: 48.h,
                                child: Text(
                                  LocaleKeys.request_money.tr(),
                                  style: context.mediumText.copyWith(fontSize: 20),
                                ).center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).withPadding(bottom: 16.h),
                    
                    // Withdrawal Requests Section
                    BlocBuilder<WalletCubit, WalletState>(
                      bloc: cubit,
                      builder: (context, state) {
                        if (state.getWithdrawalRequestsState.isLoading) {
                          return Center(child: CustomProgress(size: 30.h));
                        } else if (state.getWithdrawalRequestsState.isDone) {
                          if (cubit.withdrawalRequests.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocaleKeys.withdrawal_requests.tr(),
                                  style: context.mediumText.copyWith(fontSize: 20),
                                ).withPadding(bottom: 16.h),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) => WithdrawalRequestItem(
                                    data: cubit.withdrawalRequests[index],
                                  ).withPadding(bottom: 16.h),
                                  itemCount: cubit.withdrawalRequests.length,
                                ),
                                SizedBox(height: 16.h),
                              ],
                            );
                          } else {
                            return SizedBox();
                          }
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: CustomProgress(size: 30.h));
            }
          },
        ),
      ),
    );
  }
}
