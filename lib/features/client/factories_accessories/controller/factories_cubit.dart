import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../models/factory.dart';
import 'factories_states.dart';
import '../../../../../../core/utils/enums.dart';

class ClientFactoriesAccessoriesCubit extends Cubit<ClientFactoriesAccessoriesState> {
  ClientFactoriesAccessoriesCubit() : super(ClientFactoriesAccessoriesState());

  List<FactoryModel> items = [];
  int currentPage = 1;
  bool hasMoreItems = true;

  FactoryServiceType? type;

  Future<void> fetchCompanies({bool isPagination = false}) async {
    // Prevent duplicate requests or fetching when no more items are available
    if (isPagination && (state.paginationState == RequestState.loading || !hasMoreItems)) return;

    emit(state.copyWith(
      getListState: isPagination ? state.getListState : RequestState.loading,
      paginationState: isPagination ? RequestState.loading : state.paginationState,
    ));

    try {
      final result = await ServerGate.i.getFromServer(
        url: type == FactoryServiceType.factory ? 'client/services/factory' : 'client/services/accessory',
        params: {'page': currentPage},
      );

      if (result.success) {
        final responseData = result.data;

        // Parse data
        final newItems = List<FactoryModel>.from(
          responseData['data'].map((x) => FactoryModel.fromJson(x)),
        );

        // Update pagination state
        final meta = responseData['meta'];
        currentPage = meta['current_page'] + 1;
        hasMoreItems = meta['current_page'] < meta['last_page'];

        // Add new items
        items.addAll(newItems);

        emit(state.copyWith(
          getListState: isPagination ? state.getListState : RequestState.done,
          paginationState: isPagination ? RequestState.done : state.paginationState,
          msg: result.msg,
        ));
      } else {
        emit(state.copyWith(
          getListState: isPagination ? state.getListState : RequestState.error,
          paginationState: isPagination ? RequestState.error : state.paginationState,
          msg: result.msg,
          errorType: result.errType,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        getListState: isPagination ? state.getListState : RequestState.error,
        paginationState: isPagination ? RequestState.error : state.paginationState,
        msg: e.toString(),
        errorType: ErrorType.server,
      ));
    }
  }
}
