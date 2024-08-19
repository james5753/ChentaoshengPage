import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString('''
          <html>
            <body style="margin:0;padding:0;">
              <iframe src="http://47.120.56.163:7474/browser/"></iframe>
            </body>
          </html>
        ''');
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse('http://47.120.56.163:7474/browser/'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('知识图谱'),
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