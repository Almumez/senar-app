import 'address.dart';
import 'base.dart';
import 'slider.dart';

class ClientHomeModel extends Model {
  late List<SliderModel> sliders;
  late List<AddressModel> addresses;

  ClientHomeModel.fromJson([Map<String, dynamic>? json]) {
    sliders = listFromJson<SliderModel>(json, "sliders", callback: (e) => SliderModel.fromJson(e));
    addresses = listFromJson<AddressModel>(json, "addresses", callback: (e) => AddressModel.fromJson(e));
  }

  @override
  Map<String, dynamic> toJson() => {
        "sliders": sliders.map((e) => e.toJson()).toList(),
        "addresses": addresses.map((e) => e.toJson()).toList(),
      };
}
