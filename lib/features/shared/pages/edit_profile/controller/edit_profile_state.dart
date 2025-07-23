import '../../../../../core/utils/enums.dart';

class EditProfileState {
  final RequestState requestState, passwordState, phoneState, verifyState, profileDataState;
  final String msg;
  final ErrorType errorType;
  final String genderValue;

  EditProfileState({
    this.requestState = RequestState.initial,
    this.passwordState = RequestState.initial,
    this.phoneState = RequestState.initial,
    this.verifyState = RequestState.initial,
    this.profileDataState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.genderValue = 'male',
  });

  EditProfileState copyWith({
    RequestState? requestState,
    RequestState? passwordState,
    RequestState? phoneState,
    RequestState? verifyState,
    RequestState? profileDataState,
    String? msg,
    ErrorType? errorType,
    String? genderValue,
  }) =>
      EditProfileState(
        requestState: requestState ?? this.requestState,
        passwordState: passwordState ?? this.passwordState,
        phoneState: phoneState ?? this.phoneState,
        verifyState: verifyState ?? this.verifyState,
        profileDataState: profileDataState ?? this.profileDataState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        genderValue: genderValue ?? this.genderValue,
      );
}
