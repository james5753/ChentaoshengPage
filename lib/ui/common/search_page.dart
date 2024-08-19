import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

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
      appBar: AppBar(
        title: Text('API查询应用'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 228, 206, 206),
        titleTextStyle: TextStyle(
          fontFamily: 'Tenor',
          color: Color.fromARGB(255, 113, 84, 79),
          fontSize: 20.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
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
                              label: Text(subject),
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
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: '输入标题',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _fetchResults,
                        child: Text('搜索'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 每行显示两张图片
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return AspectRatio(
                          aspectRatio: 1, // 使每个容器宽高比为1
                          child: Container(
                            child: Stack(
                              children: [
                                Image.network(
                                  item['cover_url'],
                                  fit: BoxFit.cover,
                                ),
                                Positioned.fill(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => FullScreenDialog(item: item),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      color: Colors.transparent, // 透明的容器捕获点击事件
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
class FullScreenDialog extends StatelessWidget {
  final dynamic item;

  FullScreenDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 18.0, color: Colors.white); // 放大字体

    return Scaffold(
      backgroundColor: Colors.grey[850], // 深灰色背景
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.0), // 留出空白
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.network(item['cover_url']),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField('标题', item['title'], textStyle),
                        _buildField('日期', item['date'], textStyle),
                        _buildField('责任者', item['责任者'], textStyle),
                        _buildField('范围与提要', item['内容摘要'], textStyle),
                        _buildField('页数', item['页数'], textStyle),
                        _buildField('主题词或关键词', item['主题词或关键词'], textStyle),
                        _buildField('附注', item['附注'], textStyle),
                        _buildField('档案保管沿革', item['档案保管沿革'], textStyle),
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
                  Navigator.of(context).pop(); // 关闭弹窗
                }
              },
              child: Container(
                padding: EdgeInsets.all(8.0), // 增加点击区域的大小
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
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: textStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '无',
              softWrap: true,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
