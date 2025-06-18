// To parse this JSON data, do
//
//     final paymentDataModel = paymentDataModelFromJson(jsonString);

import 'dart:convert';

import 'package:myfatoorah_flutter/MFEnums.dart';

PaymentInfoModel paymentInfoModelFromJson(String str) => PaymentInfoModel.fromJson(json.decode(str));

String paymentInfoModelToJson(PaymentInfoModel data) => json.encode(data.toJson());

class PaymentInfoModel {
  String mfEnvironment;
  String mfLiveToken;
  String mfTestToken;

  String get country => mfEnvironment == 'test' ? MFCountry.KUWAIT : MFCountry.SAUDIARABIA;
  String get currencyIso => mfEnvironment == 'test' ? MFCurrencyISO.KUWAIT_KWD : MFCurrencyISO.SAUDIARABIA_SAR;
  String get mfEnv => mfEnvironment == 'test' ? MFEnvironment.TEST : MFEnvironment.LIVE;

  String get mAPIKey => mfEnvironment == 'test' ? mfTestToken : mfLiveToken;
  PaymentInfoModel({
    required this.mfEnvironment,
    required this.mfLiveToken,
    required this.mfTestToken,
  });

  factory PaymentInfoModel.fromJson(Map<String, dynamic> json) => PaymentInfoModel(
        mfEnvironment: json["mf_environment"],
        mfLiveToken: json["mf_live_token"],
        mfTestToken: json["mf_test_token"],
      );

  Map<String, dynamic> toJson() => {
        "mf_environment": mfEnvironment,
        "mf_live_token": mfLiveToken,
        "mf_test_token": mfTestToken,
      };
}
