# Pisano Feedback Flutter SDK

Flutter plugin that bridges Pisano native SDKs on **Android** and **iOS**.

If you’re looking for the native iOS sample apps, see the Pisano iOS sample repo and its guide: [Pisano iOS sample apps README](https://github.com/Pisano/feedback-sample-ios-app/blob/main/README.md).

## ✨ Features

- **Widget UI**: Feedback widget is rendered via web content through the native SDKs
- **One Flutter API**: Same Dart calls for Android + iOS (`init`, `show`, `track`, `clear`)
- **View modes**: Full screen and bottom sheet
- **Customer + payload**: Pass customer attributes and transactional payload
- **Multi-language**: Provide `language`
- **Custom title**: Provide `title` + `titleFontSize`

## 📱 Requirements

- **Flutter**: tested with Flutter `3.38.3` (Dart `3.10.1`)
- **iOS development**: Xcode 15+ and CocoaPods `>= 1.13`
- **Android development**: Android SDK 34+ and Java 17

Native SDK versions are an internal implementation detail for most consumers.
If you are contributing to the plugin or debugging native builds, see `DEVELOPMENT.md`.

## 📦 Installation

### Option A) Git dependency (most common for private distribution)

In your app’s `pubspec.yaml`:

```yaml
dependencies:
  feedback_flutter_sdk:
    git:
      url: https://github.com/Pisano/feedback-flutter-sdk.git
      ref: <tag_or_commit>
```

### Option B) Local path (during development)

```yaml
dependencies:
  feedback_flutter_sdk:
    path: ../feedback-flutter-sdk
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start (Flutter)

### 1) Import

```dart
import 'package:feedback_flutter_sdk/feedback_flutter_sdk.dart';
```

### 2) Initialize (Boot)

Call once at app startup (or before the first `show()`):

```dart
final feedbackSdk = FeedbackFlutterSdk();

await feedbackSdk.init(
  '<applicationId>',
  '<accessKey>',
  '<apiUrl>',
  '<feedbackUrl>',
  null, // eventUrl (optional)
  debugLogging: false,
);
```

### 3) Show widget

```dart
final callback = await feedbackSdk.show(
  viewMode: ViewMode.bottomSheetMode,
  title: 'We Value Your Feedback',
  titleFontSize: 20,
  flowId: '', // empty => default flow
  language: 'tr',
  customer: {
    'name': 'John Doe',
    'externalId': 'CRM-12345',
    'email': 'john@example.com',
    'phoneNumber': '+905001112233',
    'customAttrs': {'plan': 'premium'},
  },
  payload: {'source': 'app', 'screen': 'home'},
);

print('show callback: $callback');
```

### 4) Track event

```dart
final callback = await feedbackSdk.track(
  'view_promo',
  language: 'tr',
  customer: {'externalId': 'CRM-12345'},
  payload: {'campaign': 'winter'},
);

print('track callback: $callback');
```

### 5) Clear

```dart
await feedbackSdk.clear();
```

## 📚 API Reference

### `FeedbackFlutterSdk`

- **`Future<void> init(applicationId, accessKey, apiUrl, feedbackUrl, eventUrl, {debugLogging})`**
  - Must be called before `show` / `track`
- **`Future<FeedbackCallback> show({viewMode, title, titleFontSize, flowId, language, customer, payload})`**
- **`Future<FeedbackCallback> track(event, {language, customer, payload})`**
- **`Future<void> clear()`**

### `ViewMode`

- **`ViewMode.defaultMode`**: full screen
- **`ViewMode.bottomSheetMode`**: bottom sheet (note: some iOS bottom sheet behaviors require iOS 13+)

### `FeedbackCallback`

Returned from `show()` and `track()`:

- `closed`, `sendFeedback`, `outside`, `opened`, `displayOnce`, `preventMultipleFeedback`, `channelQuotaExceeded`, `none`

## ▶️ Run the Example App

The `example/` app uses the plugin through a path dependency and shows a UI similar to Pisano’s native sample flows.

### 1) Install dependencies

```bash
flutter pub get
(cd example && flutter pub get)
```

### 2) Provide credentials (local-only)

See `example/README.md` for the recommended approach (local `pisano_defines.json` ignored by git).

### 3) Run

```bash
cd example
flutter run -d <device_id>
```

## ⚙️ Platform Configuration Notes

### iOS permissions (only if your flows use attachments)

Add to your app’s `Info.plist`:

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSPhotoLibraryAddUsageDescription`

These are the same requirements described in the iOS native sample guide: [Pisano iOS sample apps README](https://github.com/Pisano/feedback-sample-ios-app/blob/main/README.md).

### Android permissions

This plugin’s Android manifest includes network permissions (e.g. `INTERNET`). If your flow uses additional device features, ensure your app requests the corresponding permissions.

## ❓ Troubleshooting

### “SDK not initialized / boot not happening”

- Ensure you call `await feedbackSdk.init(...)` before `show()` or `track()`
- Ensure credentials/URLs are not empty
- In the `example/` app: provide credentials as described in `example/README.md`

### iOS build issues

- Run once inside `example/ios`:

```bash
cd example/ios
pod install
```

### Android dependency resolution issues

- Ensure Gradle can reach `mavenCentral()` and the Android SDK is installed

## ✅ Smoke Tests / Checks

From repo root:

```bash
flutter analyze
flutter test
(cd example && flutter analyze)
```

## 📷 Screenshots

iOS              |  Android 
:-------------------------:|:-------------------------:
![iOS screenshot](https://github.com/Pisano/feedback-flutter-sdk/blob/main/screenshots/screenshot_ios.png)  |  ![Android screenshot](https://github.com/Pisano/feedback-flutter-sdk/blob/main/screenshots/screenshot_android.png)

## Licence

Copyright Pisano.

Released under the MIT license. See [LICENSE](https://github.com/Pisano/feedback-flutter-sdk/blob/main/LICENSE).
