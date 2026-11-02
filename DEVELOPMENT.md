# Development Guide

This document explains how to set up your machine, run checks, and contribute
to `feedback_flutter_sdk` without breaking existing integrations.

## Prerequisites

- Flutter SDK `>= 3.19` (repo currently tested with `3.38.3`, Dart `3.10.1`)
- Xcode 15+ for iOS builds (macOS only)
- Android Studio / command-line SDK 34+
- Java 17 (required by AGP 8.x)
- CocoaPods `>= 1.13` for iOS example app

Verify Flutter:

```bash
flutter --version
flutter doctor
```

## Project Structure

```
lib/                    # Dart API surface
android/                # Native Android plugin wrapping Pisano SDK
ios/                    # Native iOS plugin wrapping Pisano SDK
example/                # Sample Flutter application
test/                   # Dart unit tests (channel mocks)
```

Native SDK dependencies:

- Android: `co.pisano:feedback:2.0.0`
- iOS: `Pisano (~> 2.0.0)` (CocoaPods) / `pisano-ios` from `2.0.0` (Swift Package Manager), iOS 15.0+

Any backend communication happens through these native SDKs. Keep versions in
`android/build.gradle`, `ios/feedback_flutter_sdk.podspec` and
`ios/feedback_flutter_sdk/Package.swift` aligned.

Channel contract (both plugins):

- `show` replies with the `FeedbackCallback` **name** (`"sendFeedback"`, …),
  never an ordinal or raw value — the native enums do not line up (iOS
  `CloseStatus` has gaps since 2.0). Dart maps unknown names to `none`.
- `init` and `healthCheck` reply with a `bool`; `track`, `clear` and
  `setAutomaticStoreReview` reply with `null`.
- The `feedback_flutter_sdk/events` `EventChannel` sends one map per survey
  event: `type`, `code`, `hasChat`, `closeReason` (`null` except for
  `closed`), `handledBySDK`. Each plugin subscribes to the native
  `subscribe` API while Dart listens.
- The customer arrives with the `PisanoCustomer` field names (Dart
  `normalizeCustomer` maps other spellings); both plugins build the native
  `PisanoCustomer` from it.
- One `show()` at a time: a second one replies `"none"` right away, and
  `clear` replies `"none"` to a pending one.

## Environment Setup

1. Clone the repository and create a working branch (`git checkout -b my-branch`).
2. Install dependencies for the plugin **and** the example:

```bash
flutter pub get
(cd example && flutter pub get)
```

3. For iOS development, install pods inside `example/ios` once:

```bash
cd example/ios
pod install
```

## Running Checks

### Analyzer

```bash
flutter analyze
(cd example && flutter analyze)
```

### Tests

```bash
flutter test
(cd example && flutter test)
```

Tests rely on mock method channels. When editing channel names or signatures,
update `test/feedback_flutter_sdk_test.dart` accordingly.

### Example App

Use the sample to validate end-to-end flows:

```bash
cd example
flutter run -d <device_id>
```

Confirm `FeedbackFlutterSdk.init` completes before hitting buttons.

## Coding Guidelines

- Target Dart SDK `>=2.17.0 <4.0.0`.
- Avoid breaking API changes; prefer additive changes and document them in
  `CHANGELOG.md`.
- Keep `README.md` usage snippets synchronized with the actual API.
- Update tests whenever behavior changes (e.g., new callbacks, parameters).
- Do not commit artifacts under `.dart_tool/`, `build/`, `Pods/`, or IDE files
  (see `.gitignore`).

## Release Checklist

1. Update `pubspec.yaml` and `ios/feedback_flutter_sdk.podspec` versions.
2. Document changes in `CHANGELOG.md`.
3. Run `flutter test`, `flutter analyze`, and ensure the example app passes its
   tests.
4. Tag the release and publish to the desired distribution (git tag / pod spec).

Following this guide ensures the SDK stays stable for existing consumers while
we iterate on new features.

