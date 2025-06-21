import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  CustomPosition? position;
  Completer<CustomPosition>? _locationCompleter;

  Future<CustomPosition> getCurrentLocation() async {
    if (_locationCompleter != null && !_locationCompleter!.isCompleted) {
      return _locationCompleter!.future;
    }
    _locationCompleter = Completer<CustomPosition>();
    
    // First check if location service is enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationCompleter?.complete(
        CustomPosition(
          status: LocationPermission.denied,
          msg: "Location services are disabled. Please enable location services in settings.",
          success: false,
        ),
      );
      _locationCompleter = null;
      return position = CustomPosition(
        status: LocationPermission.denied,
        msg: "Location services are disabled. Please enable location services in settings.",
        success: false,
      );
    }
    
    // Then check for permission
    LocationPermission status = await Geolocator.checkPermission();
    
    // If permission is denied, request it
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }
    
    if (status == LocationPermission.whileInUse || status == LocationPermission.always) {
      try {
        // Handle position retrieval with error handling
        Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
        
        position = CustomPosition(
          status: status,
          msg: "",
          success: true,
          position: currentPosition,
        );
        
        if (position?.position != null) {
          final address = await getAddressFromLatLng(position: position!.position!);
          position = position?.copyWith(address: address);
        }
        
        _locationCompleter?.complete(position);
        _locationCompleter = null;
        return position!;
      } catch (e) {
        log("Error getting current position: $e");
        _locationCompleter?.complete(
          CustomPosition(
            status: status,
            msg: "Could not get current position: ${e.toString()}",
            success: false,
          ),
        );
        _locationCompleter = null;
        return CustomPosition(
          status: status,
          msg: "Could not get current position: ${e.toString()}",
          success: false,
        );
      }
    } else if (status == LocationPermission.deniedForever) {
      // Handle permanent denial
      String message = Platform.isIOS
          ? "Location permission is permanently denied. Please enable it in your device settings."
          : "Location permission is permanently denied.";
      
      _locationCompleter?.complete(CustomPosition(status: status, msg: message, success: false));
      _locationCompleter = null;
      return CustomPosition(status: status, msg: message, success: false);
    } else {
      position = CustomPosition(status: status, msg: "Location permission is $status", success: false);
      _locationCompleter?.complete(position);
      _locationCompleter = null;
      return position!;
    }
  }

  Future<String> getAddressFromLatLng({Position? position, LatLng? latLng}) async {
    try {
      double lat, lng;
      if (position == null && latLng == null) {
        throw "you position or latLng mustn't be null";
      } else {
        lat = position?.latitude ?? latLng!.latitude;
        lng = position?.longitude ?? latLng!.longitude;
      }
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        return "${placemark.street}, ${placemark.locality}, ${placemark.country}";
      } else {
        return "";
      }
    } catch (e) {
      log("$e");
      return "";
    }
  }
}

class CustomPosition {
  final Position? position;
  final String msg;
  final bool success;
  final LocationPermission status;
  final String? address;

  CustomPosition({
    this.address,
    required this.status,
    this.position,
    required this.msg,
    required this.success,
  });

  CustomPosition copyWith({
    Position? position,
    String? msg,
    bool? success,
    LocationPermission? status,
    String? address,
  }) {
    return CustomPosition(
      address: address ?? this.address,
      position: position ?? this.position,
      msg: msg ?? this.msg,
      success: success ?? this.success,
      status: status ?? this.status,
    );
  }
}
