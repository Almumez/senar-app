import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading.dart';
import 'controller/cubit.dart';
import '../../../../gen/locale_keys.g.dart';

import '../../components/appbar.dart';
import 'controller/states.dart';

class FaqView extends StatefulWidget {
  const FaqView({super.key});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  final cubit = sl<FaqCubit>();
  @override
  void initState() {
    super.initState();
    cubit.getFaq();
  }

  Future<void> _refresh() async {
    await cubit.getFaq(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(title: LocaleKeys.faq.tr()),
        body: PullToRefresh(
          onRefresh: _refresh,
          child: BlocBuilder<FaqCubit, FaqState>(
            bloc: cubit,
            builder: (context, state) {
              if (state.requestState.isError) {
                return CustomErrorWidget(title: state.msg);
              } else if (state.requestState.isDone && cubit.faq.isNotEmpty) {
                return ListView(
                  padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                  children: List.generate(
                    cubit.faq.length,
                    (index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cubit.faq[index].question, style: context.mediumText.copyWith(fontSize: 16)).withPadding(bottom: 5.h),
                        Text(
                          cubit.faq[index].answer,
                          style: context.regularText.copyWith(fontSize: 12, height: 2),
                        ).withPadding(bottom: 24.h),
                      ],
                    ),
                    // ExpansionTile(
                    //   title: Text(cubit.faq[index].question, style: context.mediumText.copyWith(fontSize: 16)).toStart,
                    //   children: [
                    //     Text(
                    //       cubit.faq[index].answer,
                    //       style: context.regularText.copyWith(fontSize: 12, height: 2),
                    //     ).toStart,
                    // ],
                    // ),
                  ),
                );
              } else if (state.requestState.isDone && cubit.faq.isEmpty) {
                return CustomErrorWidget(title: LocaleKeys.no_faq.tr());
              } else {
                return Center(child: CustomProgress(size: 30));
              }
            },
          ),
        ));
  }
}
