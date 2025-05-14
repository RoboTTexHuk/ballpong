import 'dart:convert';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart'
    show AppTrackingTransparency, TrackingStatus;
import 'package:appsflyer_sdk/appsflyer_sdk.dart'
    show AppsFlyerOptions, AppsflyerSdk;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;

import 'main_push.dart' show FunnyMainWebScreenPUSH;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_pushCircusBackgroundTrampoline);

  if (Platform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  tzData.initializeTimeZones();

  runApp(const MaterialApp(home: FunnyPushInitPage()));
}

// FCM Background Handler
@pragma('vm:entry-point')
Future<void> _pushCircusBackgroundTrampoline(RemoteMessage giggleMsg) async {
  print("🤡 BG Message: ${giggleMsg.messageId}");
  print("🤡 BG Data: ${giggleMsg.data}");
}

/// MODEL
class FunnyDeviceModel {
  String? bananaId;
  String? circusInstance = "d67f-banana-1234-chimp";
  String? osType;
  String? osVersion;
  String? appVersion;
  String? monkeyLanguage;
  String? monkeyTimezone;
  bool pushEnabled = true;

  Future<void> initBanana() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      bananaId = info.id;
      osType = "android";
      osVersion = info.version.release;
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      bananaId = info.identifierForVendor;
      osType = "ios";
      osVersion = info.systemVersion;
    }
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    monkeyLanguage = Platform.localeName.split('_')[0];
    monkeyTimezone = tz.local.name;
  }

  Map<String, dynamic> toJungleMap({String? fcmBananaToken}) {
    return {
      "fcm_token": fcmBananaToken ?? 'no_fcm_banana',
      "device_id": bananaId ?? 'no_banana',
      "app_name": "ballpong",
      "instance_id": circusInstance ?? 'no_circus',
      "platform": osType ?? 'no_type',
      "os_version": osVersion ?? 'no_os',
      "app_version": appVersion ?? 'no_app',
      "language": monkeyLanguage ?? 'en',
      "timezone": monkeyTimezone ?? 'UTC',
      "push_enabled": pushEnabled,
    };
  }
}

/// APPSFLYER VIEWMODEL
class AppsflyerCircusViewModel extends ChangeNotifier {
  AppsflyerSdk? funnyFlyerSdk;
  String clownId = "";
  String clownConversion = "";

  void startCircus(VoidCallback onUpdate) {
    final funnyOptions = AppsFlyerOptions(
      afDevKey: "qsBLmy7dAXDQhowM8V3ca4",
      appId: "6745902875",
      showDebug: true,
    );
    funnyFlyerSdk = AppsflyerSdk(funnyOptions);
    funnyFlyerSdk?.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    funnyFlyerSdk?.startSDK(
      onSuccess: () => print("🎪 AppsFlyer started"),
      onError: (int code, String msg) => print("🎪 AppsFlyer error $code $msg"),
    );
    funnyFlyerSdk?.onInstallConversionData((result) {
      clownConversion = result.toString();
      clownId = result['payload']['af_status'].toString();
      onUpdate();
    });
    funnyFlyerSdk?.getAppsFlyerUID().then((val) {
      clownId = val.toString();
      onUpdate();
    });
  }
}

/// PUSH VIEWMODEL
class PushClownViewModel extends ChangeNotifier {
  String? pushNoseToken;

  void listenForBananaToken(Function(String token) onBananaToken) {
    const MethodChannel('com.example.fcm/token').setMethodCallHandler((call) async {
      if (call.method == 'setToken') {
        final String token = call.arguments as String;
        onBananaToken(token);
      }
    });
  }
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: LiquidCircularProgressIndicator(
        value: 0.25, // Defaults to 0.5.
        valueColor: AlwaysStoppedAnimation(Colors.pink), // Defaults to the current Theme's accentColor.
        backgroundColor: Colors.white, // Defaults to the current Theme's backgroundColor.
        borderColor: Colors.red,
        borderWidth: 5.0,
        direction: Axis.horizontal, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
        center: Text("Loading..."),
      )),
    );
  }
}

/// MAIN WEB SCREEN (View)
class FunnyMainWebScreen extends StatefulWidget {
  final String? pushNoseToken;
  const FunnyMainWebScreen({super.key, required this.pushNoseToken});

  @override
  State<FunnyMainWebScreen> createState() => _FunnyMainWebScreenState();
}

class _FunnyMainWebScreenState extends State<FunnyMainWebScreen> {
  late InAppWebViewController bananaWebView;
  bool juggling = false;
  final String circusUrl = "https://gameplay.ballpong.click";

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
        "fb_app_name": "ballpong",
        "app_name": "ballpong",
        "deep": null,
        "bundle_identifier": "com.ballponng.pongballl.ballpong",
        "app_version": "1.0.0",
        "apple_id": "6745902875",
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

