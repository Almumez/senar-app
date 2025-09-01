import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/widgets/flash_helper.dart';

import '../../../../../core/services/server_gate.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../models/country.dart';
import '../../../../../models/user_model.dart';
import 'contact_us_state.dart';

class ContactUsCubit extends Cubit<ContactUsState> {
  ContactUsCubit() : super(ContactUsState());

  final phone = TextEditingController(text: UserModel.i.phone);
  final name = TextEditingController(text: UserModel.i.fullname);
  final msg = TextEditingController();

  CountryModel? country = UserModel.i.country;

  String? contactsPhone;

  Map<String, dynamic> get body => {
        "full_name": name.text,
        "phone_code": country?.phoneCode,
        "phone": phone.text,
        "content": msg.text,
      };

  Future<void> send() async {
    emit(state.copyWith(sendContactsState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/page/contact-us', body: body);
    if (result.success) {
      FlashHelper.showToast(result.msg, type: MessageType.success);
      msg.clear();
      emit(state.copyWith(sendContactsState: RequestState.done, msg: result.msg));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(sendContactsState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> getContacts() async {
    emit(state.copyWith(getContactsState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: 'general/whatsapp');
    if (result.success) {
      contactsPhone = "+${result.data['data']['whatsapp_phone_code']}-${result.data['data']['whatsapp_phone']}";
      emit(state.copyWith(getContactsState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(getContactsState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
