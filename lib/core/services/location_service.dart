import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
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
    
    // أولاً، تحقق مما إذا كانت خدمات الموقع متاحة
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // خدمات الموقع غير متاحة، حاول تفعيلها
      try {
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) {
          position = CustomPosition(
            status: LocationPermission.denied,
            msg: "Location services are disabled. Please enable them in settings.",
            success: false,
          );
          _locationCompleter?.complete(position);
          _locationCompleter = null;
          return position!;
        }
      } catch (e) {
        position = CustomPosition(
          status: LocationPermission.denied,
          msg: "Failed to open location settings: $e",
          success: false,
        );
        _locationCompleter?.complete(position);
        _locationCompleter = null;
        return position!;
      }
    }
    
    // تحقق من حالة الإذن الحالية
    LocationPermission permission = await Geolocator.checkPermission();
    
    // إذا كان الإذن مرفوضًا بشكل دائم، أعرض رسالة مناسبة
    if (permission == LocationPermission.deniedForever) {
      String message = Platform.isIOS 
          ? "Location permission is denied forever. Please enable it in your device settings."
          : "Location permission is permanently denied. Please enable it in app settings.";
          
      position = CustomPosition(
        status: permission,
        msg: message,
        success: false,
      );
      _locationCompleter?.complete(position);
      _locationCompleter = null;
      return position!;
    }
    
    // إذا كان الإذن مرفوضًا، اطلب الإذن
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      
      // تحقق من نتيجة طلب الإذن
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        String message = permission == LocationPermission.deniedForever
            ? "Location permission is denied forever. Please enable it in settings."
            : "Location permission is denied.";
            
        position = CustomPosition(
          status: permission,
          msg: message,
          success: false,
        );
        _locationCompleter?.complete(position);
        _locationCompleter = null;
        return position!;
      }
    }
    
    // إذا تم منح الإذن، احصل على الموقع
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      try {
        Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
        
        position = CustomPosition(
          status: permission,
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
        position = CustomPosition(
          status: permission,
          msg: "Error getting location: $e",
          success: false,
        );
        _locationCompleter?.complete(position);
        _locationCompleter = null;
        return position!;
      }
    } else {
      position = CustomPosition(
        status: permission,
        msg: "Location permission is $permission",
        success: false,
      );
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
