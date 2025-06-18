import '../../../../../../core/utils/enums.dart';

class CartState {
  final RequestState requestState;
  final RequestState updateCount;
  final RequestState couponState;
  final RequestState createOrderState;
  final String msg;
  final ErrorType errorType;
  final String productId;
  final bool hasCoupon;

  CartState(
      {this.requestState = RequestState.initial,
      this.updateCount = RequestState.initial,
      this.couponState = RequestState.initial,
      this.createOrderState = RequestState.initial,
      this.msg = '',
      this.errorType = ErrorType.none,
      this.productId = '',
      this.hasCoupon = false});

  CartState copyWith(
          {RequestState? requestState,
          RequestState? updateCount,
          RequestState? couponState,
          RequestState? createOrderState,
          String? msg,
          ErrorType? errorType,
          String? productId,
          bool? hasCoupon}) =>
      CartState(
          requestState: requestState ?? this.requestState,
          updateCount: updateCount ?? this.updateCount,
          couponState: couponState ?? this.couponState,
          createOrderState: createOrderState ?? this.createOrderState,
          msg: msg ?? this.msg,
          errorType: errorType ?? this.errorType,
          productId: productId ?? this.productId,
          hasCoupon: hasCoupon ?? this.hasCoupon);
}
