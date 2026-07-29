import UIKit
import Flutter
import GoogleMaps
import FirebaseCore
import FirebaseFirestore

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Firebase
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    // Google Maps
    GMSServices.provideAPIKey(
      "AIzaSyBK82kg-QdV1TdTrOoC3-jvbSstRhz1wZ0"
    )

    // Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    // Log app launch
    saveLog(
      title: "APP_START",
      value: "didFinishLaunching"
    )

    // Register for APNS
    application.registerForRemoteNotifications()

    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }

  // ============================================================
  // SAVE DEBUG LOG TO FIRESTORE
  // ============================================================

  func saveLog(
    title: String,
    value: String
  ) {

    Firestore.firestore()
      .collection("ios_native_logs")
      .document()
      .setData([
        "title": title,
        "value": value,
        "time": FieldValue.serverTimestamp()
      ]) { error in

        if let error = error {
          print("Firestore Log Error: \(error.localizedDescription)")
        } else {
          print("Firestore Log Saved: \(title)")
        }
      }
  }

  // ============================================================
  // APNS SUCCESS
  // ============================================================

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

  // ============================================================
  // APNS FAILED
  // ============================================================

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {

    saveLog(
      title: "APNS_FAILED",
      value: error.localizedDescription
    )

    super.application(
      application,
      didFailToRegisterForRemoteNotificationsWithError: error
    )
  }

  // ============================================================
  // APP ACTIVE
  // ============================================================

  override func applicationDidBecomeActive(
    _ application: UIApplication
  ) {

    saveLog(
      title: "APP_ACTIVE",
      value: "Application became active"
    )

    super.applicationDidBecomeActive(application)
  }
}