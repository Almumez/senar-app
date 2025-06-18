import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../gen/locale_keys.g.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../../core/utils/enums.dart';
import '../../components/appbar.dart';
import 'controller/cubit.dart';
import 'controller/states.dart';

class StaticView extends StatefulWidget {
  final StaticType type;
  const StaticView({super.key, required this.type});

  @override
  State<StaticView> createState() => _StaticViewState();
}

class _StaticViewState extends State<StaticView> {
  final cubit = sl<StaticCubit>();
  getUrl() {
    switch (widget.type) {
      case StaticType.about:
        return 'general/page/about';
      case StaticType.privacy:
        return 'general/page/privacy';
      case StaticType.terms:
        return 'general/page/terms';
    }
  }

  getTitle() {
    switch (widget.type) {
      case StaticType.about:
        return LocaleKeys.about_us.tr();
      case StaticType.privacy:
        return LocaleKeys.privacy_policy.tr();
      case StaticType.terms:
        return LocaleKeys.terms_and_conditions.tr();
    }
  }

  Future<void> _refresh() async {
    await cubit.getStatic(getUrl());
  }

  @override
  void initState() {
    super.initState();
    cubit.getStatic(getUrl());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: getTitle()),
      body: PullToRefresh(
        onRefresh: _refresh,
        child: BlocBuilder<StaticCubit, StaticState>(
            bloc: cubit,
            builder: (context, state) {
              if (state.requestState.isDone) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      if (state.data?.image != null) CustomImage(state.data?.image, width: 361.w, height: 230.h).center,
                      HtmlWidget(
                        state.data?.content ?? '',
                      ).withPadding(horizontal: 16.w, vertical: 16.h),
                    ],
                  ),
                );
              } else if (state.requestState.isError) {
                return CustomErrorWidget(title: state.msg);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }
}
