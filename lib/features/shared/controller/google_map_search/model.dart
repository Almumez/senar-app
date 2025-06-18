import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapSearchModel {
  late final LatLng latLng;
  late final String name;

  GoogleMapSearchModel.fromJson(Map<String, dynamic> json) {
    latLng = LatLng(json["geometry"]['coordinates'][1], json["geometry"]['coordinates'][0]);
    name = json['properties']['name'];
  }
}
