import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/company.dart';

import '../../../../core/services/server_gate.dart';
import 'states.dart';
import '../../../../../../core/utils/enums.dart';

class ClientMaintenanceSupplyCubit extends Cubit<ClientMaintenanceSupplyState> {
  ClientMaintenanceSupplyCubit() : super(ClientMaintenanceSupplyState());

  List<CompanyModel> items = [];
  int currentPage = 1;
  bool hasMoreItems = true;

  CompanyServiceType? type;

  Future<void> fetchCompanies({bool isPagination = false}) async {
    // Prevent duplicate requests or fetching when no more items are available
    if (isPagination && (state.paginationState == RequestState.loading || !hasMoreItems)) return;

    emit(state.copyWith(
      getCompaniesState: isPagination ? state.getCompaniesState : RequestState.loading,
      paginationState: isPagination ? RequestState.loading : state.paginationState,
    ));

    try {
      final result = await ServerGate.i.getFromServer(
        url: type == CompanyServiceType.supply ? 'client/services/supply' : 'client/services/maintenance',
        params: {'page': currentPage},
      );

      if (result.success) {
        final responseData = result.data;

        // Parse data
        final newItems = List<CompanyModel>.from(
          responseData['data'].map((x) => CompanyModel.fromJson(x)),
        );

        // Update pagination state
        final meta = responseData['meta'];
        currentPage = meta['current_page'] + 1;
        hasMoreItems = meta['current_page'] < meta['last_page'];

        // Add new items
        items.addAll(newItems);

        emit(state.copyWith(
          getCompaniesState: isPagination ? state.getCompaniesState : RequestState.done,
          paginationState: isPagination ? RequestState.done : state.paginationState,
          msg: result.msg,
        ));
      } else {
        emit(state.copyWith(
          getCompaniesState: isPagination ? state.getCompaniesState : RequestState.error,
          paginationState: isPagination ? RequestState.error : state.paginationState,
          msg: result.msg,
          errorType: result.errType,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        getCompaniesState: isPagination ? state.getCompaniesState : RequestState.error,
        paginationState: isPagination ? RequestState.error : state.paginationState,
        msg: e.toString(),
        errorType: ErrorType.server,
      ));
    }
  }
}
