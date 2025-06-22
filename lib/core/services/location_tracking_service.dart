import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/enums.dart';
import '../../models/user_model.dart';
import 'server_gate.dart';

/// خدمة تتبع موقع المستخدم في الخلفية وإرسال التحديثات إلى الخادم.
class LocationTrackingService {
  LocationTrackingService._();
  static final LocationTrackingService instance = LocationTrackingService._();

  static const String _isolateName = 'locationIsolate';
  static const String _portName = 'location_tracking_port';

  Isolate? _isolate;
  ReceivePort? _receivePort;
  Timer? _locationTimer;
  bool _isTracking = false;

  // بدلاً من استخدام Isolate، سنستخدم Timer في الخلفية
  Future<void> startTracking() async {
    debugPrint('بدء تشغيل خدمة تتبع الموقع...');
    
    // التحقق من نوع المستخدم مرة أخرى للتأكيد
    debugPrint('نوع المستخدم الحالي: ${UserModel.i.userType}');
    debugPrint('نوع الحساب المحسوب: ${UserModel.i.accountType}');
    
    if (_isTracking) {
      debugPrint('خدمة تتبع الموقع قيد التشغيل بالفعل');
      return;
    }
    
    if (UserModel.i.userType != 'free_agent') {
      debugPrint('لن يتم بدء تتبع الموقع لأن المستخدم ليس مندوب حر');
      return;
    }

    // طلب أذونات الموقع
    debugPrint('التحقق من خدمات الموقع...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('خدمات الموقع معطلة على الجهاز');
      return;
    }

    debugPrint('التحقق من أذونات الموقع...');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('طلب إذن الموقع...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('تم رفض إذن الموقع');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('تم رفض إذن الموقع نهائيًا');
      return;
    }

    debugPrint('بدء تتبع الموقع في الخلفية...');
    
    // استخدام Timer بدلاً من Isolate للحصول على تحديثات الموقع
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition();
        debugPrint('تم الحصول على موقع جديد: ${position.latitude}, ${position.longitude}');
        await _sendLocationToServer(position.latitude, position.longitude);
      } catch (e) {
        debugPrint('خطأ في الحصول على الموقع: $e');
      }
    });
    
    _isTracking = true;
    debugPrint('تم بدء خدمة تتبع الموقع بنجاح');
  }

  /// إيقاف تتبع موقع المستخدم.
  void stopTracking() {
    debugPrint('إيقاف خدمة تتبع الموقع...');
    
    if (!_isTracking) {
      debugPrint('خدمة تتبع الموقع متوقفة بالفعل');
      return;
    }

    // إلغاء المؤقت
    if (_locationTimer != null) {
      debugPrint('إلغاء مؤقت الموقع...');
      _locationTimer?.cancel();
      _locationTimer = null;
    }
    
    _isTracking = false;
    debugPrint('تم إيقاف خدمة تتبع الموقع بنجاح');
  }

  /// إرسال موقع المستخدم إلى الخادم.
  Future<void> _sendLocationToServer(double lat, double lng) async {
    debugPrint('إرسال تحديث الموقع إلى الخادم: $lat, $lng');
    debugPrint('معرف المندوب الحر (free_agent_id): ${UserModel.i.id}');
    
    try {
      final response = await ServerGate.i.sendToServer(
        url: 'free-agent/location/with-id',
        body: {
          'lat': lat,
          'lng': lng,
          'free_agent_id': UserModel.i.id,
        },
      );
      
      if (response.success) {
        debugPrint('تم إرسال الموقع بنجاح إلى الخادم');
      } else {
        debugPrint('فشل في إرسال الموقع إلى الخادم: ${response.msg}');
      }
    } catch (e) {
      debugPrint('استثناء عند إرسال الموقع إلى الخادم: $e');
    }
  }
  
  /// التحقق من نوع المستخدم الحالي وعرض رسائل تشخيصية
  void checkUserType() {
    if (!UserModel.i.isAuth) {
      debugPrint('=== تشخيص: المستخدم غير مسجل الدخول ===');
      return;
    }
    
    debugPrint('=== معلومات المستخدم الحالي ===');
    debugPrint('الاسم: ${UserModel.i.fullname}');
    debugPrint('معرف المستخدم (ID): ${UserModel.i.id}');
    debugPrint('userType: ${UserModel.i.userType}');
    debugPrint('accountType: ${UserModel.i.accountType}');
    debugPrint('isFreeAgent: ${UserModel.i.accountType == UserType.freeAgent}');
    debugPrint('===========================');
  }

  /// طريقة للتحقق من حالة الخدمة والبدء اليدوي
  Future<bool> checkAndStart() async {
    checkUserType();
    
    if (!_isTracking && UserModel.i.userType == 'free_agent') {
      await startTracking();
      return _isTracking;
    }
    
    return _isTracking;
  }
  
  // طريقة للتحقق من حالة الخدمة
  bool get isTracking => _isTracking;
} 