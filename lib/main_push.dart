import 'dart:convert';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart'
    show AppTrackingTransparency, TrackingStatus;
import 'package:appsflyer_sdk/appsflyer_sdk.dart'
    show AppsFlyerOptions, AppsflyerSdk;
import 'package:ballpong/main.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;



// FCM Background Handler
@pragma('vm:entry-point')
Future<void> _pushCircusBackgroundTrampoline(RemoteMessage giggleMsg) async {
  print("🤡 BG Message: ${giggleMsg.messageId}");
  print("🤡 BG Data: ${giggleMsg.data}");
}



/// INIT PAGE (View)
class FunnyPushInitPage extends StatefulWidget {
  const FunnyPushInitPage({super.key});

  @override
  State<FunnyPushInitPage> createState() => _FunnyPushInitPageState();
}

class _FunnyPushInitPageState extends State<FunnyPushInitPage> {
  final pushClown = PushClownViewModel();

  @override
  void initState() {
    super.initState();

    pushClown.listenForBananaToken((funnyToken) {
      setState(() {});
      print('🥸 Push Token received: $funnyToken');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FunnyMainWebScreen(pushNoseToken: funnyToken),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// MAIN WEB SCREEN (View)
class FunnyMainWebScreenPUSH extends StatefulWidget {

 String urll;
 FunnyMainWebScreenPUSH({super.key, required this.urll,});

  @override
  _FunnyMainWebScreenPUSHState createState() => _FunnyMainWebScreenPUSHState(urll);
}

class _FunnyMainWebScreenPUSHState extends State<FunnyMainWebScreen> {
  late InAppWebViewController bananaWebView;
  bool juggling = false;
  String circusUrl;
  _FunnyMainWebScreenPUSHState(this.circusUrl);
  final jungleDevice = FunnyDeviceModel();
  final circusAppsFlyer = AppsflyerCircusViewModel();

  @override
  void initState() {
    super.initState();
    _startClownRoutine();
  }

  void _startClownRoutine() {
    _initPushFromBanana();
    _initMonkeyTransparency();
    circusAppsFlyer.startCircus(() => setState(() {}));
    _setupClownNotificationChannel();
    _initGadgets();
    // Повторная инициализация ATT через 2 сек
    Future.delayed(const Duration(seconds: 2), _initMonkeyTransparency);
    // Передача device/app данных в web через 6 сек
    Future.delayed(const Duration(seconds: 6), () {
      _sendBananaDataToWeb();
      _sendRawCircusDataToWeb();
    });
  }

  void _initPushFromBanana() {
    FirebaseMessaging.onMessage.listen((msg) {
      final uri = msg.data['uri'];
      if (uri != null) {
        _clownLoadUrl(uri.toString());
      } else {
        _reloadCircus();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      final uri = msg.data['uri'];
      if (uri != null) {
        _clownLoadUrl(uri.toString());
      } else {
        _reloadCircus();
      }
    });
  }

  void _setupClownNotificationChannel() {
    MethodChannel('com.example.fcm/notification')
        .setMethodCallHandler((call) async {
      if (call.method == "onNotificationTap") {
        final Map<String, dynamic> data = Map<String, dynamic>.from(call.arguments);
        final url = data["uri"];
        if (url != null && !url.contains("Нет URI")) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => FunnyMainWebScreenPUSH(urll: url)),
                (route) => false,
          );
        }
      }
    });
  }

  Future<void> _initGadgets() async {
    try {
      await jungleDevice.initBanana();
      await _initPushBananaMessaging();
      if (bananaWebView != null) {
        _sendBananaDataToWeb();
      }
    } catch (e) {
      debugPrint("🐒 Device data init error: $e");
    }
  }

  Future<void> _initPushBananaMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> _initMonkeyTransparency() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 1000));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("🙈 ATT AdvertisingIdentifier: $uuid");
  }

  void _clownLoadUrl(String uri) async {
    if (bananaWebView != null) {
      await bananaWebView.loadUrl(
        urlRequest: URLRequest(url: WebUri(uri)),
      );
    }
  }

  void _reloadCircus() async {
    Future.delayed(const Duration(seconds: 3), () {
      if (bananaWebView != null) {
        bananaWebView.loadUrl(
          urlRequest: URLRequest(url: WebUri(circusUrl)),
        );
      }
    });
  }

  Future<void> _sendBananaDataToWeb() async {
  print("");
    setState(() => juggling = true);
    try {
      final funnyMap = jungleDevice.toJungleMap(fcmBananaToken: widget.pushNoseToken);
      await bananaWebView.evaluateJavascript(source: '''
      localStorage.setItem('app_data', JSON.stringify(${jsonEncode(funnyMap)}));
      ''');
    } finally {
      setState(() => juggling = false);
    }
  }

  Future<void> _sendRawCircusDataToWeb() async {
    final funnyData = {
      "content": {
        "af_data": circusAppsFlyer.clownConversion,
        "af_id": circusAppsFlyer.clownId,
        "fb_app_name": "indicricket",
        "app_name": "indicricket",
        "deep": null,
        "bundle_identifier": "com.koilktoil.crickeindicator",
        "app_version": "1.0.0",
        "apple_id": "6745818621",
        "fcm_token": widget.pushNoseToken ?? "no_fcm_banana",
        "device_id": jungleDevice.bananaId ?? "no_banana",
        "instance_id": jungleDevice.circusInstance ?? "no_circus",
        "platform": jungleDevice.osType ?? "no_type",
        "os_version": jungleDevice.osVersion ?? "no_os",
        "app_version": jungleDevice.appVersion ?? "no_app",
        "language": jungleDevice.monkeyLanguage ?? "en",
        "timezone": jungleDevice.monkeyTimezone ?? "UTC",
        "push_enabled": jungleDevice.pushEnabled,
        "useruid": circusAppsFlyer.clownId,
      },
    };
    final jsonString = jsonEncode(funnyData);
    print("🎪 SendRawData: $jsonString");

    await bananaWebView.evaluateJavascript(
      source: "sendRawData(${jsonEncode(jsonString)});",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              InAppWebView(
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  disableDefaultErrorPage: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  allowsPictureInPictureMediaPlayback: true,
                  useOnDownloadStart: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                ),
                initialUrlRequest: URLRequest(url: WebUri(circusUrl)),
                onWebViewCreated: (controller) {
                  bananaWebView = controller;
                  bananaWebView.addJavaScriptHandler(
                    handlerName: 'onServerResponse',
                    callback: (args) {
                      print("🎪 JS args: $args");
                      return args.reduce((curr, next) => curr + next);
                    },
                  );
                },
                onLoadStart: (controller, url) {
                  setState(() => juggling = true);
                },
                onLoadStop: (controller, url) async {
                  await controller.evaluateJavascript(
                    source: "console.log('🎪 Hello from JS!');",
                  );
                  await _sendBananaDataToWeb();
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  return NavigationActionPolicy.ALLOW;
                },
              ),
              if (juggling)
                const Center(
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}