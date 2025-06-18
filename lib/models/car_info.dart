import 'base.dart';

class CarInfoModel extends Model {
  late final String license, vehicleForm, healthCertificate;

  CarInfoModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    license = stringFromJson(json, "license");
    vehicleForm = stringFromJson(json, "vehicle_form");
    healthCertificate = stringFromJson(json, "health_certificate");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "license": license,
        "vehicle_form": vehicleForm,
        "health_certificate": healthCertificate,
      };
}
