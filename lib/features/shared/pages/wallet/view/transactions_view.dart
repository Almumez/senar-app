import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/services/service_locator.dart';
import '../../../../../core/utils/pull_to_refresh.dart';
import '../../../../../core/widgets/error_widget.dart';
import '../../../../../core/widgets/loading.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../components/appbar.dart';
import '../components/transaction_item.dart';
import '../controller/wallet_cubit.dart';
import '../controller/wallet_states.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final cubit = sl<WalletCubit>()..getTranscations();
  
  Future<void> _refresh() async {
    await cubit.getTranscations();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.transcations.tr()),
      bottomNavigationBar: BlocBuilder<WalletCubit, WalletState>(
        bloc: cubit,
        buildWhen: (previous, current) => previous.getTransactionsPagingState != current.getTransactionsPagingState,
        builder: (context, state) => PaginationLoading(isLoading: state.getTransactionsPagingState.isLoading),
      ),
      body: PullToRefresh(
        onRefresh: _refresh,
        child: BlocBuilder<WalletCubit, WalletState>(
          bloc: cubit,
          buildWhen: (previous, current) => previous.getTransactionsState != current.getTransactionsState,
          builder: (context, state) {
            if (cubit.transcations.isNotEmpty) {
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                controller: cubit.scrollController,
                itemCount: cubit.transcations.length,
                itemBuilder: (context, index) => TransactionItem(data: cubit.transcations[index]),
                separatorBuilder: (BuildContext context, int index) => SizedBox(height: 16.h),
              );
            } else if (state.getTransactionsState.isError) {
              return CustomErrorWidget(
                title: LocaleKeys.transcations.tr(),
                subtitle: state.msg,
                errType: state.errorType,
              );
            } else {
              return LoadingApp();
            }
          },
        ),
      ),
    );
  }
}
