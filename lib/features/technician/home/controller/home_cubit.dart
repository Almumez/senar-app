import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/user_model.dart';

import '../../../../../../../core/utils/enums.dart';
import '../../../../../core/services/server_gate.dart';

import '../../../../models/technician_order.dart';
import 'home_states.dart';

class TechnicianHomeCubit extends Cubit<TechnicianHomeState> {
  TechnicianHomeCubit() : super(TechnicianHomeState());

  List<TechnicianOrderModel> items = [];
  int currentPage = 1;
  bool hasMoreItems = true;

  Future<void> fetchOrders({bool isPagination = false}) async {
    // Prevent duplicate requests or fetching when no more items are available
    if (isPagination && (state.paginationState == RequestState.loading || !hasMoreItems)) return;

    emit(state.copyWith(
      getOrdersState: isPagination ? state.getOrdersState : RequestState.loading,
      paginationState: isPagination ? RequestState.loading : state.paginationState,
    ));

    try {
      final result = await ServerGate.i.getFromServer(
        url: 'technician/order/offers',
        params: {'page': currentPage},
      );

      if (result.success) {
        final responseData = result.data;

        // Parse data
        final newItems = List<TechnicianOrderModel>.from(
          responseData['data'].map((x) => TechnicianOrderModel.fromJson(x)),
        );

        // Update pagination state
        final meta = responseData['meta'];
        currentPage = meta['current_page'] + 1;
        hasMoreItems = meta['current_page'] < meta['last_page'];

        // Add new items
        items.addAll(newItems);

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

  changeAvilabilty() async {
    emit(state.copyWith(acttiveState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/profile/toggle-availability');
    if (result.success) {
      UserModel.i
        ..isAvailable = result.data?['data']?['is_available'] == true
        ..save();
      emit(state.copyWith(acttiveState: RequestState.done));
    } else {
      emit(state.copyWith(acttiveState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> reload() async {
    items.clear();
    currentPage = 1;
    await fetchOrders();
  }
}
