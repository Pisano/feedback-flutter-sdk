import 'dart:async';

import 'package:feedback_flutter_sdk/feedback_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await FeedbackFlutterSdk.platformVersion ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    FeedbackFlutterSdk.init(props: {
      "applicationId": "",
      "accessKey": "",
      "apiUrl": "",
      "feedbackUrl": "",
      "eventUrl": "",
    });

    FeedbackFlutterSdk.show({
      "flowId": "",
      "language": ""
    }, {
      "name": ""
    }, {
      "name": "",
      "externalId": "",
      "email": "",
      "phoneNumber": "",
    });

    /*
    FeedbackFlutterSdk.track({
      "event": ""
    }, {
      "name": ""
    }, {
      "name": "",
      "externalId": "",
      "email": "",
      "phoneNumber": "",
    });

     */

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
