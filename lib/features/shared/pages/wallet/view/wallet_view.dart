import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import '../controller/wallet_cubit.dart';
import '../controller/wallet_states.dart';

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  final cubit = sl<WalletCubit>()..getWallet();
  
  Future<void> _refresh() async {
    await cubit.getWallet();
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
                  children: [
                    WalletCard(amount: "${cubit.data?.balance ?? ''}").withPadding(bottom: 16.h),
                    if (cubit.data!.balance > 0)
                      GestureDetector(
                        onTap: () => push(NamedRoutes.withdrow, arg: {'amount': cubit.data?.balance}),
                        child: DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            radius: Radius.circular(8.r),
                            padding: EdgeInsets.zero,
                            dashPattern: [8, 4],
                          ),
                          child: SizedBox(
                            height: 48.h,
                            child: Text(
                              LocaleKeys.withdraw.tr(),
                              style: context.mediumText.copyWith(fontSize: 20),
                            ).center,
                          ),
                        ).withPadding(bottom: 16.h),
                      ),
                    (() {
                      if (cubit.data?.transactions.isNotEmpty ?? false) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(LocaleKeys.latest_transactions.tr(), style: context.mediumText.copyWith(fontSize: 20)),
                                InkWell(
                                  onTap: () {
                                    push(NamedRoutes.transactions);
                                  },
                                  child: Text(LocaleKeys.see_all.tr(), style: context.mediumText.copyWith(fontSize: 14)).withPadding(vertical: 4.h),
                                )
                              ],
                            ).withPadding(bottom: 16.h),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) => TransactionItem(data: cubit.data!.transactions[index]).withPadding(bottom: 16.h),
                              itemCount: cubit.data?.transactions.length ?? 0,
                            )
                          ],
                        );
                      } else {
                        return CustomErrorWidget(
                          title: LocaleKeys.transcations.tr(),
                          image: "assets/svg/wallet_icon.svg",
                          subtitle: LocaleKeys.no_transactions_yet.tr(),
                          errType: ErrorType.empty,
                        ).withPadding(vertical: 24.h);
                      }
                    })(),
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
