
# Pisano Feedback SDK

Pisano feedback sdk is the customer experience management platform.

## Description

Feedback Flutter Plugin for customer experience management on Android and iOS.

## Installation

In the `dependencies:` section of your `pubspec.yaml`, add the following line:

```yaml
dependencies:
  feedback_flutter_sdk:
    git:
      url: https://github.com/Pisano/feedback-flutter-sdk.git
      ref: <latest_version>
```

## Usage
For a comprehensive understanding of how to use this, refer to the example provided.

### Import package:

``` dart
import 'package:feedback_flutter_sdk/feedback_flutter_sdk.dart';
```

### Initialize:

``` dart
    FeedbackFlutterSdk.init(
      "applicationId": "",
      "accessKey": "",
      "apiUrl": "",
      "feedbackUrl": "",
      "eventUrl": "",
      debugLogging: false,
    );
```
| Parameter Name | Type  | Description  |
| ------- | --- | --- |
| applicationId | String | The application ID that can be obtained from Pisano Dashboard |
| accessKey | String | The access key can be obtained from Pisano Dashboard |
| apiUrl | String | The URL of API that will be accessed |
| feedbackUrl | String | Base URL for survey |
| eventUrl | String | Event Url for track |
| debugLogging | bool | Enables verbose native SDK logs (defaults to false) |

### Show:

``` dart
    FeedbackFlutterSdk.show(
      viewMode: ViewMode,
      title: "",
      titleFontSize: 20,
      flowId: "",
      language: "",
      customer: {
        "name": "",
        "externalId": "",
        "email": "",
        "phoneNumber": "",
        "customAttrs": {
            "your_key_one": "your value 1",
            "your_key_two": "your value 2"
        }
      },
      payload: {
          "your_key_one": "your value 1",
      });
```

| Parameter Name | Type  | Description  |
| ------- | --- | --- |
| viewMode | ViewMode | View Mode of Flow Screen, Default or Bottom Sheet |
| title | String | Custom Title of Flow Screen |
| titleFontSize | String | Custom Title Font Size |
| flowId | String | The ID of related flow. Can be obtained from Pisano Dashboard. Can be sent as empty string "" for default flow |
| language | String | language code |
| payload | HashMap<String, String> | Question and related answer in an array (mostly uses for pre-loaded responses to take transactional data(s)) |
| customer | HashMap<String, Any> | Please check the table below for the details of this dictionary |

#### customer keys
| Key Name | Type  | Description  |
| ------- | --- | --- |
| email | String | The email of the customer |
| phoneNumber | String | The phone number of the customer |
| name | String | The name of the customer |
| externalId | String | lThe external ID of the customer |
| customAttrs | Dictionary | your custom keys and values |

#### payload keys
| Key Name | Type  | Description  |
| ------- | --- | --- |
| your_custom_key | Any | your custom key and value |

### Track:

``` dart
    FeedbackFlutterSdk.track(
      "event",
      customer: {
        "name": "",
        "externalId": "",
        "email": "",
        "phoneNumber": "",
        "customAttrs": {
            "your_key_one": "your value 1",
            "your_key_two": "your value 2"
        }
      },
      payload: {
          "your_key_one": "your value 1",
      });
```

| Parameter Name | Type  | Description  |
| ------- | --- | --- |
| event | String | event name |
| payload | HashMap<String, String> | Question and related answer in an array (mostly uses for pre-loaded responses to take transactional data(s)) |
| customer | HashMap<String, Any> | Please check the table below for the details of this dictionary |

#### customer keys
| Key Name | Type  | Description  |
| ------- | --- | --- |
| email | String | The email of the customer |
| phoneNumber | String | The phone number of the customer |
| name | String | The name of the customer |
| externalId | String | lThe external ID of the customer |
| your_custom_key | Any | your custom key and value |

#### payload keys
| Key Name | Type  | Description  |
| ------- | --- | --- |
| your_custom_key | Any | your custom key and value |

## Screenshots

iOS              |  Android 
:-------------------------:|:-------------------------:
![alt-text-1](https://github.com/Pisano/feedback-flutter-sdk/blob/main/screenshots/screenshot_ios.png)  |  ![alt-text-2](https://github.com/Pisano/feedback-flutter-sdk/blob/main/screenshots/screenshot_android.png)

## Licence

Copyright Pisano 2022.

Pisano Feedback SDK is released under the MIT license. See [LICENSE](https://github.com/Pisano/feedback-flutter-sdk/blob/main/LICENSE)  for more information.
