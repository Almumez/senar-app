import 'base.dart';

class SettingsModel extends Model {
  late ClosingServiceModel closingService;
  late bool isOpened;
  late bool isNotificationTimeStart;
  late MaintenanceModeModel maintenanceMode;
  late bool isMaintenance;
  late String maintenanceMessage;

  SettingsModel.fromJson([Map<String, dynamic>? json]) {
    closingService = ClosingServiceModel.fromJson(json?["closing_service"]);
    isOpened = boolFromJson(json, "is_opened", defaultValue: true);
    isNotificationTimeStart = boolFromJson(json, "isNotificationTimeStart", defaultValue: false);
    maintenanceMode = MaintenanceModeModel.fromJson(json?["maintenance_mode"]);
    // دعم الشكلين: maintenance_mode وحقول is_maintenance/maintenance_message كنسخة احتياطية
    isMaintenance = boolFromJson(json, "is_maintenance", defaultValue: maintenanceMode.isEnabled);
    maintenanceMessage = stringFromJson(json, "maintenance_message", defaultValue: maintenanceMode.message);
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

class MaintenanceModeModel extends Model {
  late bool isEnabled;
  late String message;

  MaintenanceModeModel.fromJson([Map<String, dynamic>? json]) {
    isEnabled = boolFromJson(json, "is_enabled", defaultValue: false);
    message = stringFromJson(json, "message", defaultValue: "");
  }
}