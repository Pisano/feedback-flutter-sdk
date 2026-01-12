/// Configuration for the example app.
///
/// Recommended usage:
/// - Keep real credentials out of git.
/// - Either fill the constants below locally (do not commit), or provide values
///   via `--dart-define=...` when running the example.
///
/// Tip (avoid accidental commits):
/// After you fill values locally, you can tell git to ignore local changes:
///
/// ```bash
/// git update-index --skip-worktree example/lib/pisano_config.dart
/// ```
///
/// To start tracking changes again:
///
/// ```bash
/// git update-index --no-skip-worktree example/lib/pisano_config.dart
/// ```
///
/// Example:
/// flutter run -d <device> \
///   --dart-define=PISANO_APP_ID=... \
///   --dart-define=PISANO_ACCESS_KEY=... \
///   --dart-define=PISANO_API_URL=https://api.pisano.co \
///   --dart-define=PISANO_FEEDBACK_URL=https://web.pisano.co/web_feedback \
///   --dart-define=PISANO_EVENT_URL= \
///   --dart-define=PISANO_LANGUAGE=tr \
///   --dart-define=PISANO_DEBUG_LOGGING=false
class PisanoConfig {
  static const String applicationId =
      String.fromEnvironment('PISANO_APP_ID', defaultValue: 'YOUR_APP_ID');
  static const String accessKey = String.fromEnvironment('PISANO_ACCESS_KEY',
      defaultValue: 'YOUR_ACCESS_KEY');
  static const String apiUrl =
      String.fromEnvironment('PISANO_API_URL', defaultValue: 'YOUR_API_URL');
  static const String feedbackUrl = String.fromEnvironment('PISANO_FEEDBACK_URL',
      defaultValue: 'YOUR_FEEDBACK_URL');

  /// Optional. Pass empty string to disable.
  static const String eventUrlRaw =
      String.fromEnvironment('PISANO_EVENT_URL', defaultValue: '');

  static const bool debugLogging =
      String.fromEnvironment('PISANO_DEBUG_LOGGING', defaultValue: 'false') ==
          'true';

  static const String language =
      String.fromEnvironment('PISANO_LANGUAGE', defaultValue: 'tr');

  static String? get eventUrl => eventUrlRaw.trim().isEmpty ? null : eventUrlRaw;

  static bool get hasPlaceholders =>
      applicationId == 'YOUR_APP_ID' ||
      accessKey == 'YOUR_ACCESS_KEY' ||
      apiUrl == 'YOUR_API_URL' ||
      feedbackUrl == 'YOUR_FEEDBACK_URL';

  static String debugSummary() {
    String describeSecret(String s, String placeholder) {
      if (s == placeholder) return '<placeholder>';
      if (s.isEmpty) return '<empty>';
      return 'set(len=${s.length})';
    }

    return 'appId=${describeSecret(applicationId, "YOUR_APP_ID")}, '
        'accessKey=${describeSecret(accessKey, "YOUR_ACCESS_KEY")}, '
        'apiUrl=$apiUrl, '
        'feedbackUrl=$feedbackUrl, '
        'eventUrl=${eventUrl ?? ""}, '
        'language=$language';
  }
}


