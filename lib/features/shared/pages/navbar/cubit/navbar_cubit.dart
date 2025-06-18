import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/service_locator.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../models/user_model.dart';
import '../../../../agent/home/view/home_view.dart';
import '../../../../agent/orders/view/orders_view.dart';
import '../../../../auth/logout/logout_cubit.dart';
import '../../../../client/home/view/home_view.dart';
import '../../../../client/orders/views/orders.dart';
import '../../../../product_agent/home/view/home_view.dart';
import '../../../../product_agent/orders/view/orders_view.dart';
import '../../../../technician/home/view/home_view.dart';
import '../../../../technician/orders/views/orders_view.dart';
import '../../notifications/view/notifications_view.dart';
import '../../profile/view.dart';

class NavbarCubit extends Cubit<int> {
  NavbarCubit() : super(0);

  final logoutCubit = sl<LogoutCubit>();

  TabController? tabController;

  initTabBar(TickerProvider vsync) {
    tabController ??= TabController(length: 4, vsync: vsync, initialIndex: 0);
  }

  changeTap(int index) {
    tabController?.animateTo(index);
    emit(index);
  }

  List<Widget> get getChildren {
    switch (UserModel.i.accountType) {
      case UserType.client:
        return _buildClientChildren;
      case UserType.freeAgent:
        return _buildFreeAgentChildren;
      case UserType.agent:
        return _buildAgentChildren;
      case UserType.productAgent:
        return _buildProductAgentChildren;
      case UserType.technician:
        return _buildTechnicianAgentChildren;
    }
  }

  List<Widget> get _buildClientChildren {
    return [
      HomeClientView(),
      ClientOrdersView(),
      NotificationsView(),
      ProfileView(),
    ];
  }

  List<Widget> get _buildFreeAgentChildren {
    return [
      FreeAgentHomeView(),
      AgentOrdersView(),
      NotificationsView(),
      ProfileView(),
    ];
  }

  List<Widget> get _buildTechnicianAgentChildren {
    return [
      TechnicianHomeView(),
      TechnicianOrdersView(),
      NotificationsView(),
      ProfileView(),
    ];
  }

  List<Widget> get _buildProductAgentChildren {
    return [
      ProductAgentHomeView(),
      ProductAgentOrdersView(),
      NotificationsView(),
      ProfileView(),
    ];
  }

  List<Widget> get _buildAgentChildren {
    return [
      FreeAgentHomeView(),
      AgentOrdersView(),
      NotificationsView(),
      ProfileView(),
    ];
  }
}
