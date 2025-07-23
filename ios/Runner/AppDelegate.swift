import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBtPyO-ZthfX0GSNJISYWSudZ0Yi92_yrc")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
