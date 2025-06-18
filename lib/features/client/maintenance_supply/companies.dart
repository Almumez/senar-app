import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routes/app_routes_fun.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/custom_image.dart';
import '../../shared/components/appbar.dart';

import '../../../core/utils/enums.dart';
import '../../../gen/locale_keys.g.dart';
import 'controller/cubit.dart';
import 'controller/states.dart';

class ClientMaintenanceCompaniesView extends StatefulWidget {
  final CompanyServiceType type;
  const ClientMaintenanceCompaniesView({super.key, required this.type});

  @override
  State<ClientMaintenanceCompaniesView> createState() => _ClientMaintenanceCompaniesViewState();
}

class _ClientMaintenanceCompaniesViewState extends State<ClientMaintenanceCompaniesView> {
  final cubit = sl<ClientMaintenanceSupplyCubit>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    cubit.type = widget.type;
    cubit.fetchCompanies();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
        cubit.fetchCompanies(isPagination: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await cubit.fetchCompanies();
  }

  getTitle() {
    switch (widget.type) {
      case CompanyServiceType.maintenance:
        return LocaleKeys.stove_and_oven_maintenance.tr();
      case CompanyServiceType.supply:
        return LocaleKeys.pipe_supplies.tr();
    }
  }

  getSubTitle() {
    switch (widget.type) {
      case CompanyServiceType.maintenance:
        return LocaleKeys.all_maintenance_companies.tr();
      case CompanyServiceType.supply:
        return LocaleKeys.all_pipe_supply_companies.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: getTitle()),
      body: BlocBuilder<ClientMaintenanceSupplyCubit, ClientMaintenanceSupplyState>(
        bloc: cubit,
        builder: (context, state) {
          if (state.getCompaniesState == RequestState.loading && cubit.items.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.getCompaniesState == RequestState.error && cubit.items.isEmpty) {
            return Center(child: Text('Error: ${state.msg}'));
          }
          if (state.getCompaniesState == RequestState.done && cubit.items.isEmpty) {
            return Center(child: Text(LocaleKeys.no_companies.tr()));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ${getSubTitle()}').withPadding(horizontal: 16.w, vertical: 15.h),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  color: Theme.of(context).primaryColor,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                    controller: _scrollController,
                    itemCount: cubit.items.length + (state.paginationState == RequestState.loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == cubit.items.length) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return InkWell(
                        onTap: () => push(NamedRoutes.companyDetails, arg: {
                          "type": widget.type,
                          "id": cubit.items[index].id,
                          "title": cubit.items[index].fullname,
                        }),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: context.borderColor),
                            color: context.hoverColor,
                          ),
                          child: Row(
                            children: [
                              CustomImage(
                                cubit.items[index].image,
                                height: 120.h,
                                width: 120.h,
                              ).withPadding(end: 5.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cubit.items[index].fullname, style: context.boldText.copyWith(fontSize: 16)).withPadding(bottom: 10.h),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, size: 20.h, color: context.hintColor),
                                      Text(cubit.items[index].address, style: context.regularText.copyWith(fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).withPadding(bottom: 15.h);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    
    );
  }
}
