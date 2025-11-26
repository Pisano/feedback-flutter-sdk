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
