import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // 导入 flutter_staggered_grid_view 包
import 'package:wonders/logic/data/wonders_data/great_wall_data.dart';
import 'package:wonders/ui/screens/home_menu/home_menu.dart';


double getRandomWidth(int index) {
  Random random = Random(index);
  return 1.5 + random.nextDouble() * 0.8;
}

// 生成长度为 50 的数组
List<double> generateRandomArray(int length) {
  List<double> randomArray = [];
  for (int i = 0; i < length; i++) {
    randomArray.add(getRandomWidth(i));
  }
  return randomArray;
}
List<double> itemHeight = generateRandomArray(50);
Future<List<String>> fetchImageUrls(String manifestUrl) async {
  final response = await http.get(Uri.parse(manifestUrl));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    List<String> imageUrls = [];

    for (var item in data['items']) {
      var annotationPage = item['items'][0];
      for (var annotation in annotationPage['items']) {
        var imageBody = annotation['body'];
        if (imageBody['type'] == 'Image') {
          imageUrls.add(imageBody['id']);
        }
      }
    }

    return imageUrls;
  } else {
    throw Exception('Failed to load JSON data');
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedSubject;
  List<dynamic> _results = [];

  Future<void> _fetchResults() async {
    String subjectQuery = _selectedSubject ?? '';

    final response = await http.get(Uri.parse(
        'https://search-oihidiiqud.cn-shanghai.fcapp.run?subject=$subjectQuery&title=${_controller.text}'));

    if (response.statusCode == 200) {
      setState(() {
        print('响应体: ${json.decode(response.body)}');
        _results = json.decode(response.body);
      });
    } else {
      setState(() {
        _results = [];
      });
      throw Exception('Failed to load results');
    }

    // Clear the text field after fetching results
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9ECE4), // 设置整体背景颜色为深灰色
      appBar: AppBar(
        title: Text('查询'),
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
           Positioned(
            right: 40,
            top: 10,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8.0,
                      children: [
                        for (String subject in [
                          '杂志文稿',
                          '学术成果',
                          '报告、提案及复文',
                          '思想见解',
                          '照片',
                          '文集'
                        ])
                          ChoiceChip(
                            label: Text(
                              subject,
                              style: TextStyle(color: Colors.white), // Set text color to deep color
                            ),
                            selectedColor: Color(0xFF642828), // Set the color when selected
                            backgroundColor: Color(0xFF6C795B), // Set the background color when not selected
                            selected: _selectedSubject == subject,
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedSubject = selected ? subject : null;
                                // 选择后立即触发搜索
                                _fetchResults();
                              });
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: TextStyle(color: Color(0xFF642828)),
                            decoration: InputDecoration(
                              labelText: '输入标题',
                              labelStyle: TextStyle(color: Color(0xFF642828)),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF642828)), // 设置边框颜色
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF642828)), // 设置未选中时的边框颜色
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF642828)), // 设置选中时的边框颜色
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0), // Add space between the TextField and ElevatedButton
                        ElevatedButton(
                          onPressed: _fetchResults,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6C795B), // Button color
                            foregroundColor: Colors.white, // Text color
                          ),
                          child: Text('搜索'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;
                      int crossAxisCount = (screenWidth / 200).ceil();
                      double itemWidth = screenWidth / crossAxisCount ;

                      return MasonryGridView.builder(
                        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                        ),
                        crossAxisSpacing: 30.0,
                        mainAxisSpacing: 30.0,
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final item = _results[index];
//                        double itemHeight = itemWidth * (1 + 0.5 + random.nextDouble() * 0.8); // 高度随机，确保不同
                          return SizedBox(
                            width: itemWidth,
                            height: itemHeight[index] * itemWidth,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24.0), // 增大圆角范围
                                child: Stack(
                                  children: [
                                    Container(
                                      color: Colors.grey[300], // 设置背景颜色为灰色
                                      child: Image.network(
                                        item['cover_url'],
                                        fit: BoxFit.cover,
                                        width: double.infinity, // force image to fill area
                                        height: double.infinity,
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: GestureDetector(
                                        onTap: () async {
                                          final imageUrls = await fetchImageUrls(item['manifest_url']);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => FullScreenDialog(item: item, imageUrls: imageUrls),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

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
                        _buildDownloadLink(widget.item['md_url'], textStyle),
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

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildDownloadLink(String? url, TextStyle textStyle) {
    if (url == null || url.isEmpty) return SizedBox.shrink();

    return GestureDetector(
      onTap: () => _launchURL(url),
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
