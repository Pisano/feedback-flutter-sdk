#import "FeedbackFlutterSdkPlugin.h"
#if __has_include(<feedback_flutter_sdk/feedback_flutter_sdk-Swift.h>)
#import <feedback_flutter_sdk/feedback_flutter_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "feedback_flutter_sdk-Swift.h"
#endif

@implementation FeedbackFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFeedbackFlutterSdkPlugin registerWithRegistrar:registrar];
}
@end
