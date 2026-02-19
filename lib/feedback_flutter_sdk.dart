import 'dart:developer';

import 'package:flutter/services.dart';

String checkNotEmpty(String? value, String message) {
  if (value == null || value.isEmpty == true) {
    return throw Exception(message);
  } else {
    return value;
  }
}

enum ViewMode { defaultMode, bottomSheetMode }

enum FeedbackCallback {
  none,
  closed,
  sendFeedback,
  outside,
  opened,
  displayOnce,
  preventMultipleFeedback,
  channelQuotaExceeded
}

class FeedbackFlutterSdk {
  static const MethodChannel _channel = MethodChannel('feedback_flutter_sdk');

  Future<void> init(
      String applicationId,
      String accessKey,
      String apiUrl,
      String feedbackUrl,
      String? eventUrl,
      {bool debugLogging = false, required String code}) async {
    checkNotEmpty(applicationId, "application id cannot be empty");
    checkNotEmpty(accessKey, "access key cannot be empty");
    checkNotEmpty(apiUrl, "api url cannot be empty");
    checkNotEmpty(feedbackUrl, "feedback url cannot be empty");
    checkNotEmpty(code, "code cannot be empty");

    await _channel.invokeMethod('init', {
      "applicationId": applicationId,
      "accessKey": accessKey,
      "apiUrl": apiUrl,
      "feedbackUrl": feedbackUrl,
      "eventUrl": eventUrl,
      "debugLogging": debugLogging,
      "code": code
    });
  }

  /// Shows the feedback widget. [code] is optional; if omitted, boot code is used.
  Future<FeedbackCallback> show(
      {ViewMode viewMode = ViewMode.defaultMode,
      String? title,
      int? titleFontSize,
      String? code,
      String? language,
      customer,
      payload}) async {
    dynamic result = await _channel.invokeMethod('show', {
      "viewMode": viewMode.index,
      "title": title,
      "titleFontSize": titleFontSize,
      "code": code,
      "language": language,
      "customer": customer,
      "payload": payload
    });

    return _callback(result);
  }

  Future<FeedbackCallback> track(String event,
      {String? language, customer, payload}) async {
    final normalizedEvent = checkNotEmpty(event, "event cannot be empty");
    dynamic result = await _channel.invokeMethod('track', {
      "event": normalizedEvent,
      "language": language,
      "customer": customer,
      "payload": payload
    });

    return _callback(result);
  }

  Future<void> clear() async {
    await _channel.invokeMethod("clear");
  }

  FeedbackCallback _callback(dynamic result) {
    if (result is int) {
      if (result >= 0 && result < FeedbackCallback.values.length) {
        return FeedbackCallback.values[result];
      }
      log('Invalid FeedbackCallback index: $result');
    } else if (result is String) {
      log(result);
    }
    return FeedbackCallback.none;
  }
}
