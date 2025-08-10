import Flutter
import UIKit
import GoogleMaps
import UserNotifications
import AVFoundation

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
      UNUserNotificationCenter.current().delegate = self
      
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { granted, error in
          print("Notification authorization: \(granted)")
          if let error = error {
            print("Authorization error: \(error.localizedDescription)")
          }
        }
      )
      
      // تكوين فئة الإشعارات مع الصوت
      let soundName = UNNotificationSoundName("notification.wav")
      let sound = UNNotificationSound(named: soundName)
      
      let category = UNNotificationCategory(
        identifier: "high_importance_category",
        actions: [],
        intentIdentifiers: [],
        options: .customDismissAction
      )
      
      UNUserNotificationCenter.current().setNotificationCategories([category])
      
      // تسجيل للإشعارات البعيدة
      application.registerForRemoteNotifications()
    }
    
    // إعداد جلسة صوتية
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Failed to set audio session category: \(error)")
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // التعامل مع استلام الإشعارات في المقدمة
  override func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                      willPresent notification: UNNotification, 
                                      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // عرض الإشعار مع الصوت حتى عندما يكون التطبيق في المقدمة
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound])
    } else {
      completionHandler([.alert, .badge, .sound])
    }
  }
  
  // التعامل مع النقر على الإشعار
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      didReceive response: UNNotificationResponse,
                                      withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    print("Notification clicked: \(userInfo)")
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
  
  // تسجيل نجاح تسجيل الإشعارات البعيدة
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    var tokenString = ""
    for byte in deviceToken {
      tokenString += String(format: "%02.2hhx", byte)
    }
    print("APNs device token: \(tokenString)")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  // تسجيل فشل تسجيل الإشعارات البعيدة
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
  
  // التعامل مع وصول الإشعارات البعيدة
  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("Remote notification received: \(userInfo)")
    
    // إذا كان التطبيق في الخلفية، قم بتشغيل الصوت يدويًا
    if application.applicationState == .background || application.applicationState == .inactive {
      playNotificationSound()
    }
    
    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
  }
  
  // تشغيل صوت الإشعار يدويًا
  private func playNotificationSound() {
    guard let soundURL = Bundle.main.url(forResource: "notification", withExtension: "wav") else {
      print("Sound file not found")
      
      // Intentar buscar el archivo en otros lugares
      if let resourcePath = Bundle.main.resourcePath {
        print("Resource path: \(resourcePath)")
        let fileManager = FileManager.default
        do {
          let files = try fileManager.contentsOfDirectory(atPath: resourcePath)
          print("Files in bundle: \(files)")
        } catch {
          print("Error listing files: \(error)")
        }
      }
      
      return
    }
    
    print("Sound file found at: \(soundURL)")
    var soundID: SystemSoundID = 0
    AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
    AudioServicesPlaySystemSound(soundID)
  }
}
