import Flutter
import UIKit
import Feedback

public class SwiftFeedbackFlutterSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "feedback_flutter_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftFeedbackFlutterSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
        
        if(call.method == "init") {
            guard let args = call.arguments else {
                return result("Could not recognize flutter arguments in method: (init)")
            }
            if let myArgs = args as? [String: Any]   {
                if let props = myArgs["props"] as? Dictionary<String,Any> {
                    
                    Pisano.boot(appId:props["applicationId"] as? String ?? "",
                                accessKey:props["accessKey"] as? String ?? "",
                                apiUrl:props["apiUrl"] as? String ?? "",
                                feedbackUrl:props["feedbackUrl"] as? String ?? "")
                }
            }
            
        }else if(call.method == "show") {
            guard let args = call.arguments else {
                return result("Could not recognize flutter arguments in method: (show)")
            }
            if let myArgs = args as? [String: Any]   {
                if let props = myArgs["props"] as? Dictionary<String,Any> {
                    if let customer = myArgs["customer"] as? Dictionary<String,Any> {
                        if let payload = myArgs["payload"] as? Dictionary<String,String> {
                            
                            Pisano.show(flowId: props["flowId"] as? String ?? "",
                                        language: props["language"] as? String ?? "",
                                        customer: customer,
                                        payload: payload)
                        }
                        
                    }
                    
                }
            }
        }else if(call.method == "track") {
            guard let args = call.arguments else {
                return result("Could not recognize flutter arguments in method: (track)")
            }
            if let myArgs = args as? [String: Any]   {
                if let props = myArgs["props"] as? Dictionary<String,Any> {
                    if let customer = myArgs["customer"] as? Dictionary<String,Any> {
                        if let payload = myArgs["payload"] as? Dictionary<String,String> {
                            
                            Pisano.track(event: props["event"] as? String ?? "", payload: payload, customer: customer)
                        }
                        
                    }
                }
            }
        }
    }
}
