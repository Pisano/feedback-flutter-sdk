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
