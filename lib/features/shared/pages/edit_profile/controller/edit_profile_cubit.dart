import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/services/server_gate.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../models/country.dart';
import '../../../../../models/user_model.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit() : super(EditProfileState()) {
    // Cargar los datos del perfil al iniciar
    getProfileData();
  }

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
  String gender = UserModel.i.gender;

  bool get canUpdate => name.text != UserModel.i.fullname || image != UserModel.i.image || email.text != UserModel.i.email || gender != UserModel.i.gender;
  bool get canUpdatePhone => phone.text != UserModel.i.phone || country?.phoneCode != UserModel.i.phoneCode;

  void setGender(String value) {
    gender = value;
    emit(state.copyWith(genderValue: value));
  }

  passwordsClean() {
    oldPassword.clear();
    password.clear();
    confirmPassword.clear();
  }

  Map<String, dynamic> get body => {
        "full_name": name.text,
        "email": email.text,
        "gender": gender,
        if (pickedImage != null) "image": image,
      };

  Future<void> getProfileData() async {
    emit(state.copyWith(profileDataState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: 'general/profile');
    if (result.success) {
      if (result.data['data'] != null) {
        // Guardar el token actual antes de actualizar
        String currentToken = UserModel.i.token;
        
        // Actualizar el modelo de usuario con los datos recibidos
        UserModel.i.fromJson(result.data['data']);
        
        // Restaurar el token ya que la API no lo devuelve
        UserModel.i.token = currentToken;
        
        // Actualizar los controladores con los nuevos datos
        name.text = UserModel.i.fullname;
        phone.text = UserModel.i.phone;
        email.text = UserModel.i.email;
        gender = UserModel.i.gender;
        image = UserModel.i.image;
        country = UserModel.i.country;
        
        // Guardar los datos actualizados
        UserModel.i.save();
      }
      emit(state.copyWith(profileDataState: RequestState.done));
    } else {
      emit(state.copyWith(profileDataState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> updateProfile() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.putToServer(
      url: 'general/profile', 
      body: body
    );
    if (result.success) {
      // Guardar el token actual antes de actualizar
      String currentToken = UserModel.i.token;
      
      // Actualizar el modelo de usuario con los datos recibidos
      if (result.data['data'] != null) {
        UserModel.i.fromJson(result.data['data']);
      } else {
        // Si no devuelve datos, actualizar manualmente los campos
        UserModel.i.fullname = name.text;
        UserModel.i.gender = gender;
      }
      
      // Restaurar el token
      UserModel.i.token = currentToken;
      
      // Guardar los cambios
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
