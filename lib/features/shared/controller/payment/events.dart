class PaymentInfoEvent {}

class StartPaymentInfoEvent extends PaymentInfoEvent {
  Map<String, dynamic> get data => {};

  StartPaymentInfoEvent();
}