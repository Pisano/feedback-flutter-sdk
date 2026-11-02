## 0.1.0 (unreleased)

Moves the plugin onto the native Pisano 2.0 SDKs (iOS `Pisano ~> 2.0.0`,
Android `co.pisano:feedback:2.0.0`). Both report one result per `show()` and
the survey events through a separate channel; the plugin does the same.

* **BREAKING**: minimum iOS **15.0** (podspec, `Package.swift`, example app);
  Dart `>= 2.17`, Flutter `>= 3.0`.
* **BREAKING**: `FeedbackCallback` holds only `show()` results:
  `none`, `closed`, `sendFeedback`, `displayOnce`, `preventMultipleFeedback`,
  `channelQuotaExceeded`, and the new `channelPassive` and
  `displayRateLimited`. `outside` is removed (an outside tap is `closed`; the
  `closed` event's `closeReason` is `outside`), and so is `opened` (an event).
* **BREAKING**: the native plugins send the result **by name**. Android used to
  send `ordinal + 1`, so every Android result was off by one (a closed survey
  arrived as `sendFeedback`); this is fixed.
* **BREAKING**: Android `minSdk` 21 and `compileSdk` 34, as the native
  `co.pisano:feedback` 2.0 AAR requires. The unused `READ_EXTERNAL_STORAGE` /
  `WRITE_EXTERNAL_STORAGE` permissions are no longer added to your app.
* **BREAKING**: `init()` completes with a `bool` (`true` when the SDK booted).
* **BREAKING**: `track()` returns `Future<bool>`: `true` when the server
  accepted the event. It used to wait on the next survey result and could
  steal a pending `show()` result on Android.
* **BREAKING**: `payload` is typed `Map<String, String>?`; `customer` is a
  `PisanoCustomer` or a `Map`. The Android plugin read `customAttrs` while the
  README documented it, so custom attributes were dropped on Android; both
  plugins now read `customAttributes`, and Dart maps `customAttrs`,
  `custom_attrs`, `phone_number`, `external_id`, `phone` (any case) onto the
  `PisanoCustomer` fields. Unknown keys are dropped with a warning.
* Results follow one rule on both platforms: a submitted survey completes
  `sendFeedback` however the widget closes afterwards; a survey that is not
  shown, or whose page cannot load, completes `none` (on iOS a `show()` without
  a successful boot used to never complete). One survey at a time: a `show()`
  while one is open or about to open completes `none`; `clear()` completes a
  pending one with `none`. Both rules are in the native SDKs; the plugins keep
  no `show()` state and complete each call from its own native result.
* Add `events` (`Stream<PisanoEvent>`): `opened`, `feedbackSubmitted`
  (`hasChat`), `redirectedToStore` (`handledBySDK`), `closed` (`closeReason`).
* Add `setRequestTimeout(Duration)`: network timeout of every SDK request
  (default 30 seconds on both platforms).
* Add `show(dismissOnDrag:)`, `healthCheck()`, `setAutomaticStoreReview()` and
  the `PisanoCustomer` class.
* Android: `init(debugLogging:)` now turns on the native debug log too.
* Example app: event log, health check, `dismissOnDrag` and automatic store
  review switches, typed `PisanoCustomer`.

## Unreleased (Swift Package Manager)

* Add Swift Package Manager (SPM) support for iOS, alongside the existing CocoaPods support.
  * Add `ios/feedback_flutter_sdk/Package.swift`, depending on the [`Pisano/pisano-ios`](https://github.com/Pisano/pisano-ios) Swift package (`PisanoFeedback`), mirroring the podspec's `~> 1.0.21` constraint.
  * Move iOS sources to `ios/feedback_flutter_sdk/Sources/feedback_flutter_sdk/`; the podspec's `source_files` points at the new location, so CocoaPods keeps working unchanged.
  * Replace the Objective-C registrar shim with the Swift plugin class, renamed from `SwiftFeedbackFlutterSdkPlugin` to `FeedbackFlutterSdkPlugin` and annotated with `@objc(FeedbackFlutterSdkPlugin)`. `pluginClass` in `pubspec.yaml` is unchanged, and a deprecated `SwiftFeedbackFlutterSdkPlugin` typealias is kept for source compatibility.
  * Raise the podspec's iOS platform from `9.0` to `12.0`, matching the native SDK's stated requirement.
* No Dart API changes.

## 0.0.18

* Native pin bump for MT-38 (`disable_zoom` + keyboard/viewport) and MT-41 bottom sheet (via native SDK).
* Update iOS native SDK dependency to `~> 1.0.21`
* Update Android native SDK dependency to `co.pisano:feedback:1.3.33`
* Sync podspec version with pubspec (`0.0.18`)
* No Dart API changes — zoom controlled via Pisano channel config (`disable_zoom`)

## 0.0.17

* **BREAKING**: `code` is now a **required** parameter in `init()`. Pass the survey/channel code from the Pisano panel.
* **BREAKING**: `flowId` parameter removed from `show()`. Use optional `code` parameter instead (omit to use the boot code).
* Update iOS native SDK dependency to `~> 1.0.17`
* Update Android native SDK dependency to `co.pisano:feedback:1.3.28`
* Migrate example app Android Gradle config to declarative `plugins {}` block
* Clean up unused imports and async modifiers in Dart API

## 0.0.16

* No runtime/API changes compared to 0.0.15.
* Clean up tracked tool artifacts so `flutter pub publish` succeeds.
* Add homepage and minimum Flutter SDK constraint to `pubspec.yaml`.

## 0.0.15

* Support Dart SDK >=2.12.0 and enable Dart 3/Flutter 3 apps (upper bound <4.0.0)
* Fix Android track bridge so events reach Pisano backend reliably
* Deliver OPENED callbacks to Flutter and expose debug logging toggle
* Stop forcing Pisano iOS SDK debug mode; honor new `debugLogging` flag
* Align customer payload handling between show/track and awaitable init/clear
* Update iOS Pisano SDK dependency to `~> 1.0.16`
* Please run `pod repo update && pod install` (or `pod update Pisano`) after upgrading so the new iOS pod version is fetched; otherwise Xcode may still look for the legacy `Feedback` module.

## 0.0.14

* Fixed Android release build resource linking errors
* Added missing AndroidX dependencies (AppCompat, CardView, Material Components)
* Resolved resource conflicts for `cardview_light_background`, `windowNoTitle`, and `textAllCaps` attributes

## 0.0.13

* Updated Retrofit2 dependencies to latest stable versions
* Enhanced SDK stability and performance
* Improved error handling for network requests


## 0.0.1

* TODO: Describe initial release.
