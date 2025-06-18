import 'base.dart';

class SliderModel extends Model {
  late String image;
  SliderModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, 'id');
    image = stringFromJson(json, "image");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
      };
}

class SliderDetailsModel extends SliderModel {
  late String link, title, description, creationDate;
  SliderDetailsModel.fromJson([Map<String, dynamic>? json]) : super.fromJson() {
    link = stringFromJson(json, "link");
    title = stringFromJson(json, "title");
    description = stringFromJson(json, "description");
    creationDate = stringFromJson(json, "creation_date");
  }
  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        "link": link,
        "title": title,
        "description": description,
        "creation_date": creationDate,
      };
}
