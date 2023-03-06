import 'dart:async';
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

  ///
  void init(String applicationId, String accessKey, String apiUrl,
      String feedbackUrl, String? eventUrl) async {
    checkNotEmpty(applicationId, "application id cannot be empty");
    checkNotEmpty(accessKey, "access key cannot be empty");
    checkNotEmpty(apiUrl, "api url cannot be empty");
    checkNotEmpty(feedbackUrl, "feedback url cannot be empty");

    await _channel.invokeMethod('init', {
      "applicationId": applicationId,
      "accessKey": accessKey,
      "apiUrl": apiUrl,
      "feedbackUrl": feedbackUrl,
      "eventUrl": eventUrl
    });
  }

  ///
  Future<FeedbackCallback> show(
      {ViewMode viewMode = ViewMode.defaultMode,
      String? title,
      int? titleFontSize,
      String? flowId,
      String? language,
      customer,
      payload}) async {
    dynamic result = await _channel.invokeMethod('show', {
      "viewMode": viewMode.index,
      "title": title,
      "titleFontSize": titleFontSize,
      "flowId": flowId,
      "language": language,
      "customer": customer,
      "payload": payload
    });

    return _callback(result);
  }

  ///
  Future<FeedbackCallback> track(String event,
      {String? language, customer, payload}) async {
    checkNotEmpty(event, "event cannot be empty");
    dynamic result = await _channel.invokeMethod('track', {
      "event": event,
      "language": language,
      "customer": customer,
      "payload": payload
    });

    return _callback(result);
  }

  void clear() async {
    await _channel.invokeMethod("clear");
  }

  Future<FeedbackCallback> _callback(dynamic result) async {
    if (result is int) {
      try {
        final feedbackCallback = FeedbackCallback.values[result];
        return feedbackCallback;
      } catch (e) {
        log('Non exist FeedbackCallback enum value');
      }
    } else if (result is String) {
      log(result);
    }

    return FeedbackCallback.none;
  }
}
