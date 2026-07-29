import UIKit
import Flutter
import GoogleMaps
import FirebaseCore
import FirebaseFirestore

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
      [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    GMSServices.provideAPIKey(
      "AIzaSyBK82kg-QdV1TdTrOoC3-jvbSstRhz1wZ0"
    )

    GeneratedPluginRegistrant.register(
      with: self
    )

    saveLog(
      title: "APP_START",
      value: "didFinishLaunching"
    )

    application.registerForRemoteNotifications()

    return super.application(
      application,
      didFinishLaunchingWithOptions:
      launchOptions
    )
  }

  // ==========================================
  // SAVE DEBUG LOG TO FIRESTORE
  // ==========================================

  func saveLog(
    title: String,
    value: String
  ) {

    Firestore.firestore()
        .collection("ios_native_logs")
        .add([
          "title": title,
          "value": value,
          "time": FieldValue.serverTimestamp()
        ])
  }

  // ==========================================
  // APNS SUCCESS
  // ==========================================

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {

    let token = deviceToken.map {
      String(format: "%02.2hhx", $0)
    }.joined()

    saveLog(
      title: "APNS_SUCCESS",
      value: token
    )

    super.application(
      application,
      didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
    )
  }

  // ==========================================
  // APNS FAILED
  // ==========================================

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {

    saveLog(
      title: "APNS_FAILED",
      value: error.localizedDescription
    )
  }

  // ==========================================
  // APP ACTIVE
  // ==========================================

  override func applicationDidBecomeActive(
    _ application: UIApplication
  ) {

    saveLog(
      title: "APP_ACTIVE",
      value: "Application became active"
    )
  }
}