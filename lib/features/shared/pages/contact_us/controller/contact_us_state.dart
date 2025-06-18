import '../../../../../core/utils/enums.dart';

class ContactUsState {
  final RequestState sendContactsState;
  final RequestState getContactsState;
  final String msg;
  final ErrorType errorType;

  ContactUsState({
    this.sendContactsState = RequestState.initial,
    this.msg = '',
    this.getContactsState = RequestState.initial,
    this.errorType = ErrorType.none,
  });

  ContactUsState copyWith({
    RequestState? sendContactsState,
    String? msg,
    ErrorType? errorType,
    RequestState? getContactsState,
  }) =>
      ContactUsState(
        sendContactsState: sendContactsState ?? this.sendContactsState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        getContactsState: getContactsState ?? this.getContactsState,
      );
}
