import 'base.dart';

class SettingsModel extends Model {
  late ClosingServiceModel closingService;

  SettingsModel.fromJson([Map<String, dynamic>? json]) {
    closingService = ClosingServiceModel.fromJson(json?["closing_service"]);
  }
}

class ClosingServiceModel extends Model {
  late String closingTime;
  late String openingTime;
  late int cancellationTime;
  late String notificationStartTime;

  ClosingServiceModel.fromJson([Map<String, dynamic>? json]) {
    closingTime = stringFromJson(json, "closing_time");
    openingTime = stringFromJson(json, "opening_time");
    cancellationTime = intFromJson(json, "cancellation_time");
    notificationStartTime = stringFromJson(json, "notification_start_time");
  }
} 