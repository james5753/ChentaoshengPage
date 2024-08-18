import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';

class WebImage extends StatelessWidget {
  final String url;

  WebImage(this.url);

  @override
  Widget build(BuildContext context) {
    String _divId = "web_image_" + DateTime.now().toIso8601String();
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _divId,
          (int viewId) => ImageElement(src: url),
    );

    return HtmlElementView(
      key: UniqueKey(),
      viewType: _divId,
    );
  }
}
