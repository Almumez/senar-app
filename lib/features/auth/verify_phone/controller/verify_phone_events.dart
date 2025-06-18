// import 'dart:io';

// import 'package:flutter/material.dart';

// import '../../../../core/services/local_notifications_service.dart';
// import '../view/verify_phone_view.dart';

// class VerifyPhoneEvent {}

// class StartVerifyPhoneEvent extends VerifyPhoneEvent {
  // final VerifyType type;
  // String phone;
  // final code = TextEditingController();

  // String get url => type == VerifyType.register ? 'client/verify' : 'client/forgot-password/check-code';
  // Future<Map<String, dynamic>> get body async => {
  //       "email": phone,
  //       "code": code.text,
  //       "type": Platform.isAndroid ? "android" : "ios",
  //       "device_token": await GlobalNotification.getFcmToken(),
  //     };
//   StartVerifyPhoneEvent(this.type, this.phone);
// }

// class StartResendCodeEvent extends VerifyPhoneEvent {
  // final VerifyType type;
  // final String email;

  // String get url => type == VerifyType.register ? 'client/send-code' : 'client/forgot-password';
  // Map<String, dynamic> get body => {"email": email};
//   StartResendCodeEvent(this.type, this.email);
// }

// class StartEditPhoneEvent extends VerifyPhoneEvent {
//   final VerifyType type;
//   final String email;

//   String get url => type == VerifyType.register ? 'client/send-code' : 'client/forgot-password';
//   Map<String, dynamic> get body => {"email": email};
//   StartEditPhoneEvent(this.type, this.email);
// }

// class StartEditEmailEvent extends VerifyPhoneEvent {
//   final String oldEmail;
//   final String newEmail;
//   Map<String, dynamic> get body => {"email": newEmail, 'old_email': oldEmail};

//   StartEditEmailEvent(this.oldEmail, this.newEmail);
// }
