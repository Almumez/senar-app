import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/utils/enums.dart';
import '../../../../../core/services/server_gate.dart';
import '../../../../../models/client_order.dart';
import 'states.dart';

class ClientOrdersCubit extends Cubit<ClientOrdersCState> {
  ClientOrdersCubit() : super(ClientOrdersCState());

  List<ClientOrderModel> items = [];
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
        url: 'client/order',
        params: {'page': currentPage},
      );

      if (result.success) {
        final responseData = result.data;

        // Parse data
        final newItems = List<ClientOrderModel>.from(
          responseData['data'].map((x) => ClientOrderModel.fromJson(x)),
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

  reload() {
    reset();
    fetchOrders();
  }

  reset() {
    items.clear();
    currentPage = 1;
    hasMoreItems = true;
  }
}
