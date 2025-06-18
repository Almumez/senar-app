import '../../../../models/address.dart';

import '../../../../core/utils/enums.dart';

class AddressesState {
  final RequestState addStateState;
  final RequestState editStateState;
  final RequestState deleteStateState;
  final RequestState getStateState;
  final RequestState setDefaultStateState;
  final RequestState checkZoneState;
  final String msg;
  final ErrorType errorType;

  AddressesState({
    this.addStateState = RequestState.initial,
    this.editStateState = RequestState.initial,
    this.deleteStateState = RequestState.initial,
    this.getStateState = RequestState.initial,
    this.setDefaultStateState = RequestState.initial,
    this.checkZoneState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  AddressesState copyWith({
    RequestState? addStateState,
    RequestState? editStateState,
    RequestState? deleteStateState,
    RequestState? getStateState,
    RequestState? setDefaultStateState,
    RequestState? checkZoneState,
    String? msg,
    ErrorType? errorType,
    AddressModel? address,
  }) =>
      AddressesState(
        addStateState: addStateState ?? this.addStateState,
        editStateState: editStateState ?? this.editStateState,
        deleteStateState: deleteStateState ?? this.deleteStateState,
        getStateState: getStateState ?? this.getStateState,
        setDefaultStateState: setDefaultStateState ?? this.setDefaultStateState,
        checkZoneState: checkZoneState ?? this.checkZoneState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
