import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedback_flutter_sdk/feedback_flutter_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('feedback_flutter_sdk');

  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  dynamic showResult;
  dynamic initResult;
  dynamic trackResult;

  setUp(() {
    calls.clear();
    showResult = 'closed';
    initResult = true;
    trackResult = true;
    binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      calls.add(methodCall);
      switch (methodCall.method) {
        case 'init':
          return initResult;
        case 'show':
          return showResult;
        case 'healthCheck':
          return true;
        case 'track':
          return trackResult;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  Future<bool> init(FeedbackFlutterSdk sdk) => sdk.init(
        "applicationId",
        "accessKey",
        "apiUrl",
        "feedbackUrl",
        null,
        code: "test-code",
      );

  test('init completes with the boot result', () async {
    final sdk = FeedbackFlutterSdk();
    expect(await init(sdk), isTrue);
    initResult = false;
    expect(await init(sdk), isFalse);
  });

  test('show maps the result by name', () async {
    final sdk = FeedbackFlutterSdk();
    for (final value in FeedbackCallback.values) {
      showResult = value.name;
      expect(await sdk.show(), value);
    }
  });

  test('show maps an unknown or legacy result to none', () async {
    final sdk = FeedbackFlutterSdk();
    for (final value in ['outside', 'opened', 1, null]) {
      showResult = value;
      expect(await sdk.show(), FeedbackCallback.none);
    }
  });

  test('show forwards its arguments', () async {
    final sdk = FeedbackFlutterSdk();
    await sdk.show(
      viewMode: ViewMode.bottomSheetMode,
      title: 'Title',
      titleFontSize: 18,
      code: 'PSN-x',
      language: 'tr',
      payload: {'screen': 'home'},
      dismissOnDrag: true,
    );
    expect(calls.single.arguments, {
      'viewMode': 1,
      'title': 'Title',
      'titleFontSize': 18,
      'code': 'PSN-x',
      'language': 'tr',
      'customer': null,
      'payload': {'screen': 'home'},
      'dismissOnDrag': true,
    });
  });

  test('customer: a PisanoCustomer is sent with the canonical keys', () async {
    final sdk = FeedbackFlutterSdk();
    await sdk.show(
      customer: const PisanoCustomer(
        name: 'Ada',
        externalId: 'USR-1',
        customAttributes: {'plan': 'gold'},
      ),
    );
    expect(calls.single.arguments['customer'], {
      'name': 'Ada',
      'externalId': 'USR-1',
      'customAttributes': {'plan': 'gold'},
    });
  });

  test('customer: other spellings are mapped, canonical wins, unknown keys dropped', () {
    expect(
      normalizeCustomer({
        'Phone': '1',
        'External-Id': 'X',
        'externalId': 'canonical',
        'custom_attrs': {'plan': 'gold'},
        'emial': 'typo@b.co',
      }),
      {
        'phoneNumber': '1',
        'externalId': 'canonical',
        'customAttributes': {'plan': 'gold'},
      },
    );
    expect(normalizeCustomer(null), isNull);
  });

  test('healthCheck completes with a bool', () async {
    final sdk = FeedbackFlutterSdk();
    expect(
      await sdk.healthCheck(customer: {'external_id': 'USR-1'}),
      isTrue,
    );
    expect(calls.single.arguments['customer'], {'externalId': 'USR-1'});
  });

  test('track completes with the native result', () async {
    final sdk = FeedbackFlutterSdk();
    expect(await sdk.track('test_event', payload: {'a': 'b'}), isTrue);
    expect(calls.single.method, 'track');
    expect(calls.single.arguments['event'], 'test_event');
    expect(() => sdk.track(''), throwsException);

    trackResult = false;
    expect(await sdk.track('test_event'), isFalse);
    trackResult = null;
    expect(await sdk.track('test_event'), isFalse);
  });

  test('setAutomaticStoreReview forwards the flag', () async {
    final sdk = FeedbackFlutterSdk();
    await sdk.setAutomaticStoreReview(false);
    expect(calls.single.method, 'setAutomaticStoreReview');
    expect(calls.single.arguments, {'enabled': false});
  });

  test('setRequestTimeout forwards whole seconds, ignores less than 1 s',
      () async {
    final sdk = FeedbackFlutterSdk();
    await sdk.setRequestTimeout(const Duration(seconds: 15));
    await sdk.setRequestTimeout(const Duration(milliseconds: 20700));
    await sdk.setRequestTimeout(const Duration(milliseconds: 500));
    await sdk.setRequestTimeout(Duration.zero);
    expect(calls.map((c) => c.method),
        ['setRequestTimeout', 'setRequestTimeout']);
    expect(calls.map((c) => c.arguments), [
      {'seconds': 15},
      {'seconds': 20},
    ]);
  });

  test('PisanoEvent.fromMap reads the native event map', () {
    final closed = PisanoEvent.fromMap({
      'type': 'closed',
      'code': 'PSN-x',
      'hasChat': false,
      'closeReason': 'outside',
      'handledBySDK': false,
    })!;
    expect(closed.type, PisanoEventType.closed);
    expect(closed.code, 'PSN-x');
    expect(closed.closeReason, PisanoCloseReason.outside);

    final submitted = PisanoEvent.fromMap({
      'type': 'feedbackSubmitted',
      'code': 'PSN-x',
      'hasChat': true,
      'closeReason': null,
      'handledBySDK': false,
    })!;
    expect(submitted.hasChat, isTrue);
    expect(submitted.closeReason, isNull);

    expect(PisanoEvent.fromMap({'type': 'unknown'}), isNull);
  });

  test('events stream delivers native events', () async {
    const codec = StandardMethodCodec();
    final received = <PisanoEvent>[];
    final subscription = FeedbackFlutterSdk().events.listen(received.add);
    await Future<void>.delayed(Duration.zero);

    for (final type in PisanoEventType.values) {
      await binding.defaultBinaryMessenger.handlePlatformMessage(
        'feedback_flutter_sdk/events',
        codec.encodeSuccessEnvelope({'type': type.name, 'code': 'PSN-x'}),
        (_) {},
      );
    }
    await Future<void>.delayed(Duration.zero);

    expect(received.map((e) => e.type), PisanoEventType.values);
    await subscription.cancel();
    developer.log('events: $received');
  });
}
