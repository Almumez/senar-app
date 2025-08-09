import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCvLDETWANAijGWUxdHaV7F_ph3PyQsHho")
    GeneratedPluginRegistrant.register(with: self)
    
    // تفعيل الإشعارات
    if #available(iOS 10.0, *) {
      // استخدام الطريقة المباشرة بدون UserNotifications
      application.registerForRemoteNotifications()
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
