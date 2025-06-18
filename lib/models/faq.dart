import 'base.dart';

class FaqModel extends Model {
  late final String question, answer;

  FaqModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    question = stringFromJson(json, "question");
    answer = stringFromJson(json, "answer");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "answer": answer,
      };
}
