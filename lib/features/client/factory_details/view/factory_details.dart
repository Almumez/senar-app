import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_grid.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/factory.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/components/client_show_your_cart_btn.dart';
import '../../../shared/components/product_item.dart';
import '../controller/cubit.dart';
import '../controller/states.dart';

class FactoryDetailsView extends StatefulWidget {
  final FactoryModel data;
  final FactoryServiceType type;
  const FactoryDetailsView({super.key, required this.type, required this.data});

  @override
  State<FactoryDetailsView> createState() => _FactoryDetailsViewState();
}

class _FactoryDetailsViewState extends State<FactoryDetailsView> {
  final cubit = sl<FactoryDetailsCubit>();
  @override
  void initState() {
    super.initState();
    cubit.type = widget.type;
    cubit.getDetails(id: widget.data.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ShowYourCartBtn(),
      appBar: CustomAppbar(title: widget.data.fullname),
      body: BlocBuilder<FactoryDetailsCubit, FactoryDetailsState>(
        bloc: cubit,
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: CustomImage(
                  widget.data.image,
                  height: 145.h,
                  width: 145.h,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(145),
                ).center,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_outlined, size: 16.h),
                        Text(widget.data.address),
                      ],
                    ).withPadding(bottom: 25.h, top: 12.h),
                  ],
                ),
              ),
              Builder(builder: (context) {
                if (state.requestState == RequestState.done && cubit.data!.description.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
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
                  );
                } else {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
              }),
              Builder(builder: (context) {
                if (state.requestState == RequestState.done && cubit.data!.products.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: Text("• ${LocaleKeys.products.tr()}", style: context.mediumText).withPadding(horizontal: 16.w).toStart,
                  );
                } else {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
              }),
              Builder(
                builder: (context) {
                  if (state.requestState == RequestState.done && cubit.data!.products.isNotEmpty) {
                    return CustomSliverGrid(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      itemPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                      itemCount: cubit.data!.products.length,
                      crossCount: 2,
                      itemBuilder: (context, index) => ProductItem(data: cubit.data!.products[index]),
                    );
                  } else if (state.requestState == RequestState.done && cubit.data!.products.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text(LocaleKeys.no_products.tr())),
                    );
                  } else if (state.requestState == RequestState.error) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text(state.msg)),
                    );
                  } else {
                    return SliverToBoxAdapter(
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              )
            ],
          );
        },
      ),
    );
  }
}
