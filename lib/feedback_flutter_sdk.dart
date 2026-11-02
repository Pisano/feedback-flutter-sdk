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

/// The result of [FeedbackFlutterSdk.show], reported once.
///
/// What happened on the way (opened, submitted, how the widget closed) comes
/// through [FeedbackFlutterSdk.events]. The native plugins send these values
/// by name, so the order of this enum carries no meaning.
enum FeedbackCallback {
  /// No result: [FeedbackFlutterSdk.clear], the survey page could not load,
  /// the SDK is not initialized, no connection, a failed request, or a second
  /// `show()` while one is open.
  none,

  /// Closed without submitting: close button, back (Android), drag, a tap
  /// outside the bottom sheet, or the app or system taking the widget away.
  /// The `closed` event's [PisanoEvent.closeReason] tells which.
  closed,

  /// The survey was submitted, however the widget closed afterwards (chat
  /// surveys, the thank-you screen closed early).
  sendFeedback,

  /// Not shown: the customer saw it before.
  displayOnce,

  /// Not shown: the customer already submitted feedback in the given period.
  preventMultipleFeedback,

  /// Not shown: the channel quota is exceeded.
  channelQuotaExceeded,

  /// Not shown: the channel is passive.
  channelPassive,

  /// Not shown: display rate limit.
  displayRateLimited,
}

/// What happened while a survey was on screen. See [FeedbackFlutterSdk.events].
enum PisanoEventType {
  /// The survey widget is on screen.
  opened,

  /// The survey was submitted (also in chat surveys). [PisanoEvent.hasChat]
  /// is set.
  feedbackSubmitted,

  /// The survey asked for the store review flow. [PisanoEvent.handledBySDK]
  /// is set.
  redirectedToStore,

  /// The widget left the screen. [PisanoEvent.closeReason] is set.
  closed,
}

/// Why the widget left the screen, for [PisanoEventType.closed].
enum PisanoCloseReason {
  /// The survey's close button.
  closeButton,

  /// The system back key (Android).
  back,

  /// The bottom sheet was dragged away (`dismissOnDrag: true`).
  drag,

  /// A tap outside the bottom sheet.
  outside,

  /// The thank-you screen ended after a submit.
  afterSubmit,

  /// The session was cleared.
  clear,

  /// The survey page could not be loaded.
  loadFailed,

  /// The app or the system took the widget away.
  hostDismissed,
}

/// An event from a survey shown by [FeedbackFlutterSdk.show].
class PisanoEvent {
  const PisanoEvent({
    required this.type,
    required this.code,
    this.hasChat = false,
    this.closeReason,
    this.handledBySDK = false,
  });

  final PisanoEventType type;

  /// The survey code of the `show()` call the event belongs to.
  final String code;

  /// [PisanoEventType.feedbackSubmitted] only: the survey continues with a
  /// chat.
  final bool hasChat;

  /// [PisanoEventType.closed] only; `null` for the other events.
  final PisanoCloseReason? closeReason;

  /// [PisanoEventType.redirectedToStore] only: the SDK asked the system for
  /// the review prompt. The system does not tell whether it was shown, so this
  /// means "asked", not "seen". `false` when automatic store review is off:
  /// ask for it yourself.
  final bool handledBySDK;

  /// Reads an event sent by the native plugins; `null` for an unknown type.
  static PisanoEvent? fromMap(Map<dynamic, dynamic> map) {
    final type = _byName(PisanoEventType.values, map['type']);
    if (type == null) {
      log('Unknown Pisano event: $map');
      return null;
    }
    return PisanoEvent(
      type: type,
      code: map['code'] as String? ?? '',
      hasChat: map['hasChat'] == true,
      closeReason: _byName(PisanoCloseReason.values, map['closeReason']),
      handledBySDK: map['handledBySDK'] == true,
    );
  }

  @override
  String toString() =>
      'PisanoEvent(${type.name}, code: $code, hasChat: $hasChat, '
      'closeReason: ${closeReason?.name}, handledBySDK: $handledBySDK)';
}

/// The customer a survey or event is about. Same fields as the native
/// `PisanoCustomer` on iOS and Android.
class PisanoCustomer {
  const PisanoCustomer({
    this.name,
    this.email,
    this.phoneNumber,
    this.externalId,
    this.customAttributes,
  });

  final String? name;
  final String? email;
  final String? phoneNumber;

  /// The customer's ID in your own system (CRM, user ID, ...).
  final String? externalId;

  /// Any other attributes, e.g. `{'plan': 'gold', 'city': 'Istanbul'}`.
  final Map<String, dynamic>? customAttributes;

  Map<String, dynamic> toMap() => {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (externalId != null) 'externalId': externalId,
        if (customAttributes != null) 'customAttributes': customAttributes,
      };
}

const List<String> _canonicalCustomerKeys = [
  'name',
  'email',
  'phoneNumber',
  'externalId',
  'customAttributes',
];

// Accepted spellings, compared without case, `_` and `-`.
const Map<String, String> _customerKeyAliases = {
  'name': 'name',
  'email': 'email',
  'phone': 'phoneNumber',
  'phonenumber': 'phoneNumber',
  'externalid': 'externalId',
  'customattrs': 'customAttributes',
  'customattributes': 'customAttributes',
};

/// The customer as the native plugins read it: a [PisanoCustomer], or a map
/// whose keys are mapped onto the [PisanoCustomer] fields. Other spellings
/// (`phone_number`, `external_id`, `custom_attrs`, `phone`, any case) are
/// accepted; when two keys name the same field the canonical spelling wins.
/// An unknown key is not sent and always logs a warning: misspelled personal
/// data must not end up somewhere unexpected.
Map<String, dynamic>? normalizeCustomer(Object? customer) {
  if (customer == null) return null;
  if (customer is PisanoCustomer) return customer.toMap();
  if (customer is! Map) {
    log('Ignoring customer of type ${customer.runtimeType}: '
        'pass a PisanoCustomer or a Map');
    return null;
  }
  final result = <String, dynamic>{};
  customer.forEach((key, value) {
    final keyText = key.toString();
    final field = _customerKeyAliases[
        keyText.toLowerCase().replaceAll(RegExp('[_-]'), '')];
    if (field == null) {
      log('Unknown customer key "$keyText" was not sent. '
          'Use one of: ${_canonicalCustomerKeys.join(', ')}.');
      return;
    }
    if (result.containsKey(field) && keyText != field) return;
    result[field] = value;
  });
  return result;
}

T? _byName<T extends Enum>(List<T> values, Object? name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

class FeedbackFlutterSdk {
  static const MethodChannel _channel = MethodChannel('feedback_flutter_sdk');
  static const EventChannel _eventChannel =
      EventChannel('feedback_flutter_sdk/events');

  static final Stream<PisanoEvent> _events = _eventChannel
      .receiveBroadcastStream()
      .map((event) =>
          event is Map ? PisanoEvent.fromMap(event) : null)
      .where((event) => event != null)
      .cast<PisanoEvent>()
      .asBroadcastStream();

  /// Events of the surveys shown by [show]: opened, feedback submitted,
  /// redirected to the store and closed (with its reason).
  ///
  /// [show] still completes with the result of its call once; events add what
  /// happened on the way. For one survey they arrive in this order, all
  /// before the result: [PisanoEventType.opened],
  /// [PisanoEventType.feedbackSubmitted], [PisanoEventType.redirectedToStore],
  /// [PisanoEventType.closed]. A survey that is not shown (display once,
  /// passive, ...) sends no events. A widget that closes before it finished
  /// appearing (a page that cannot load) may send `closed` without `opened`.
  ///
  /// A broadcast stream: listen as often as you like and cancel the
  /// subscription when you no longer need the events.
  Stream<PisanoEvent> get events => _events;

  /// Sets the SDK up and loads its configuration.
  ///
  /// Completes with `true` once the SDK configuration is fetched, `false` when
  /// the request fails or the configuration is invalid.
  Future<bool> init(
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

    final dynamic booted = await _channel.invokeMethod('init', {
      "applicationId": applicationId,
      "accessKey": accessKey,
      "apiUrl": apiUrl,
      "feedbackUrl": feedbackUrl,
      "eventUrl": eventUrl,
      "debugLogging": debugLogging,
      "code": code
    });
    return booted == true;
  }

  /// Shows the feedback widget. [code] is optional; if omitted, boot code is
  /// used.
  ///
  /// Completes once with a [FeedbackCallback]. A submitted survey completes
  /// with [FeedbackCallback.sendFeedback] however the widget closes
  /// afterwards. When the survey is not shown it completes with
  /// [FeedbackCallback.none], or why the server gated it
  /// ([FeedbackCallback.displayOnce], ...). Use [events] for what happened on
  /// the way.
  ///
  /// [customer] is a [PisanoCustomer] or a map (see [normalizeCustomer]).
  /// [dismissOnDrag] lets the user drag the bottom sheet away.
  Future<FeedbackCallback> show(
      {ViewMode viewMode = ViewMode.defaultMode,
      String? title,
      int? titleFontSize,
      String? code,
      String? language,
      Object? customer,
      Map<String, String>? payload,
      bool dismissOnDrag = false}) async {
    final dynamic result = await _channel.invokeMethod('show', {
      "viewMode": viewMode.index,
      "title": title,
      "titleFontSize": titleFontSize,
      "code": code,
      "language": language,
      "customer": normalizeCustomer(customer),
      "payload": payload,
      "dismissOnDrag": dismissOnDrag
    });

    return _callback(result);
  }

  /// Whether [show] would open a survey right now for this customer and
  /// context, without showing anything. `false` when the channel is gated,
  /// the SDK is not initialized, or the check failed.
  Future<bool> healthCheck(
      {String? code,
      String? language,
      Object? customer,
      Map<String, String>? payload}) async {
    final dynamic canShow = await _channel.invokeMethod('healthCheck', {
      "code": code,
      "language": language,
      "customer": normalizeCustomer(customer),
      "payload": payload
    });
    return canShow == true;
  }

  /// Sends a custom event to the Pisano trigger engine. If the event is
  /// configured as a trigger, a survey opens on its own and reports through
  /// [events].
  ///
  /// Completes with `true` when the server accepted the event, `false`
  /// otherwise (not initialized, no `eventUrl`, no connection, or the request
  /// failed).
  Future<bool> track(String event,
      {String? language, Object? customer, Map<String, String>? payload}) async {
    final normalizedEvent = checkNotEmpty(event, "event cannot be empty");
    final sent = await _channel.invokeMethod<bool>('track', {
      "event": normalizedEvent,
      "language": language,
      "customer": normalizeCustomer(customer),
      "payload": payload
    });
    return sent ?? false;
  }

  /// Whether the SDK asks the system for the store review prompt when a
  /// survey redirects to the store. Defaults to `true`, and is `true` again
  /// each time the app starts. Turn it off to run your own flow on the
  /// [PisanoEventType.redirectedToStore] event ([PisanoEvent.handledBySDK] is
  /// `false`). The [show] result does not change either way.
  Future<void> setAutomaticStoreReview(bool enabled) async {
    await _channel.invokeMethod('setAutomaticStoreReview', {"enabled": enabled});
  }

  /// Network timeout of every SDK request, in whole seconds: a request fails
  /// when the server sends no data for this long. Defaults to 30 seconds on
  /// both platforms and applies to requests that start after it is set. A
  /// timeout below 1 second is ignored.
  Future<void> setRequestTimeout(Duration timeout) async {
    final seconds = timeout.inSeconds;
    if (seconds < 1) {
      log('setRequestTimeout($timeout) ignored: use 1 second or more');
      return;
    }
    await _channel.invokeMethod('setRequestTimeout', {"seconds": seconds});
  }

  /// Ends the session: a survey still pending completes with
  /// [FeedbackCallback.none].
  Future<void> clear() async {
    await _channel.invokeMethod("clear");
  }

  FeedbackCallback _callback(dynamic result) {
    final callback = _byName(FeedbackCallback.values, result);
    if (callback == null) log('Unknown FeedbackCallback: $result');
    return callback ?? FeedbackCallback.none;
  }
}
