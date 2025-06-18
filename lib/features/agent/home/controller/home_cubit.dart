import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/utils/enums.dart';
import '../../../../../core/services/server_gate.dart';
import '../../../../models/agent_order.dart';
import '../../../../models/user_model.dart';
import 'home_states.dart';

class AgentHomeCubit extends Cubit<AgentHomeState> {
  AgentHomeCubit() : super(AgentHomeState());

  List<AgentOrderModel> items = [];
  int currentPage = 1;
  bool hasMoreItems = true;

  Future<void> fetchOrders({bool isPagination = false, bool withLoading = true}) async {
    // Prevent duplicate requests or fetching when no more items are available
    if (isPagination && (state.paginationState == RequestState.loading || !hasMoreItems)) return;

    emit(state.copyWith(
      getOrdersState: isPagination && withLoading ? state.getOrdersState : RequestState.loading,
      paginationState: isPagination && withLoading ? RequestState.loading : state.paginationState,
    ));

    try {
      final result = await ServerGate.i.getFromServer(
        url: '${UserModel.i.accountType == UserType.freeAgent ? "free-" : ""}agent/order/offers',
        params: {'page': currentPage},
      );

      if (result.success) {
        final responseData = result.data;

        // Parse data
        final newItems = List<AgentOrderModel>.from(
          responseData['data'].map((x) => AgentOrderModel.fromJson(x)),
        );

        // Update pagination state
        final meta = responseData['meta'];
        currentPage = meta['current_page'] + 1;
        hasMoreItems = meta['current_page'] < meta['last_page'];

        // Add new items
        items.addAll(newItems);
        
        // ترتيب الطلبات تصاعديًا حسب رقم الطلب (الرقم الأصغر أولاً)
        items.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

        emit(state.copyWith(
          getOrdersState: isPagination ? state.getOrdersState : RequestState.done,
          paginationState: isPagination ? RequestState.done : state.paginationState,
          msg: result.msg,
        ));
      } else {
        emit(state.copyWith(
          getOrdersState: isPagination ? state.getOrdersState : RequestState.error,
          paginationState: isPagination ? RequestState.error : state.paginationState,
          msg: result.msg,
          errorType: result.errType,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        getOrdersState: isPagination ? state.getOrdersState : RequestState.error,
        paginationState: isPagination ? RequestState.error : state.paginationState,
        msg: e.toString(),
        errorType: ErrorType.server,
      ));
    }
  }

  changeAvailability() async {
    emit(state.copyWith(activeState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/profile/toggle-availability');
    if (result.success) {
      UserModel.i
        ..isAvailable = result.data?['data']?['is_available'] == true
        ..save();
      emit(state.copyWith(activeState: RequestState.done));
    } else {
      emit(state.copyWith(activeState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> reload() async {
    reset();
    await fetchOrders();
  }

  reset() {
    items.clear();
    currentPage = 1;
    hasMoreItems = true;
  }
}
