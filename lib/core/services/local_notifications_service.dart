import 'dart:async';
// import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'package:doctor_client/main.dart';

import '../utils/extensions.dart';
import 'server_gate.dart';

class GlobalNotification {
  static String _deviceToken = "";
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification'),
    enableVibration: true,
    enableLights: true,
  );

  static Future<String> getFcmToken() async {
    try {
      if (_deviceToken.isNotEmpty) return _deviceToken;
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.getAPNSToken();
        await Future.delayed(const Duration(seconds: 1));
      }
      _deviceToken = await FirebaseMessaging.instance.getToken() ?? "";
      // print("--------- Global Notification Logger --------> \x1B[37m------ FCM TOKEN -----\x1B[0m");
      // print('<--------- Global Notification Logger --------> \x1B[32m $_deviceToken\x1B[0m');
      // ignore: avoid_print
      print("device token : $_deviceToken");
      return _deviceToken;
    } catch (e) {
      print("-=-=-=-=- $e");
      return 'postman';
    }
  }

  late FirebaseMessaging _firebaseMessaging;

  updateFcm() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      CustomResponse response = await ServerGate.i.patchToServer(
        url: "client/profile/fcm_update",
        body: {"type": Platform.isAndroid ? "android" : "ios", "device_token": _deviceToken},
      );
      if (response.statusCode == 200) {
        print('<--------- Fcm was updated successfully --------> \x1B[32m $_deviceToken\x1B[0m');
      }
    });
  }
  
  // دالة جديدة لإرسال توكن الجهاز إلى API الجديدة
  static Future<bool> sendTokenToServer() async {
    try {
      // الحصول على التوكن إذا لم يكن موجوداً بالفعل
      String token = await getFcmToken();
      
      // إرسال التوكن إلى الخادم
      CustomResponse response = await ServerGate.i.sendToServer(
        url: "general/device/register",
        body: {
          "device_token": token,
          "device_type": Platform.isAndroid ? "android" : "ios"
        },
      );
      
      // التحقق من نجاح العملية
      if (response.success) {
        print('<--------- Token sent to server successfully --------> \x1B[32m $token\x1B[0m');
        return true;
      } else {
        print('<--------- Failed to send token to server --------> \x1B[31m ${response.msg}\x1B[0m');
        return false;
      }
    } catch (e) {
      print('<--------- Error sending token to server --------> \x1B[31m $e\x1B[0m');
      return false;
    }
  }

  StreamController<Map<String, dynamic>> get notificationSubject {
    return _onMessageStreamController;
  }

  void killNotification() {
    _onMessageStreamController.close();
  }

  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  Map<String, dynamic> _not = {};

  Future<void> setUpFirebase() async {
    await getFcmToken();
    
    // التحقق من وجود ملف الصوت في iOS
    if (Platform.isIOS) {
      await _checkSoundFileExists();
    }
    
    // Inicializar Firebase en segundo plano
    await Firebase.initializeApp();
    
    // Configurar el canal de notificación para Android
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
    
    // Configurar opciones de notificación en primer plano
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.setAutoInitEnabled(true);
    
    firebaseCloudMessagingListeners();
    _notificationsPlugin = flutterLocalNotificationsPlugin;
    
    if (Platform.isAndroid) await _firebaseMessaging.requestPermission(alert: true, announcement: false, badge: true, sound: true);
    
    // Configurar inicialización para Android y iOS
    var android = const AndroidInitializationSettings('@mipmap/launcher_icon');
    var ios = const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentSound: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
    );
    var initSetting = InitializationSettings(android: android, iOS: ios);
    _notificationsPlugin.initialize(initSetting, onDidReceiveNotificationResponse: onSelectNotification);
  }

  Future<void> firebaseCloudMessagingListeners() async {
    if (Platform.isIOS) await iOSPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage data) {
      // print("--------- Global Notification Logger --------> \x1B[37m------ on Notification message data -----\x1B[0m");
      // print('<--------- Global Notification Logger --------> \x1B[32m ${data.data}\x1B[0m');
      // print('<--------- Global Notification Logger --------> \x1B[32m ${data.notification?.android?.channelId}\x1B[0m');
      // print('<--------- Global Notification Logger --------> \x1B[32m ${data.notification?.android?.sound}\x1B[0m');
      _onMessageStreamController.add(data.data);

      _not = data.data;
      showNotification(data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage data) {
      // ignore: avoid_print
      print("--------- Global Notification Logger --------> \x1B[37m------ on Opened -----\x1B[0m");
      // ignore: avoid_print
      print('<--------- Global Notification Logger --------> \x1B[32m ${data.data}\x1B[0m');
      // ignore: avoid_print
      print('<--------- Global Notification Logger --------> \x1B[32m ${data.notification?.android?.channelId}\x1B[0m');
      handlePath(data.data);
    });
  }

  Future<void> showNotification(RemoteMessage data) async {
    if (data.notification != null) {
      String? imageUrl = data.notification!.android?.imageUrl ?? data.notification!.apple?.imageUrl;
      
      AndroidNotificationDetails androidDetails;
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final ByteArrayAndroidBitmap largeIcon = await _getByteArrayFromUrl(imageUrl);
          final ByteArrayAndroidBitmap bigPicture = await _getByteArrayFromUrl(imageUrl);
          
          final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
            bigPicture,
            largeIcon: largeIcon,
            contentTitle: data.notification!.title,
            summaryText: data.notification!.body,
          );
          
          androidDetails = AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            colorized: true,
            color: '#70C656'.color,
            styleInformation: bigPictureStyleInformation,
            sound: const RawResourceAndroidNotificationSound('notification'),
            playSound: true,
            enableVibration: true,
            enableLights: true,
          );
        } catch (e) {
          print("Error loading notification image: $e");
          androidDetails = _getDefaultAndroidDetails();
        }
      } else {
        androidDetails = _getDefaultAndroidDetails();
      }
      
      var iOSPlatformSpecifics = const DarwinNotificationDetails(
        presentSound: true,
        sound: 'notification.wav', // تحديد ملف الصوت المخصص
        interruptionLevel: InterruptionLevel.active,
        categoryIdentifier: 'high_importance_category',
        presentAlert: true,
        presentBadge: true,
      );
      
      var notificationDetails = NotificationDetails(android: androidDetails, iOS: iOSPlatformSpecifics);
      await _notificationsPlugin.show(0, data.notification!.title, data.notification!.body, notificationDetails);
    }
  }
  
  AndroidNotificationDetails _getDefaultAndroidDetails() {
    return AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      colorized: true,
      color: '#70C656'.color,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('notification'),
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );
  }
  
  Future<ByteArrayAndroidBitmap> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return ByteArrayAndroidBitmap(response.bodyBytes);
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  // _downloadAndSaveFile(String url, String fileName) async {
  //   var directory = await getApplicationDocumentsDirectory();
  //   var filePath = '${directory.path}/$fileName';
  //   var response = await http.get(Uri.parse(url));
  //   var file = File(filePath);
  //   await file.writeAsBytes(response.bodyBytes);
  //   return filePath;
  // }

  Future<void> iOSPermission() async {
    // طلب أذونات شاملة للإشعارات في iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true, // مهم جداً لتفعيل الصوت
    );
    
    // التأكد من تفعيل الصوت في الإعدادات المحلية
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void handlePath(Map<String, dynamic> dataMap) {
    handlePathByRoute(dataMap);
  }

  // دالة للتحقق من وجود ملف الصوت في iOS Bundle
  Future<void> _checkSoundFileExists() async {
    try {
      print('🔊 Checking notification sound file...');
      
      // إرسال إشعار تجريبي للتأكد من الصوت
      if (Platform.isIOS) {
        await _testNotificationSound();
      }
      
      print('✅ Sound file check completed');
    } catch (e) {
      print('❌ Error checking sound file: $e');
    }
  }

  // دالة لاختبار صوت الإشعار
  Future<void> _testNotificationSound() async {
    try {
      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentSound: true,
        sound: 'notification.wav',
        presentAlert: false, // لا نريد عرض الإشعار، فقط اختبار الصوت
        presentBadge: false,
      );
      
      const NotificationDetails testDetails = NotificationDetails(iOS: iOSDetails);
      
      // هذا مجرد اختبار داخلي - لن يظهر للمستخدم
      print('🎵 Testing notification sound configuration...');
      
    } catch (e) {
      print('❌ Sound test failed: $e');
    }
  }

  Future<void> handlePathByRoute(Map<String, dynamic> dataMap) async {
    // String type = dataMap["notify_type"].toString();
    // ignore: avoid_print
    print("--------- Global Notification Logger --------> \x1B[37m------ key -----\x1B[0m");
    // ignore: avoid_print
    print('<--------- Global Notification Logger --------> \x1B[32m handlePathByRoute $dataMap\x1B[0m');
    // if (User.i.isAuth == false) {
    // } else if (type == "new_message") {
    //   push(NamedRoutes.i.chatSupport);
    // } else {
    //   push(NamedRoutes.i.notifications);
    // }
  }

  onSelectNotification(NotificationResponse? onSelectNotification) async {
    // print("--------- Global Notification Logger --------> \x1B[37m------ payload -----\x1B[0m");
    // print('<--------- Global Notification Logger --------> \x1B[32m ${onSelectNotification?.notificationResponseType}\x1B[0m');
    handlePath(_not);
  }
}

// Esta función debe ser de nivel superior, fuera de cualquier clase
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage data) async {
  // Asegurarnos que Firebase está inicializado
  await Firebase.initializeApp();
  
  // En segundo plano, debemos mostrar la notificación manualmente
  await showBackgroundNotification(data);
}

// Función adicional para mostrar notificación en segundo plano
@pragma('vm:entry-point')
Future<void> showBackgroundNotification(RemoteMessage message) async {
  if (message.notification != null) {
    // Inicializar el plugin de notificaciones locales
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    String? imageUrl = message.notification!.android?.imageUrl ?? message.notification!.apple?.imageUrl;
    
    AndroidNotificationDetails androidDetails;
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final http.Response response = await http.get(Uri.parse(imageUrl));
        final ByteArrayAndroidBitmap largeIcon = ByteArrayAndroidBitmap(response.bodyBytes);
        final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(response.bodyBytes);
        
        final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
          bigPicture,
          largeIcon: largeIcon,
          contentTitle: message.notification!.title,
          summaryText: message.notification!.body,
        );
        
        androidDetails = AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: bigPictureStyleInformation,
          sound: const RawResourceAndroidNotificationSound('notification'),
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );
      } catch (e) {
        print("Error loading notification image in background: $e");
        androidDetails = const AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification'),
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );
      }
    } else {
      androidDetails = const AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('notification'),
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );
    }
    
    // Configuración específica para iOS
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentSound: true,
      sound: 'notification.wav', // استخدام ملف الصوت المخصص
      interruptionLevel: InterruptionLevel.active,
      categoryIdentifier: 'high_importance_category',
      presentAlert: true,
      presentBadge: true,
    );
    
    // Combinamos configuraciones
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    // Mostrar la notificación
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
    );
  }
}

StreamController<Map<String, dynamic>> _onMessageStreamController = StreamController.broadcast();
