import 'base.dart';

class NotificationModel extends Model {
  late final String title, body;
  NotificationModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    title = stringFromJson(json, "title");
    body = stringFromJson(json, "body");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "body": body,
      };
}
