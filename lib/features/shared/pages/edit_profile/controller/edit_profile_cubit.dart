import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/services/server_gate.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../models/country.dart';
import '../../../../../models/user_model.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit() : super(EditProfileState());

  final phone = TextEditingController(text: UserModel.i.phone);
  final email = TextEditingController(text: UserModel.i.email);

  final oldPassword = TextEditingController();
  final code = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final name = TextEditingController(text: UserModel.i.fullname);
  CountryModel? country = UserModel.i.country;
  String? image = UserModel.i.image;
  XFile? pickedImage;

  bool get canUpdate => name.text != UserModel.i.fullname || image != UserModel.i.image || email.text != UserModel.i.email;
  bool get canUpdatePhone => phone.text != UserModel.i.phone || country?.phoneCode != UserModel.i.phoneCode;

  passwordsClean() {
    oldPassword.clear();
    password.clear();
    confirmPassword.clear();
  }

  Map<String, dynamic> get body => {
        "full_name": name.text,
        "email": email.text,
        if (pickedImage != null) "image": image,
      };

  Future<void> updateProfile() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/profile', body: body);
    if (result.success) {
      result.data['data']['token'] = UserModel.i.token;
      UserModel.i.fromJson(result.data['data']);
      UserModel.i.save();
      emit(state.copyWith(requestState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> changePassword() async {
    emit(state.copyWith(passwordState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/profile/change-password', body: {
      "old_password": oldPassword.text,
      "password": password.text,
      "password_confirmation": confirmPassword.text,
    });
    if (result.success) {
      passwordsClean();
      emit(state.copyWith(passwordState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(passwordState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> updatePhone() async {
    emit(state.copyWith(phoneState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'general/profile/send-otp',
      body: {
        "phone_code": country?.phoneCode,
        "phone": phone.text,
      },
    );
    if (result.success) {
      emit(state.copyWith(phoneState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(phoneState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> verifyPhone({required String phoneCode, required String phone, required String code}) async {
    emit(state.copyWith(verifyState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'general/profile/verify-phone',
      body: {
        "otp": code,
        "phone_code": phoneCode,
        "phone": phone,
      },
    );
    if (result.success) {
      result.data['data']['token'] = UserModel.i.token;
      UserModel.i.fromJson(result.data['data']);
      UserModel.i.save();
      this.code.clear();
      emit(state.copyWith(verifyState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(verifyState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
