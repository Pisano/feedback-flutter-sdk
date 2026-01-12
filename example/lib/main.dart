import 'dart:async';
import 'dart:developer';

import 'package:feedback_flutter_sdk/feedback_flutter_sdk.dart';
import 'package:flutter/material.dart';

import 'pisano_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FeedbackFlutterSdk feedbackSdk = FeedbackFlutterSdk();
  bool _initialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we normalize in an async method.
  Future<void> initPlatformState() async {
    try {
      log('PisanoConfig: ${PisanoConfig.debugSummary()}');

      if (PisanoConfig.hasPlaceholders) {
        setState(() {
          _initialized = false;
          _initError =
              'PisanoConfig is not set. Provide values via --dart-define-from-file / --dart-define.\n'
              '${PisanoConfig.debugSummary()}';
        });
        return;
      }

      await feedbackSdk.init(
        PisanoConfig.applicationId,
        PisanoConfig.accessKey,
        PisanoConfig.apiUrl,
        PisanoConfig.feedbackUrl,
        PisanoConfig.eventUrl,
        debugLogging: PisanoConfig.debugLogging,
      );
      setState(() {
        _initialized = true;
        _initError = null;
      });
      log('Pisano init completed');
    } catch (e) {
      setState(() {
        _initialized = false;
        _initError = e.toString();
      });
      log('Pisano init failed: $e');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1677FF)),
        useMaterial3: true,
      ),
      home: HomeScreen(
        initialized: _initialized,
        initError: _initError,
        onRetryInit: initPlatformState,
        feedbackSdk: feedbackSdk,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
    required this.initialized,
    required this.initError,
    required this.onRetryInit,
    required this.feedbackSdk,
  }) : super(key: key);

  final bool initialized;
  final String? initError;
  final Future<void> Function() onRetryInit;
  final FeedbackFlutterSdk feedbackSdk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pisano',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 48),
                  _Card(
                    title: 'Feedback\nforms || flows\nfor business',
                    subtitle: 'Interact with flows made by Pisano',
                    buttonText: 'Getting Started',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => FeedbackFormScreen(
                            feedbackSdk: feedbackSdk,
                            initialized: initialized,
                            initError: initError,
                            onRetryInit: onRetryInit,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (!initialized)
                    _InitBanner(
                      initError: initError,
                      onRetry: onRetryInit,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.06,
                ),
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitBanner extends StatelessWidget {
  const _InitBanner({Key? key, required this.initError, required this.onRetry})
      : super(key: key);

  final String? initError;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final text = initError ??
        'SDK not initialized yet. Check your credentials and try again.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE69C)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5F4B00),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () async => onRetry(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({
    Key? key,
    required this.feedbackSdk,
    required this.initialized,
    required this.initError,
    required this.onRetryInit,
  }) : super(key: key);

  final FeedbackFlutterSdk feedbackSdk;
  final bool initialized;
  final String? initError;
  final Future<void> Function() onRetryInit;

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _phoneController = TextEditingController();
  final _externalIdController = TextEditingController();
  final _customTitleController = TextEditingController();

  ViewMode _viewMode = ViewMode.defaultMode;
  _TitleFont _titleFont = _TitleFont.title;
  _TitleColor _titleColor = _TitleColor.blue;

  FeedbackCallback? _lastShowStatus;

  @override
  void dispose() {
    _phoneController.dispose();
    _externalIdController.dispose();
    _customTitleController.dispose();
    super.dispose();
  }

  int? get _titleFontSize {
    switch (_titleFont) {
      case _TitleFont.title:
        return 20;
      case _TitleFont.body:
        return 16;
    }
  }

  Future<void> _onGetFeedbackPressed() async {
    if (!widget.initialized) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SDK not initialized yet.')),
      );
      return;
    }

    final customer = <String, dynamic>{
      if (_phoneController.text.trim().isNotEmpty)
        'phoneNumber': _phoneController.text.trim(),
      if (_externalIdController.text.trim().isNotEmpty)
        'externalId': _externalIdController.text.trim(),
    };

    final payload = <String, String>{
      'source': 'flutter_example',
    };

    final title = _customTitleController.text.trim();
    final callback = await widget.feedbackSdk.show(
      viewMode: _viewMode,
      title: title.isEmpty ? null : title,
      titleFontSize: _titleFontSize,
      flowId: '',
      language: PisanoConfig.language,
      customer: customer.isEmpty ? {} : customer,
      payload: payload,
    );

    setState(() {
      _lastShowStatus = callback;
    });
    log('show callback: $callback');
  }

  Future<void> _onTrackPressed() async {
    if (!widget.initialized) return;

    final callback = await widget.feedbackSdk.track(
      'view_promo',
      customer: {
        if (_externalIdController.text.trim().isNotEmpty)
          'externalId': _externalIdController.text.trim(),
      },
      payload: const {'source': 'flutter_example'},
      language: PisanoConfig.language,
    );
    log('track callback: $callback');
  }

  Future<void> _onClearPressed() async {
    await widget.feedbackSdk.clear();
    setState(() {
      _lastShowStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final headerStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        );

    return Scaffold(
        appBar: AppBar(
        title: const Text('Pisano'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(16),
          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.initialized)
                      _InitBanner(
                        initError: widget.initError,
                        onRetry: widget.onRetryInit,
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _externalIdController,
                      decoration: const InputDecoration(
                        labelText: 'External Id',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _customTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('View Mode', style: headerStyle),
                    const SizedBox(height: 8),
                    SegmentedButton<ViewMode>(
                      segments: const [
                        ButtonSegment(
                          value: ViewMode.defaultMode,
                          label: Text('Default'),
                        ),
                        ButtonSegment(
                          value: ViewMode.bottomSheetMode,
                          label: Text('BottomSheet'),
                        ),
                      ],
                      selected: {_viewMode},
                      onSelectionChanged: (s) =>
                          setState(() => _viewMode = s.first),
                    ),
                    const SizedBox(height: 18),
                    Text('Custom Title Color', style: headerStyle),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _TitleColor.values.map((c) {
                        final selected = c == _titleColor;
                        return GestureDetector(
                          onTap: () => setState(() => _titleColor = c),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _titleColorValue(c),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? cs.primary : Colors.black12,
                                width: selected ? 3 : 1,
                              ),
                            ),
                            child: selected
                                ? const Center(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Note: title color is a UI-only option in this Flutter example (plugin currently supports title + font size).',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                    ),
                    const SizedBox(height: 18),
                    Text('Title Font', style: headerStyle),
                    const SizedBox(height: 8),
                    SegmentedButton<_TitleFont>(
                      segments: const [
                        ButtonSegment(value: _TitleFont.title, label: Text('Title')),
                        ButtonSegment(value: _TitleFont.body, label: Text('Body')),
                      ],
                      selected: {_titleFont},
                      onSelectionChanged: (s) =>
                          setState(() => _titleFont = s.first),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _onGetFeedbackPressed,
                        child: const Text(
                          'Get Feedback',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _onTrackPressed,
                child: const Text('Track'),
              ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _onClearPressed,
                child: const Text('Clear'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Status: Show: ${_lastShowStatus == null ? '-' : _enumName(_lastShowStatus)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _TitleFont { title, body }

enum _TitleColor { gray, blue, green, yellow, slate, lightGray, darkGray, orange }

Color _titleColorValue(_TitleColor c) {
  switch (c) {
    case _TitleColor.gray:
      return const Color(0xFFBDBDBD);
    case _TitleColor.blue:
      return const Color(0xFF1677FF);
    case _TitleColor.green:
      return const Color(0xFF22C55E);
    case _TitleColor.yellow:
      return const Color(0xFFFACC15);
    case _TitleColor.slate:
      return const Color(0xFF64748B);
    case _TitleColor.lightGray:
      return const Color(0xFFD1D5DB);
    case _TitleColor.darkGray:
      return const Color(0xFF6B7280);
    case _TitleColor.orange:
      return const Color(0xFFF59E0B);
  }
}

String _enumName(Object? e) {
  if (e == null) return '-';
  final s = e.toString();
  final dot = s.lastIndexOf('.');
  return dot == -1 ? s : s.substring(dot + 1);
}
