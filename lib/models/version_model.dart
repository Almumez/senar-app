import 'base.dart';

class VersionModel extends Model {
  late String mobileVersion;

  VersionModel();

  VersionModel.fromJson(Map<String, dynamic> json) {
    mobileVersion = stringFromJson(json, "mobile_version");
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "mobile_version": mobileVersion,
    };
  }
} 