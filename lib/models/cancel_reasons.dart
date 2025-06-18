import 'base.dart';

class CancelReasonsModel extends Model {
  late String name;

  CancelReasonsModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    name = stringFromJson(json, "title");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": name,
      };
}
