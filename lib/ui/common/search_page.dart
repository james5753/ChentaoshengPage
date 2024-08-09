import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
/*
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _queryType = 'subject';
  List<dynamic> _results = [];

  Future<void> _fetchResults() async {
    final response = await http.get(Uri.parse('https://search-oihidiiqud.cn-shanghai.fcapp.run?$_queryType=${_controller.text}'));

    if (response.statusCode == 200) {
      setState(() {
        print('响应体: ${response.body}'); // 打印响应体
        _results = json.decode(response.body);
      });
    } else {
      setState(() {
        _results = [];
      });
      throw Exception('Failed to load results');
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Query App'),
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
                    DropdownButton<String>(
                      value: _queryType,
                      onChanged: (String? newValue) {
                        setState(() {
                          _queryType = newValue!;
                        });
                      },
                      items: <String>['subject', 'title']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      isExpanded: true,
                    ),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Enter query',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _fetchResults,
                      child: Text('Search'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final item = _results[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                              onTap: () => _launchURL(item['cover_url']),
                              child: Text(
                                '查看图片',
                                style: TextStyle(color: Colors.blue),
                                     ),
                              ),
                      //         item['cover_url'] != null
                      //             ? Image.network(item['cover_url'])
                      //             : SizedBox.shrink(),
                              SizedBox(height: 8.0),
                              Text(
                                item['title'] ?? 'No Title',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                item['date'] ?? 'No Date',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 8.0),
                              item['note'] != null
                                  ? Text(item['note'])
                                  : SizedBox.shrink(),
                              SizedBox(height: 8.0),
                              item['manifest_url'] != null
                                  ? GestureDetector(
                                onTap: () => _launchURL(item['manifest_url']),
                                child: Text(
                                  'Manifest URL: ${item['manifest_url']}',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              )
                                  : SizedBox.shrink(),
                              item['md_url'] != null
                                  ? GestureDetector(
                                onTap: () => _launchURL(item['md_url']),
                                child: Text(
                                  'MD URL: ${item['md_url']}',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              )
                                  : SizedBox.shrink(),
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
*/

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _queryType = 'subject';
  List<dynamic> _results = [];

  Future<void> _fetchResults() async {
    final response = await http.get(Uri.parse('https://search-oihidiiqud.cn-shanghai.fcapp.run?$_queryType=${_controller.text}'));

    if (response.statusCode == 200) {
      setState(() {
        print('响应体: ${response.body}'); // 打印响应体
        _results = json.decode(response.body);
      });
    } else {
      setState(() {
        _results = [];
      });
      throw Exception('Failed to load results');
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API查询应用'),
        centerTitle: true,
        automaticallyImplyLeading: false, // 取消按钮回退的功能
        backgroundColor: Color.fromARGB(255, 221, 160, 160), // 设置AppBar的背景颜色
        titleTextStyle: TextStyle(
          color: Color.fromARGB(168, 0, 0, 0), // 设置标题文字颜色
          fontSize: 20.0, // 设置标题文字大小
          fontWeight: FontWeight.bold, // 设置标题文字粗细
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
                    DropdownButton<String>(
                      value: _queryType,
                      onChanged: (String? newValue) {
                        setState(() {
                          _queryType = newValue!;
                        });
                      },
                      items: <String>['subject', 'title']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      isExpanded: true,
                    ),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Enter query',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _fetchResults,
                      child: Text('Search'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final item = _results[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: () => _launchURL(item['cover_url']),
                                child: Text(
                                  '查看图片',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                item['title'] ?? 'No Title',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                item['date'] ?? 'No Date',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 8.0),
                              item['note'] != null
                                  ? Text(item['note'])
                                  : SizedBox.shrink(),
                              SizedBox(height: 8.0),
                              item['manifest_url'] != null
                                  ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JsonDisplayPage(manifestUrl: item['manifest_url']),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Manifest URL: ${item['manifest_url']}',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              )
                                  : SizedBox.shrink(),
                              item['md_url'] != null
                                  ? GestureDetector(
                                onTap: () => _launchURL(item['md_url']),
                                child: Text(
                                  'MD URL: ${item['md_url']}',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              )
                                  : SizedBox.shrink(),
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

class JsonDisplayPage extends StatelessWidget {
  final String manifestUrl;

  JsonDisplayPage({required this.manifestUrl});

  Future<Map<String, dynamic>> _fetchJson() async {
    final response = await http.get(Uri.parse(manifestUrl));
    if (response.statusCode == 200) {
      // 使用 utf8.decode 确保正确解析中文字符
      final decodedResponse = utf8.decode(response.bodyBytes);
      return json.decode(decodedResponse);
    } else {
      throw Exception('Failed to load JSON');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JSON Viewer', style: TextStyle(color: Colors.black)),
        //backgroundColor: Colors.white, // 如果需要更改 AppBar 的背景颜色
        //iconTheme: IconThemeData(color: Colors.black), // 如果需要更改 AppBar 图标的颜色
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchJson(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.black)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found', style: TextStyle(color: Colors.black)));
          } else {
            final jsonData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: jsonData.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key, style: TextStyle(color: Colors.black)),
                    subtitle: Text(entry.value.toString(), style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}