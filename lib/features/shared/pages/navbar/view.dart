import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../client/addresses/controller/cubit.dart';
import '../../../client/home/controller/cubit.dart';
import '../../../../models/user_model.dart';

import '../../../../core/services/service_locator.dart';
import 'components/custom_bottom_navigation.dart';
import 'cubit/navbar_cubit.dart';

class NavbarView extends StatefulWidget {
  final int? index;

  const NavbarView({super.key, this.index});

  @override
  State<NavbarView> createState() => _NavbarViewState();
}

class _NavbarViewState extends State<NavbarView> with SingleTickerProviderStateMixin {
  late final cubit = sl<NavbarCubit>()..initTabBar(this);

  @override
  void initState() {
    if (UserModel.i.accountType.isClient) {
      sl.resetLazySingleton<ClientHomeCubit>();
      sl.resetLazySingleton<AddressesCubit>();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomNavigationBarItems(),
      body: BlocBuilder<NavbarCubit, int>(
        bloc: cubit,
        builder: (context, state) {
          return TabBarView(
            controller: cubit.tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: cubit.getChildren,
          );
        },
      ),
    );
  }
}
