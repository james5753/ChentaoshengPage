import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class FullScreenDialog extends StatefulWidget {
  final dynamic item;
  final List<String> imageUrls;

  FullScreenDialog({required this.item, required this.imageUrls});

  @override
  _FullScreenDialogState createState() => _FullScreenDialogState();
}

class _FullScreenDialogState extends State<FullScreenDialog> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 18.0, color: Colors.white);

    return Scaffold(
      backgroundColor: Colors.grey[900], // 设置背景颜色为深灰色
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: widget.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Image.network(widget.imageUrls[index]),
                          ),
                        );
                      },
                      onPageChanged: (index) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                      physics: NeverScrollableScrollPhysics(),
                    ),
                    Positioned(
                      left: 16.0,
                      top: MediaQuery.of(context).size.height / 2 - 24,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
                        onPressed: _currentPageIndex > 0
                            ? () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 16.0,
                      top: MediaQuery.of(context).size.height / 2 - 24,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward, color: Colors.white, size: 30.0),
                        onPressed: _currentPageIndex < widget.imageUrls.length - 1
                            ? () {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField('标题', widget.item['title'], textStyle),
                        _buildField('日期', widget.item['date'], textStyle),
                        _buildField('责任者', widget.item['责任者'], textStyle),
                        _buildField('范围与提要', widget.item['内容摘要'], textStyle),
                        _buildField('页数', widget.item['页数'], textStyle),
                        _buildField('主题词或关键词', widget.item['主题词或关键词'], textStyle),
                        _buildField('附注', widget.item['附注'], textStyle),
                        _buildField('档案保管沿革', widget.item['档案保管沿革'], textStyle),
                        SizedBox(height: 16.0),
                        _buildDownloadLink(Uri.parse(widget.item['md_url']), textStyle),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String? value, TextStyle textStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: textStyle.copyWith(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: value ?? '无数据',
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  Widget _buildDownloadLink(Uri uri, TextStyle textStyle) {
    return GestureDetector(
      onTap: () => _launchURL(uri),
      child: RichText(
        text: TextSpan(
          text: '下载文字版',
          style: textStyle.copyWith(
            decoration: TextDecoration.underline,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}