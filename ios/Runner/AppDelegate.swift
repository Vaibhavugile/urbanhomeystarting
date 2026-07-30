import UIKit
import Flutter
import GoogleMaps


@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

   
  

    // Google Maps
    GMSServices.provideAPIKey(
      "AIzaSyBK82kg-QdV1TdTrOoC3-jvbSstRhz1wZ0"
    )

    // Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

let result = super.application(
    application,
    didFinishLaunchingWithOptions: launchOptions
)

saveLog(
    title: "APP_START",
    value: "didFinishLaunching"
)

application.registerForRemoteNotifications()

return result
  }

  // ============================================================
  // SAVE DEBUG LOG TO FIRESTORE
  // ============================================================

  func saveLog(
    title: String,
    value: String
) {
    print("========== \(title) ==========")
    print(value)
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