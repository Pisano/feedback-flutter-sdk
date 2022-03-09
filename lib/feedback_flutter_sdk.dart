import 'dart:async';

import 'package:flutter/services.dart';

String checkNotEmpty(String? value, String message) {
  if (value == null || value.isEmpty == true) {
    return throw Exception(message);
  } else {
    return value;
  }
}

class FeedbackFlutterSdk {
  static const MethodChannel _channel = MethodChannel('feedback_flutter_sdk');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /**
   *
   */
  static void init({props}) async {
    checkNotEmpty(props['applicationId'], "application id cannot be empty");
    checkNotEmpty(props['accessKey'], "access key cannot be empty");
    checkNotEmpty(props['apiUrl'], "api url cannot be empty");
    checkNotEmpty(props['feedbackUrl'], "feedback url cannot be empty");
    checkNotEmpty(props['eventUrl'], "event url cannot be empty");

    await _channel.invokeMethod('init', {"props": props});
  }

  /**
   *
   */
  static void show(props, payload, customer) async {
    await _channel.invokeMethod(
        'show', {"props": props, "payload": payload, "customer": customer});
  }

  /**
   *
   */
  static void track(props, payload, customer) async {
    await _channel.invokeMethod(
        'track', {"props": props, "payload": payload, "customer": customer});
  }
}
