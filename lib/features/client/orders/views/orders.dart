import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/user_model.dart';
import '../../../shared/components/appbar.dart';
import '../components/client_order_item.dart';
import '../controller/orders/cubit.dart';
import '../controller/orders/states.dart';

class ClientOrdersView extends StatefulWidget {
  const ClientOrdersView({super.key});

  @override
  State<ClientOrdersView> createState() => _ClientOrdersViewState();
}

class _ClientOrdersViewState extends State<ClientOrdersView> {
  final cubit = sl<ClientOrdersCubit>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (UserModel.i.isAuth) {
      cubit.fetchOrders();
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
          cubit.fetchOrders(isPagination: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await cubit.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.orders.tr(), withBack: false),
      body: !UserModel.i.isAuth 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: AppBtn(
                    title: LocaleKeys.login.tr(),
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                    radius: 30.r,
                    onPressed: () => push(NamedRoutes.login),
                  ),
                ),
              ],
            ),
          )
          
        : BlocBuilder<ClientOrdersCubit, ClientOrdersCState>(
            bloc: cubit,
            builder: (context, state) {
              if (state.getOrdersState == RequestState.loading && cubit.items.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (state.getOrdersState == RequestState.error && cubit.items.isEmpty) {
                return Center(child: CustomErrorWidget(title: state.msg));
              }
              if (state.getOrdersState == RequestState.done && cubit.items.isEmpty) {
                return Center(child: Text(LocaleKeys.no_orders.tr(), style: context.mediumText.copyWith(fontSize: 14)));
              }
              return RefreshIndicator(
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
                    return ClientOrderCard(data: cubit.items[index], onBack: () => cubit.reload()).withPadding(bottom: 20.h);
                  },
                ),
              );
            },
          ),
    );
  }
}
