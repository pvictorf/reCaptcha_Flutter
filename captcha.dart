import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Captcha extends StatefulWidget {
  Function onChallenge;

  Captcha({Key? key, required this.onChallenge}) : super(key: key);

  @override
  State<Captcha> createState() => _CaptchaState();
}

class _CaptchaState extends State<Captcha> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  final String site = 'YOUR_WEBSITE_CAPTCHA.HTML';
  final String apiKey = 'YOUR_RECAPTCHA_APIKEY';

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  void _webviewJavaScript(String fn) {
    _controller.future.then((webview) {
      webview.runJavascript(fn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0,
      height: 0,
      constraints: BoxConstraints(
          minHeight: 580,
          maxHeight: 580,
          minWidth: MediaQuery.of(context).size.width),
      child: WebView(
        backgroundColor: Colors.transparent,
        initialUrl: site,
        /*
        gestureRecognizers: Set()
          ..add(Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer())),
        */      
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: Set.from([
          JavascriptChannel(
              name: 'FlutterCaptcha',
              onMessageReceived: (JavascriptMessage token) {
                widget.onChallenge(token.message);
              })
        ]),
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        navigationDelegate: (url) {
          return NavigationDecision.prevent;
        },
        onPageFinished: (url) {
          _webviewJavaScript("document.body.style.background = 'transparent'");
          _webviewJavaScript(
              "document.body.innerHTML=`<div id='grcaptcha' style='transform: scale(0.77); -webkit-transform: scale(0.77); transform-origin: 0 0; -webkit-transform-origin: 0 0;'></div>`");
          _webviewJavaScript(
              "grecaptcha.render('grcaptcha', {'sitekey': '$apiKey', 'callback': (token) => FlutterCaptcha.postMessage(token)});");
          //_webviewJavaScript("grecaptcha.execute()");
        },
      ),
    );
  }
}
