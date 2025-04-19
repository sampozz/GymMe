import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    //Google Maps API key for iOS
    GMSServices.provideAPIKey("AIzaSyA78dAdSxee-z3tu89roFSfuihVVTjMGHY")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
