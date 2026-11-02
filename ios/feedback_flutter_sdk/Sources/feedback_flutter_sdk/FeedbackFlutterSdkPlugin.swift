import Flutter
import UIKit
import PisanoFeedback

@objc(FeedbackFlutterSdkPlugin)
public class FeedbackFlutterSdkPlugin: NSObject, FlutterPlugin {
    // The show() call in flight. A second show() completes with "none" right
    // away (the Android SDK applies the same rule natively), and clear()
    // completes the pending one with "none".
    private var pendingShow: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "feedback_flutter_sdk", binaryMessenger: registrar.messenger())
        let instance = FeedbackFlutterSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let events = FlutterEventChannel(name: "feedback_flutter_sdk/events", binaryMessenger: registrar.messenger())
        events.setStreamHandler(PisanoEventStreamHandler())
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            guard let args = arguments(call, result) else { return }

            let debugLogging = args["debugLogging"] as? Bool ?? false
            Pisano.debugMode(debugLogging)
            let code = args["code"] as? String ?? ""
            Pisano.boot(appId: args["applicationId"] as? String ?? "",
                        accessKey: args["accessKey"] as? String ?? "",
                        code: code,
                        apiUrl: args["apiUrl"] as? String ?? "",
                        feedbackUrl: args["feedbackUrl"] as? String ?? "",
                        eventUrl: args["eventUrl"] as? String) { succeeded in
                result(succeeded)
            }

        case "show":
            guard let args = arguments(call, result) else { return }
            guard pendingShow == nil else {
                result(Self.resultName(.none))
                return
            }
            pendingShow = result

            var customTitle: NSAttributedString? = nil
            if let title = args["title"] as? String {
                var attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
                if let titleFontSize = args["titleFontSize"] as? Int {
                    attributes[.font] = UIFont.systemFont(ofSize: CGFloat(titleFontSize))
                }
                customTitle = NSAttributedString(string: title, attributes: attributes)
            }

            let viewMode = ViewMode(rawValue: args["viewMode"] as? Int ?? 0) ?? .default
            Pisano.show(mode: viewMode,
                        title: customTitle,
                        language: args["language"] as? String,
                        pisanoCustomer: Self.customer(args["customer"]),
                        payload: args["payload"] as? [String: String],
                        code: args["code"] as? String,
                        dismissOnDrag: args["dismissOnDrag"] as? Bool ?? false) { [weak self] status in
                self?.completeShow(Self.resultName(status))
            }

        case "healthCheck":
            guard let args = arguments(call, result) else { return }
            Pisano.healthCheck(language: args["language"] as? String,
                               pisanoCustomer: Self.customer(args["customer"]),
                               payload: args["payload"] as? [String: String],
                               code: args["code"] as? String) { canShow in
                result(canShow)
            }

        case "track":
            guard let args = arguments(call, result) else { return }
            // Fire-and-forget: only iOS reports whether the event was sent, so
            // the plugin does not surface it.
            Pisano.track(event: args["event"] as? String ?? "",
                         payload: args["payload"] as? [String: String],
                         pisanoCustomer: Self.customer(args["customer"]),
                         language: args["language"] as? String) { _ in }
            result(nil)

        case "setAutomaticStoreReview":
            guard let args = arguments(call, result) else { return }
            Pisano.automaticStoreReview = args["enabled"] as? Bool ?? true
            result(nil)

        case "clear":
            Pisano.clear()
            // Pisano.clear() ends a pending show() with .none itself; completing
            // here too keeps it immediate and matches Android, whose
            // clearAction() does not end it.
            completeShow(Self.resultName(.none))
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func arguments(_ call: FlutterMethodCall, _ result: FlutterResult) -> [String: Any]? {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "Expected a map for method: \(call.method)",
                                details: nil))
            return nil
        }
        return args
    }

    private func completeShow(_ name: String) {
        guard let result = pendingShow else { return }
        pendingShow = nil
        result(name)
    }

    /// The customer map (keys already mapped onto the PisanoCustomer field
    /// names in Dart, `normalizeCustomer`) as the typed native customer; nil
    /// when no field is set.
    static func customer(_ value: Any?) -> PisanoCustomer? {
        guard let map = value as? [String: Any] else { return nil }
        func string(_ key: String) -> String? {
            guard let text = map[key] as? String, !text.isEmpty else { return nil }
            return text
        }
        let customAttributes = map["customAttributes"] as? [String: Any]
        let customer = PisanoCustomer(name: string("name"),
                                      email: string("email"),
                                      phoneNumber: string("phoneNumber"),
                                      externalId: string("externalId"),
                                      customAttributes: customAttributes)
        let isEmpty = customer.name == nil && customer.email == nil && customer.phoneNumber == nil
            && customer.externalId == nil && customAttributes == nil
        return isEmpty ? nil : customer
    }

    /// `CloseStatus` -> the Dart `FeedbackCallback` name. By name, never by raw
    /// value: the raw values have gaps since Pisano 2.0.
    static func resultName(_ status: CloseStatus) -> String {
        switch status {
        case .none: return "none"
        case .closed: return "closed"
        case .sendFeedback: return "sendFeedback"
        case .displayOnce: return "displayOnce"
        case .preventMultipleFeedback: return "preventMultipleFeedback"
        case .channelQuotaExceeded: return "channelQuotaExceeded"
        case .channelPassive: return "channelPassive"
        case .displayRateLimited: return "displayRateLimited"
        @unknown default: return "none"
        }
    }

    /// `PisanoEvent` -> the map `PisanoEvent.fromMap` reads in Dart.
    static func eventMap(_ event: PisanoEvent) -> [String: Any] {
        let type: String
        switch event.type {
        case .opened: type = "opened"
        case .feedbackSubmitted: type = "feedbackSubmitted"
        case .redirectedToStore: type = "redirectedToStore"
        case .closed: type = "closed"
        @unknown default: type = ""
        }
        let closeReason: String?
        switch event.closeReason {
        case .closeButton: closeReason = "closeButton"
        case .drag: closeReason = "drag"
        case .outside: closeReason = "outside"
        case .afterSubmit: closeReason = "afterSubmit"
        case .clear: closeReason = "clear"
        case .loadFailed: closeReason = "loadFailed"
        case .hostDismissed: closeReason = "hostDismissed"
        default: closeReason = nil
        }
        return [
            "type": type,
            "code": event.code,
            "hasChat": event.hasChat,
            "closeReason": closeReason as Any,
            "handledBySDK": event.handledBySDK,
        ]
    }
}

/// Forwards `Pisano.subscribe` events to the Dart `events` stream while it has
/// a listener.
final class PisanoEventStreamHandler: NSObject, FlutterStreamHandler {
    private var subscription: PisanoSubscription?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        subscription?.cancel()
        subscription = Pisano.subscribe { event in
            events(FeedbackFlutterSdkPlugin.eventMap(event))
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        subscription?.cancel()
        subscription = nil
        return nil
    }
}

/// Kept for source compatibility with releases before the Swift Package Manager
/// migration, where the plugin was registered through an Objective-C shim.
@available(*, deprecated, renamed: "FeedbackFlutterSdkPlugin")
public typealias SwiftFeedbackFlutterSdkPlugin = FeedbackFlutterSdkPlugin
