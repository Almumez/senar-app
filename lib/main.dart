import 'dart:io';

import 'package:easy_localization/easy_localization.dart' as lang;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/routes/app_routes.dart';
import 'core/routes/app_routes_fun.dart';
import 'core/services/bloc_observer.dart';
import 'core/services/local_notifications_service.dart';
import 'core/services/service_locator.dart';
import 'core/services/location_tracking_service.dart';
import 'core/utils/app_theme.dart';
import 'core/utils/enums.dart';
import 'core/utils/phoneix.dart';
import 'core/utils/unfocus.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';

// Definir el manejador de mensajes en segundo plano a nivel superior
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await lang.EasyLocalization.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  Bloc.observer = AppBlocObserver();
  Prefs = await SharedPreferences.getInstance();
  UserModel.i.get();

  // Inicializar Firebase primero
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Configurar el manejador de mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Crear e inicializar canales de notificación
  await GlobalNotification.flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(GlobalNotification.channel);

  // Configurar opciones de presentación de notificaciones en primer plano
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  
  // Inicializar el servicio de notificación
  GlobalNotification().setUpFirebase();
  
  // Inicializar el localizador de servicios
  ServicesLocator().init();

  // بدء خدمة تتبع الموقع للمندوب الحر
  debugPrint('تحقق من نوع الحساب عند بدء التطبيق: ${UserModel.i.userType}');
  
  if (UserModel.i.isAuth) {
    debugPrint('المستخدم مسجل الدخول، مستخدم من نوع: ${UserModel.i.userType}');
    
    if (UserModel.i.userType == 'free_agent') {
      debugPrint('المستخدم هو مندوب حر، بدء خدمة تتبع الموقع...');
      try {
        await sl<LocationTrackingService>().startTracking();
        debugPrint('تم بدء خدمة تتبع الموقع عند بدء التطبيق');
      } catch (e) {
        debugPrint('خطأ عند بدء خدمة تتبع الموقع: $e');
      }
    } else {
      debugPrint('المستخدم ليس مندوب حر، لن يتم بدء خدمة تتبع الموقع');
    }
  } else {
    debugPrint('المستخدم غير مسجل الدخول، لن يتم بدء خدمة تتبع الموقع');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (UserModel.i.isAuth && UserModel.i.accountType == UserType.freeAgent) {
      switch (state) {
        case AppLifecycleState.resumed:
          // App is in the foreground
          sl<LocationTrackingService>().startTracking();
          break;
        case AppLifecycleState.detached:
        case AppLifecycleState.hidden:
        case AppLifecycleState.inactive:
        case AppLifecycleState.paused:
          // App is in the background or inactive
          // Keep location tracking running for agents
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return lang.EasyLocalization(
      path: 'assets/translations',
      saveLocale: true,
      startLocale: Prefs.getString('lang') == 'en' ? const Locale('en', 'US') : const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            themeMode: ThemeMode.system,
            initialRoute: AppRoutes.init.initial,
            routes: AppRoutes.init.appRoutes,
            navigatorKey: navigator,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppThemes.lightTheme,
            builder: (context, child) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.white,
                  ),
                );
              };
              return Phoenix(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.sp)),
                  child: Unfocus(child: child ?? const SizedBox.shrink()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ignore: non_constant_identifier_names
late SharedPreferences Prefs;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (cert, host, port) => true;
  }
}
