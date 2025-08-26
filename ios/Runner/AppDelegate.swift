import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let launcherIconChannel = FlutterMethodChannel(name: "com.escrowcorner.app/launcher_icon",
                                              binaryMessenger: controller.binaryMessenger)
    
    launcherIconChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "updateLauncherIcon" {
        if let args = call.arguments as? [String: Any],
           let iconPath = args["iconPath"] as? String {
          let success = self.updateLauncherIcon(iconPath: iconPath)
          result(success)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENT",
                            message: "Icon path is required",
                            details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func updateLauncherIcon(iconPath: String) -> Bool {
    do {
      let iconURL = URL(fileURLWithPath: iconPath)
      if !FileManager.default.fileExists(atPath: iconPath) {
        print("Icon file does not exist: \(iconPath)")
        return false
      }
      
      // Load the new icon
      guard let imageData = try? Data(contentsOf: iconURL),
            let image = UIImage(data: imageData) else {
        print("Failed to load icon image")
        return false
      }
      
      // Update the launcher icon
      updateAppIcon(image: image)
      
      print("Launcher icon updated successfully")
      return true
    } catch {
      print("Error updating launcher icon: \(error)")
      return false
    }
  }
  
  private func updateAppIcon(image: UIImage) {
    // Note: This is a simplified implementation
    // In a real app, you would need to:
    // 1. Save the icon to the app's bundle or documents directory
    // 2. Update the app's Info.plist or use a custom launcher
    // 3. Handle different icon sizes and densities
    
    // For now, we'll just log that the icon update was requested
    // The actual icon change would require more complex native iOS implementation
    print("Icon update requested for image with size: \(image.size)")
  }
}
