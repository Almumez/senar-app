import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../cart/controller/cubit.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/appbar.dart';
import '../controller/factories_cubit.dart';
import '../controller/factories_states.dart';

class ClientFactoryAccessoryView extends StatefulWidget {
  final FactoryServiceType type;
  const ClientFactoryAccessoryView({super.key, required this.type});

  @override
  State<ClientFactoryAccessoryView> createState() => _ClientFactoryAccessoryViewState();
}

class _ClientFactoryAccessoryViewState extends State<ClientFactoryAccessoryView> {
  final cubit = sl<ClientFactoriesAccessoriesCubit>();
  final _scrollController = ScrollController();
  final cartCubit = sl<CartCubit>()..getCart();
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
      case FactoryServiceType.factory:
        return LocaleKeys.industrial_gas_factories.tr();
      case FactoryServiceType.accessory:
        return LocaleKeys.gas_cylinder_supplies.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: getTitle()),
      body: PullToRefresh(
        onRefresh: _refresh,
        child: BlocBuilder<ClientFactoriesAccessoriesCubit, ClientFactoriesAccessoriesState>(
          bloc: cubit,
          builder: (context, state) {
            if (state.getListState == RequestState.loading && cubit.items.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            if (state.getListState == RequestState.error && cubit.items.isEmpty) {
              return Center(child: Text('Error: ${state.msg}'));
            }
            if (state.getListState == RequestState.done && cubit.items.isEmpty) {
              return Center(child: Text(LocaleKeys.no_companies.tr()));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ${LocaleKeys.all_merchants.tr()}').withPadding(horizontal: 16.w, vertical: 15.h),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                    controller: _scrollController,
                    itemCount: cubit.items.length + (state.paginationState == RequestState.loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == cubit.items.length) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return InkWell(
                        onTap: () => push(NamedRoutes.factoryDetails, arg: {
                          "type": widget.type,
                          "data": cubit.items[index],
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
                                borderRadius: BorderRadius.circular(12.r),
                                backgroundColor: context.primaryColorLight,
                                fit: BoxFit.cover,
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
              ],
            );
          },
        ),
      ),
    );
  }
}
