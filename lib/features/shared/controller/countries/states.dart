import '../../../../core/utils/enums.dart';

class CountriesState {
  final RequestState countriesState;
  final String msg;
  final ErrorType errorType;
  final bool openSheet;

  CountriesState({
    this.countriesState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.openSheet = false,
  });

  CountriesState copyWith({
    RequestState? countriesState,
    String? msg,
    ErrorType? errorType,
    bool? openSheet,
  }) =>
      CountriesState(
        countriesState: countriesState ?? this.countriesState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        openSheet: openSheet ?? this.openSheet,
      );
}
