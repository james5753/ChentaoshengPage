import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString('<iframe src="https://uploads.knightlab.com/storymapjs/9225aae001d3e5974e45e6258b821782/chentaosheng-story-map/index.html" width="100%" height="100%" style="border:none; min-height: 100vh;"></iframe>');
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse('https://uploads.knightlab.com/storymapjs/9225aae001d3e5974e45e6258b821782/chentaosheng-story-map/index.html'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('故事模式'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 221, 160, 160),
        titleTextStyle: TextStyle(
          color: Color.fromARGB(168, 0, 0, 0),
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}