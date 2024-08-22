import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';
import 'dart:io' show Platform;

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final dynamic _controller;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse('https://uploads.knightlab.com/storymapjs/9225aae001d3e5974e45e6258b821782/chentaosheng-story-map/index.html'));
    } else if (Platform.isWindows) {
      _controller = WebviewController();
      _initWindowsWebView();
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse('https://uploads.knightlab.com/storymapjs/9225aae001d3e5974e45e6258b821782/chentaosheng-story-map/index.html'));
    }
  }

  Future<void> _initWindowsWebView() async {
    await _controller.initialize();
    await _controller.loadUrl('https://uploads.knightlab.com/storymapjs/9225aae001d3e5974e45e6258b821782/chentaosheng-story-map/index.html');
    // Inject JavaScript to enable scrolling with mouse wheel
    await _controller.executeScript('''
      window.addEventListener('wheel', function(event) {
        if (event.deltaY < 0) {
          window.scrollBy(0, -100); // Scroll up
        } else {
          window.scrollBy(0, 100); // Scroll down
        }
      });
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('故事模式'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 228, 206, 206),
        titleTextStyle: TextStyle(
          fontFamily: 'Tenor',
          color: Color.fromARGB(255, 113, 84, 79),
          fontSize: 20.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: _buildWebView(),
      ),
    );
  }

  Widget _buildWebView() {
    if (Platform.isWindows) {
      return Webview(_controller);
    } else {
      return WebViewWidget(controller: _controller);
    }
  }
}
