import 'base.dart';

class StaticModel extends Model {
  late final String title, content, image;

  StaticModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    title = stringFromJson(json, "title");
    content = stringFromJson(json, "content");
    image = stringFromJson(json, "image");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "image": image,
      };
}
