# feedback_flutter_sdk_example

Demonstrates how to use the feedback_flutter_sdk plugin.

## Getting Started

### Configuration

You must provide Pisano credentials before the example can initialize the SDK.

Choose one of these options:

#### Option A) Use `--dart-define-from-file` (recommended)

1) Copy `pisano_defines.json.example` → `pisano_defines.json` and fill your real values.

2) Run:

```bash
flutter run -d <device_id> --dart-define-from-file=pisano_defines.json
```

`pisano_defines.json` is ignored by git (local-only).

#### Option B) Use `--dart-define` (useful for CI)

```bash
flutter run -d <device_id> \
  --dart-define=PISANO_APP_ID=YOUR_APP_ID \
  --dart-define=PISANO_ACCESS_KEY=YOUR_ACCESS_KEY \
  --dart-define=PISANO_CODE=YOUR_CODE \
  --dart-define=PISANO_API_URL=YOUR_API_URL \
  --dart-define=PISANO_FEEDBACK_URL=YOUR_FEEDBACK_URL \
  --dart-define=PISANO_EVENT_URL= \
  --dart-define=PISANO_LANGUAGE=tr \
  --dart-define=PISANO_DEBUG_LOGGING=false
```

#### Option C) Edit config file (quickest for local demo)

Fill the placeholders in `example/lib/pisano_config.dart`:

- `PisanoConfig.applicationId`
- `PisanoConfig.accessKey`
- `PisanoConfig.code`
- `PisanoConfig.apiUrl`
- `PisanoConfig.feedbackUrl`

Do **not** commit real credentials to git.

Tip: after you fill values locally, you can prevent accidental commits:

```bash
git update-index --skip-worktree example/lib/pisano_config.dart
```

To start tracking changes again:

```bash
git update-index --no-skip-worktree example/lib/pisano_config.dart
```
