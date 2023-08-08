import 'dart:async';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'dart:developer' as developer;
import 'package:url_launcher/url_launcher.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aku Juara',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
          primarySwatch: Colors.blue,
          useMaterial3: true
      ),
      home: EasySplashScreen(
        durationInSeconds: 3,
        navigator: const MyHomePage(title: 'Aku Juara'),
        logo: Image.asset('images/logo.png'),
        backgroundColor: const Color(0xFF222939),
        loaderColor: Colors.white,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late final WebViewController controller;
  DateTime preBackpress = DateTime.now();
  late DatabaseReference _urlGameRef;
  bool initialized = false;

  @override
  void initState()  {
    init();
    super.initState();
  }

  Future<void> init() async {
    _urlGameRef = FirebaseDatabase.instance.ref("URL_GAMES_AKU_JUARA");
    final urlGameSnapshot = await _urlGameRef.get();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setNavigationDelegate(
          NavigationDelegate(
              onProgress: (int progress) {

              },
              onPageStarted: (String url) {

              },
              onPageFinished: (String url) {

              },
              onWebResourceError: (WebResourceError error) {

              },
              onNavigationRequest: (NavigationRequest request) {
                if (request.url
                    .startsWith('whatsapp://send')) {
                  developer.log(request.url, name:"url_wa");
                  whatsapp(Uri.parse(request.url));
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              }
          )
      )
      ..loadRequest(
          Uri.parse(urlGameSnapshot.value?.toString() ?? 'https://mobile--sprightly-youtiao-662b0f.netlify.app/')
      );
    setState(() {
      initialized = true;
    });
  }

  whatsapp(url) async{
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Fluttertoast.showToast(msg: "WhatsApp is not installed on the device");
    }
  }

  Future<bool> _willPopCallback() async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return Future.value(false);
    } else {
      final timegap = DateTime.now().difference(preBackpress);
      final cantExit = timegap >= const Duration(seconds: 2);
      preBackpress = DateTime.now();
      if(cantExit){
        Fluttertoast.showToast(msg: "Press again to exit");
        return false; // false will do nothing when back press
      }else{
        return true;   // true will exit the app
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) return Container();
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        body: WillPopScope(
            onWillPop: _willPopCallback,
            child: WebViewWidget(controller: controller))
    );
  }

}