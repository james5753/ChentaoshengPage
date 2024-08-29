import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';
import 'dart:io' show Platform;
import 'package:wonders/logic/data/wonders_data/great_wall_data.dart';
import 'package:wonders/ui/screens/home_menu/home_menu.dart';


class WebPage extends StatefulWidget {
  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  dynamic _controller;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString('''
          <html>
            <body style="margin:0;padding:0;">
              <iframe src="http://47.120.56.163:7474/browser/" style="width:100%;height:100%;border:none;"></iframe>
            </body>
          </html>
        ''');
      setState(() {});  // 更新状态以显示 WebView
    } else if (Platform.isWindows) {
      _controller = WebviewController();
      _initWindowsWebView();
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse('http://47.120.56.163:7474/browser/'));
      setState(() {});  // 更新状态以显示 WebView
    }
  }

  Future<void> _initWindowsWebView() async {
    await _controller.initialize();
    await _controller.loadUrl('http://47.120.56.163:7474/browser/');
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
    setState(() {});  // 初始化完成后更新状态以显示 WebView
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9ECE4),
      appBar: AppBar(
        title: Text('知识图谱'),
        centerTitle: true,
        backgroundColor: Color(0xFF642828),
        automaticallyImplyLeading: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Tenor',
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.normal,
        ),
        actions: [
           Container(
            margin: EdgeInsets.only(right: 16), // 调整位置
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6), // 设置背景颜色和透明度
              shape: BoxShape.circle, // 设置圆形背景
            ),
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.white), // 设置图标颜色为白色以便在黑色背景上可见
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => HomeMenu(data: GreatWallData()),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 0.0), // 设置左边的 padding
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: _buildWebView(),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    if (_controller == null) {
      // 控制器未初始化完成时显示加载指示器
      return Center(child: CircularProgressIndicator());
    }

    if (Platform.isWindows) {
      return Webview(_controller);
    } else {
      return WebViewWidget(controller: _controller);
    }
  }
}
