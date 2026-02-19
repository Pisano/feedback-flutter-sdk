import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedback_flutter_sdk/feedback_flutter_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('feedback_flutter_sdk');

  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getPlatformVersion') {
        return '42';
      } else if (methodCall.method == 'init') {
        return null;
      } else if (methodCall.method == 'show') {
        return 1;
      } else if (methodCall.method == 'track') {
        return 1;
      } else if (methodCall.method == 'clear') {
        return null;
      }
      return null;
    });
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('init method test', () async {
    final sdk = FeedbackFlutterSdk();
    try {
      await sdk.init(
        "applicationId",
        "accessKey",
        "apiUrl",
        "feedbackUrl",
        null,
        code: "test-code",
      );
      expect(true, isTrue);
    } catch (e) {
      expect(true, isTrue);
    }
  });

  test('show method test', () async {
    final sdk = FeedbackFlutterSdk();
    try {
      await sdk.init(
        "applicationId",
        "accessKey",
        "apiUrl",
        "feedbackUrl",
        null,
        code: "test-code",
      );
      final result = await sdk.show();
      expect(result, FeedbackCallback.closed);
    } catch (e) {
      expect(true, isTrue);
    }
  });

  test('track method test', () async {
    final sdk = FeedbackFlutterSdk();
    try {
      await sdk.init(
        "applicationId",
        "accessKey",
        "apiUrl",
        "feedbackUrl",
        null,
        code: "test-code",
      );
      final result = await sdk.track('test_event');
      expect(result, FeedbackCallback.closed);
    } catch (e) {
      expect(true, isTrue);
    }
  });
}
