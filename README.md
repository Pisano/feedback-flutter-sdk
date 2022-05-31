
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

### Import package:

``` dart
import 'package:feedback_flutter_sdk/feedback_flutter_sdk.dart';
```

### Initialize:

``` dart
    FeedbackFlutterSdk.init(props: {
      "applicationId": "",
      "accessKey": "",
      "apiUrl": "",
      "feedbackUrl": "",
      "eventUrl": "",
    });
```
| Parameter Name | Type  | Description  |
| ------- | --- | --- |
| props | HashMap<String, Any> | properties |


#### props keys
| Key Name | Type  | Description  |
| ------- | --- | --- |
| applicationId | String | The application ID that can be obtained from Pisano Dashboard |
| accessKey | String | The access key can be obtained from Pisano Dashboard |
| apiUrl | String | The URL of API that will be accessed |
| feedbackUrl | String | Base URL for survey |
| eventUrl | String | Event Url for track |

### Show:

``` dart
    FeedbackFlutterSdk.show({ // props
      "flowId": "",
      "language": ""
    }, { // payload
      "name": ""
    }, { // customer
      "name": "",
      "externalId": "",
      "email": "",
      "phoneNumber": "",
      "customAttrs": {
          "your_key_one": "your value 1",
          "your_key_two": "your value 2"
      }
    });
```

| Parameter Name | Type  | Description  |
| ------- | --- | --- |
| props | HashMap<String, Any> | properties |
| payload | HashMap<String, String> | Question and related answer in an array (mostly uses for pre-loaded responses to take transactional data(s)) |
| customer | HashMap<String, Any> | Please check the table below for the details of this dictionary |

#### props keys
| Key Name | Type  | Description  |
| ------- | --- | --- |
| flowId | String | The ID of related flow. Can be obtained from Pisano Dashboard. Can be sent as empty string "" for default flow |
| language | String | language code |

#### payload keys
| Key Name | Type  | Description  |
| ------- | --- | --- |
| flowId | String | The ID of related flow. Can be obtained from Pisano Dashboard. Can be sent as empty string "" for default flow |
| language | String | language code |

#### customer keys
| Key Name | Type  | Description  |
| ------- | --- | --- |
| email | String | The email of the customer |
| phoneNumber | String | The phone number of the customer |
| name | String | The name of the customer |
| externalId | String | lThe external ID of the customer |
| customAttrs | Dictionary | your custom keys and values |

### Track:

``` dart
    FeedbackFlutterSdk.track({ // props
      "event": ""
    }, { // payload
      "name": ""
    }, { // customer
      "name": "",
      "externalId": "",
      "email": "",
      "phoneNumber": "",
    });
```

| Parameter Name | Type  | Description  |
| ------- | --- | --- |
| props | HashMap<String, Any> | properties |
| payload | HashMap<String, String> | Question and related answer in an array (mostly uses for pre-loaded responses to take transactional data(s)) |
| customer | HashMap<String, Any> | Please check the table below for the details of this dictionary |

#### props keys
| Key Name | Type  | Description  |
| ------- | --- | --- |
| event | String | event name |

#### payload keys
| Key Name | Type  | Description  |
| ------- | --- | --- |
| your_custom_key | Any | your custom key and value |

#### customer keys
| Key Name | Type  | Description  |
| ------- | --- | --- |
| email | String | The email of the customer |
| phoneNumber | String | The phone number of the customer |
| name | String | The name of the customer |
| externalId | String | lThe external ID of the customer |
| your_custom_key | Any | your custom key and value |

## Screenshots

iOS              |  Android 
:-------------------------:|:-------------------------:
![alt-text-1](https://github.com/Pisano/feedback-flutter-sdk/blob/main/screenshots/screenshot_ios.png)  |  ![alt-text-2](https://github.com/Pisano/feedback-flutter-sdk/blob/main/screenshots/screenshot_android.png)

## Licence

Copyright Pisano 2022.

Pisano Feedback SDK is released under the MIT license. See [LICENSE](https://github.com/Pisano/feedback-flutter-sdk/blob/main/LICENSE)  for more information.
