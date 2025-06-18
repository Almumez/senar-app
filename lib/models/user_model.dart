import 'dart:convert';

import '../core/utils/enums.dart';
import 'country.dart';

import '../main.dart';
import 'base.dart';

class UserModel extends Model {
  UserModel._();
  static UserModel i = UserModel._();

  late String token, fullname, image, phoneCode, phone, email, userType, locale, license, vehicleForm, healthCertificate, civilStatusNumber, address, wallet;
  late bool isActive, adminApproved, isAvailable, isNotified, completeRegistration;
  late CountryModel country;

  bool get isAuth => token.isNotEmpty;

  UserType get accountType {
    switch (userType) {
      case "client":
        return UserType.client;
      case "free_agent":
        return UserType.freeAgent;
      case "agent":
        return UserType.agent;
      case "product_agent":
        return UserType.productAgent;
      case "technician":
        return UserType.technician;
      default:
        return UserType.client;
    }
  }

  fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    token = stringFromJson(json, "token");
    fullname = stringFromJson(json, "full_name");
    image = stringFromJson(json, "image");
    phoneCode = stringFromJson(json, "phone_code");
    phone = stringFromJson(json, "phone");
    email = stringFromJson(json, "email");
    userType = stringFromJson(json, "user_type");
    isActive = boolFromJson(json, "is_active");
    adminApproved = boolFromJson(json, "admin_approved");
    isAvailable = boolFromJson(json, "is_available");
    isNotified = boolFromJson(json, "is_notified");
    locale = stringFromJson(json, "locale");
    license = stringFromJson(json, "license");
    vehicleForm = stringFromJson(json, "vehicle_form");
    healthCertificate = stringFromJson(json, "health_certificate");
    civilStatusNumber = stringFromJson(json, "civil_status_number");
    address = stringFromJson(json, "address");
    completeRegistration = boolFromJson(json, "complete_registeratin_form");
    wallet = stringFromJson(json, "wallet");
    country = CountryModel.fromJson(json?["country"] ?? {});
  }

  save() {
    Prefs.setString('user', jsonEncode(toJson()));
  }

  clear() {
    Prefs.remove('user');
    fromJson();
  }

  get() {
    String user = Prefs.getString('user') ?? '{}';
    fromJson(jsonDecode(user));
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "token": token,
        "full_name": fullname,
        "image": image,
        "phone_code": phoneCode,
        "phone": phone,
        "email": email,
        "user_type": userType,
        "is_active": isActive,
        "admin_approved": adminApproved,
        "is_available": isAvailable,
        "is_notified": isNotified,
        "locale": locale,
        "license": license,
        "vehicle_form": vehicleForm,
        "health_certificate": healthCertificate,
        "civil_status_number": civilStatusNumber,
        "address": address,
        "complete_registeratin_form": completeRegistration,
        "wallet": wallet,
        "country": country.toJson(),
      };
}
