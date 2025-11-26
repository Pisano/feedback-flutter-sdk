import Flutter
import UIKit
import PisanoFeedback

public class SwiftFeedbackFlutterSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "feedback_flutter_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftFeedbackFlutterSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "init") {
            guard let args = call.arguments else {
                return result("Could not recognize flutter arguments in method: (init)")
            }
            if let args = args as? [String: Any]   {
                    let debugLogging = args["debugLogging"] as? Bool ?? false
                    Pisano.debugMode(debugLogging)
                    Pisano.boot(appId:args["applicationId"] as? String ?? "",
                                accessKey:args["accessKey"] as? String ?? "",
                                apiUrl:args["apiUrl"] as? String ?? "",
                                feedbackUrl:args["feedbackUrl"] as? String ?? "",
                                eventUrl:args["eventUrl"] as? String)
            }
            
        } else if(call.method == "show") {
            guard let args = call.arguments else {
                return result("Could not recognize flutter arguments in method: (show)")
            }
            if let args = args as? [String: Any]   {
                var customTitle: NSAttributedString? = nil
                if let title = args["title"] as? String {
                    var attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
                    if let titleFontSize = args["titleFontSize"] as? Int {
                        attributes[.font] = UIFont.systemFont(ofSize: CGFloat(titleFontSize))
                    }
                    customTitle = NSAttributedString(string: title, attributes: attributes)
                }
                
                let viewMode = ViewMode(rawValue: args["viewMode"] as? Int ?? 0) ?? .default
                Pisano.show(mode: viewMode, title: customTitle, flowId: args["flowId"] as? String, language: args["language"] as? String, customer: args["customer"] as? [String : Any], payload: args["payload"] as? [String : String]) { callback in
                    result(callback.rawValue)
                }
            }
            
        } else if(call.method == "track") {
            guard let args = call.arguments else {
                return result("Could not recognize flutter arguments in method: (track)")
            }
            if let args = args as? [String: Any]   {
                Pisano.track(event: args["event"] as? String ?? "", payload: args["payload"] as? [String: String], customer: args["customer"] as? [String: Any], language: args["language"] as? String) { callback in
                    result(callback.rawValue)
                }
            }
            
        } else if (call.method == "clear") {
            Pisano.clear()
        }
    }
}
