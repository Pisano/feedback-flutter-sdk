import 'dart:async';
import 'dart:developer';

import 'package:feedback_flutter_sdk/feedback_flutter_sdk.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FeedbackFlutterSdk feedbackSdk = FeedbackFlutterSdk();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we normalize in an async method.
  Future<void> initPlatformState() async {
    await feedbackSdk.init(
      "applicationId",
      "accessKey",
      "apiUrl",
      "feedbackUrl",
      null,
      debugLogging: false,
    );

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> _onShowButtonPressed() async {
    var callback = await feedbackSdk.show(
        viewMode: ViewMode.bottomSheetMode,
        title: "Flutter Title Test",
        titleFontSize: 20,
        flowId: "",
        language: "language",
        customer: {},
        payload: {});
    log(callback.toString());
  }

  Future<void> _onTrackButtonPressed() async {
    var callback = await feedbackSdk.track("view_promo",
        customer: {}, payload: {}, language: "language");
    log(callback.toString());
  }

  void _onClearButtonPressed() {
    feedbackSdk.clear();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                  height: 20), // Add some vertical spacing between the buttons
              ElevatedButton(
                onPressed: _onShowButtonPressed,
                child: const Text('Show'),
              ),
              const SizedBox(
                  height: 20), // Add some vertical spacing between the buttons
              ElevatedButton(
                onPressed: _onTrackButtonPressed,
                child: const Text('Track'),
              ),
              const SizedBox(
                  height: 20), // Add some vertical spacing between the buttons
              ElevatedButton(
                onPressed: _onClearButtonPressed,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
