import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/services/service_locator.dart';
import '../../../../../core/widgets/app_btn.dart';
import '../../../../../core/widgets/confirmation_sheet.dart';
import '../../../../../core/widgets/successfully_sheet.dart';
import '../controller/wallet_cubit.dart';
import '../controller/wallet_states.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/widgets/app_field.dart';
import '../../../components/appbar.dart';
import '../../../../../gen/locale_keys.g.dart';

class WithdrowView extends StatefulWidget {
  final double amount;
  const WithdrowView({super.key, required this.amount});

  @override
  State<WithdrowView> createState() => _WithdrowViewState();
}

class _WithdrowViewState extends State<WithdrowView> {
  final cubit = sl<WalletCubit>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.wallet.tr()),
      bottomNavigationBar: BlocConsumer<WalletCubit, WalletState>(
        bloc: cubit,
        buildWhen: (previous, current) => previous.withdrowState != current.withdrowState,
        listenWhen: (previous, current) => previous.withdrowState != current.withdrowState,
        listener: (context, state) {
          if (state.withdrowState.isDone) {
            showModalBottomSheet(
              context: context,
              isDismissible: false,
              enableDrag: false,
              builder: (c) => SuccessfullySheet(
                title: LocaleKeys.withdraw_request_success.tr(),
                onLottieFinish: () {
                  Navigator.pop(context);
                },
              ),
            );
          }
        },
        builder: (context, state) {
          return AppBtn(
            loading: state.withdrowState.isLoading,
            title: LocaleKeys.withdraw_amount.tr(),
            onPressed: () {
              if (cubit.formKey.isValid) {
                showModalBottomSheet(
                  context: context,
                  builder: (c) => ConfirmationSheet(
                    title: LocaleKeys.withdraw_confirmation.tr(args: [cubit.amount.text]),
                    subTitle: LocaleKeys.withdraw_balance_prompt.tr(),
                  ),
                ).then((v) {
                  if (v == true) {
                    cubit.withDrow();
                  }
                });
              }
            },
          );
        },
      ).withPadding(horizontal: 16.w, vertical: 12.h),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Form(
          key: cubit.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              SizedBox(height: 24.h),
              Container(
                decoration: BoxDecoration(
                  color: '#757575'.color,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.all(20.r),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        LocaleKeys.current_balance.tr(),
                        style: context.semiboldText.copyWith(color: context.primaryColorLight, fontSize: 16),
                      ),
                    ),
                    Text(
                      "${widget.amount} ${LocaleKeys.currency.tr()}",
                      style: context.semiboldText.copyWith(color: context.primaryColorLight, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              AppField(
                controller: cubit.amount,
                labelText: LocaleKeys.amount.tr(),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final amount = double.tryParse('$v');
                  if (amount == null) {
                    return LocaleKeys.invalid_value.tr();
                  } else if (amount > widget.amount) {
                    return LocaleKeys.insufficient_balance.tr();
                  }
                  return null;
                },
                suffixIcon: SizedBox(
                  width: 100.w,
                  child: Container(
                    decoration: BoxDecoration(color: '#F4F7FC'.color, borderRadius: BorderRadius.circular(4.r)),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Text(
                      LocaleKeys.sar.tr(),
                      style: context.regularText.copyWith(fontSize: 14),
                    ),
                  ).center,
                ),
              ),
              SizedBox(height: 20.h),
              AppField(
                controller: cubit.bankName,
                labelText: LocaleKeys.bank_name.tr(),
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 20.h),
              AppField(
                controller: cubit.receiverName,
                labelText: LocaleKeys.card_holder_name.tr(),
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 20.h),
              AppField(
                controller: cubit.accountNumber,
                labelText: LocaleKeys.account_number.tr(),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
