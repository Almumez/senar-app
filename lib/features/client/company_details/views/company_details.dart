import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../gen/locale_keys.g.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../shared/components/appbar.dart';
import '../controller/cubit.dart';
import '../controller/states.dart';

class CompanyDetailsView extends StatefulWidget {
  final String title, id;
  final CompanyServiceType type;
  const CompanyDetailsView({super.key, required this.title, required this.type, required this.id});

  @override
  State<CompanyDetailsView> createState() => _CompanyDetailsViewState();
}

class _CompanyDetailsViewState extends State<CompanyDetailsView> {
  late CompanyDetailsCubit cubit;

  @override
  void initState() {
    sl.resetLazySingleton<CompanyDetailsCubit>();
    cubit = sl<CompanyDetailsCubit>();
    cubit.type = widget.type;
    cubit.getDetails(id: widget.id);
    super.initState();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: widget.title),
      bottomNavigationBar: BlocBuilder<CompanyDetailsCubit, CompanyDetailsState>(
        bloc: cubit,
        builder: (context, state) {
          if (state.requestState.isDone && cubit.data != null) {
            return SafeArea(
              child: AppBtn(
                enable: cubit.servicesSelected(),
                title: LocaleKeys.order_now.tr(),
                onPressed: () => push(NamedRoutes.chooseAddress),
              ).withPadding(horizontal: 16.w, bottom: 16.h),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: BlocBuilder<CompanyDetailsCubit, CompanyDetailsState>(
        bloc: cubit,
        builder: (context, state) {
          if (state.requestState == RequestState.done) {
            return Column(
              children: [
                CustomImage(cubit.data!.image, height: 145.h, width: 145.w, borderRadius: BorderRadius.circular(100)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined, size: 16.h),
                    Text(cubit.data!.address),
                  ],
                ).withPadding(bottom: 25.h),
                if (cubit.data!.description.isNotEmpty)
                  Container(
                    width: context.w,
                    padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${LocaleKeys.description.tr()} : ", style: context.mediumText),
                        Expanded(child: Text(cubit.data!.description, style: context.regularText.copyWith(fontSize: 12))),
                      ],
                    ),
                  ).withPadding(horizontal: 16.w, bottom: 20.h),
                if (cubit.data!.services.isNotEmpty)
                  Text("• ${LocaleKeys.services.tr()}", style: context.boldText).withPadding(horizontal: 16.w, bottom: 10.h).toStart,
                Expanded(
                  child: ListView.separated(
                    itemCount: cubit.data!.services.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(height: 8.h, color: context.shadowColor.withValues(alpha: .3)).withPadding(vertical: 16.h);
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${index + 1}. ${cubit.data!.services[index].title}", style: context.mediumText).withPadding(bottom: 10.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
                            child: Row(
                              children: [
                                Expanded(child: Text(cubit.data!.services[index].description)),
                                Checkbox(
                                    value: cubit.data!.services[index].isSelected,
                                    onChanged: (value) {
                                      cubit.selectService(cubit.data!.services[index].id);
                                    })
                              ],
                            ),
                          ),
                        ],
                      ).withPadding(horizontal: 16.w);
                    },
                  ),
                )
              ],
            );
          } else if (state.requestState == RequestState.error) {
            return Center(child: Text(state.msg));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
