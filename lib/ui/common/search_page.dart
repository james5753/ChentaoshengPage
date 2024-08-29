import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wonders/ui/common/display.dart';
import 'dart:math';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // 导入 flutter_staggered_grid_view 包
import 'package:wonders/logic/data/wonders_data/great_wall_data.dart';
import 'package:wonders/ui/screens/home_menu/home_menu.dart';

double getRandomWidth(int index) {
  Random random = Random(index);
  return 1 + random.nextDouble() * 0.3;
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
  final List<String> _subjects = [
    '杂志文稿',
    '学术成果',
    '报告、提案及复文',
    '思想见解',
    '照片',
    '文集'
  ];

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
    //_controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800], // 设置整体背景颜色为深灰色
      appBar: AppBar(
        title: Text('文档查询'),
        centerTitle: true,
        backgroundColor: Colors.black87,
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: SizedBox(
              width: 180.0, // 设置宽度
              child: DropdownButton<String>(
                alignment: Alignment.center,
                value: _selectedSubject,
                hint: Text(
                  '请选择主题',
                  style: TextStyle(color: Colors.white),
                ),
                dropdownColor: Colors.grey[800], // 设置下拉菜单背景颜色
                elevation: 24,
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                isExpanded: true,
                borderRadius: BorderRadius.circular(8.0),
                items: _subjects.map((String subject) {
                  return DropdownMenuItem<String>(
                    alignment: Alignment.center,
                    value: subject,
                    child: Text(
                      subject,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubject = newValue;
                    // 选择后立即触发搜索
                    _fetchResults();
                  });
                },
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: '输入标题',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white), // 设置边框颜色
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white), // 设置未选中时的边框颜色
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white), // 设置选中时的边框颜色
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear, color: Colors.white,size:16),
                                onPressed: () {
                                  _controller.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0), // Add space between the TextField and ElevatedButton
                        IconButton(
                          onPressed: _fetchResults,
                          icon: Icon(Icons.search),
                          color: Colors.white, // Icon color
                          tooltip: '搜索',
                        )
                      ],
                    ),
                    SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;
                      int crossAxisCount = (screenWidth / 200).ceil();
                      double itemWidth = screenWidth / crossAxisCount +40;

                      return MasonryGridView.builder(
                        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                        ),
                        crossAxisSpacing: 15.0,
                        mainAxisSpacing: 15.0,
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final item = _results[index];
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