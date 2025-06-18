import '../../../../../../core/utils/enums.dart';

class ProductDetailsState {
  final RequestState requestState;
  final RequestState updateCount;
  final RequestState addToCartState;

  final String msg;
  final ErrorType errorType;

  ProductDetailsState({
    this.requestState = RequestState.initial,
    this.updateCount = RequestState.initial,
    this.addToCartState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  ProductDetailsState copyWith({
    RequestState? requestState,
    RequestState? updateCount,
    RequestState? addToCartState,
    String? msg,
    ErrorType? errorType,
  }) =>
      ProductDetailsState(
        requestState: requestState ?? this.requestState,
        updateCount: updateCount ?? this.updateCount,
        addToCartState: addToCartState ?? this.addToCartState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
