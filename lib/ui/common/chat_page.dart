import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:wonders/logic/data/wonder_data.dart';
import 'package:wonders/logic/data/wonders_data/great_wall_data.dart';
import 'package:wonders/ui/screens/home_menu/home_menu.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  final List<String> questions = [
    '陈騊声曾在哪里求学',
    '陈騊声曾在哪里工作',
    '陈騊声从事过哪方面的工作',
    '陈騊声如何推动我国相关教育事业的发展',
    '陈騊声先生曾出版过什么书',
    '为什么陈騊声说自己是编书而不是著书',
    '陈騊声是否参加过政治活动，参加过哪些',
    '整风运动后陈騊声先生思想上有哪些转变',
    '请列举出陈騊声先生受过的奖励',
    '陈騊声在发酵工业方面有哪些成果和建树',
    '简述一下陈騊声在酿酒，酱油制造，制糖方面的贡献',
    '在制糖厂，陈騊声是如何战胜渡边改善了酒精酿造技术',
    '对于酱油酿造技术、谷氨酸发酵陈騊声先生有什么贡献',
    '陈騊声先生的自我评价',
    '陈騊声对于理论研究和应用研究的看法',
    '解放对于陈騊声先生有什么影响',
    '我国发酵工业在解放前后有什么改变，有什么影响',
    '陈騊声作为一个酷爱诗文的科学家，举一些他创作的诗句',
    '陈騊声与林志钧之间是什么关系，有什么故事吗?',
  ];

  final types.User _user = types.User(id: 'user-id');
  String _selectedApi = 'GraphRAG';

  Future<void> _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    String apiUrl;
    if (_selectedApi == 'GraphRAG') {
      apiUrl = 'https://graphrag-adbjhlgvps.us-west-1.fcapp.run';
    } else {
      apiUrl = 'https://cts-rag-hfmcjjwges.cn-hangzhou.fcapp.run/query';
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json', 'Accept-Charset': 'utf-8'},
      body: jsonEncode({
        'prompt': message.text,
        if (_selectedApi == 'GraphRAG') 'scope': 'local' else 'question': message.text,
      }),
    );

    if (response.statusCode == 200) {
      print('请求成功，状态码: ${response.statusCode}');
      print('响应体: ${response.body}');

      try {
        final utf8Body = utf8.decode(response.bodyBytes);
        dynamic responseData;
        try {
          responseData = jsonDecode(utf8Body);
        } catch (e) {
          responseData = utf8Body;
        }

        String aiMessageText = '';
        List<InlineSpan> aiMessageSpans = [];
        if (_selectedApi == 'ClassicRAG' && responseData is Map) {
          if (responseData.containsKey('answer')) {
            aiMessageText += '回答: ${responseData['answer']}\n\n';
          }
          if (responseData.containsKey('documents')) {
            final documents = responseData['documents'];
            for (var doc in documents) {
              final title = doc['title'] ?? 'No title';
              aiMessageText += '图片: $title\n';
              final m3Url = doc['m3_url'] ?? '';
              if (m3Url.isNotEmpty) {
                aiMessageText += '链接: $m3Url\n';
              }
              aiMessageText += '\n';
            }
          }
        } else {
          aiMessageText = responseData is Map && responseData.containsKey('response')
              ? '${responseData['response']}'
              : '$responseData';
        }

        // 提取人名和链接
        final nameRegex = RegExp(r'@([^@]+)@');
        final linkRegex = RegExp(r'\$([^$]+)\$');

        final names = nameRegex.allMatches(aiMessageText).map((match) => match.group(1)).toList();
        final links = linkRegex.allMatches(aiMessageText).map((match) => match.group(1)).toList();

        // 替换掉回答中的 @ 和 $ 符号，同时保留人名
        aiMessageText = aiMessageText.replaceAllMapped(nameRegex, (match) => match.group(1) ?? '');
        aiMessageText = aiMessageText.replaceAll(linkRegex, '');

        // 添加相关人物和链接信息
        if (names.isNotEmpty && links.isNotEmpty) {
          aiMessageText += '\n相关人物：${names.join(', ')}\n';
          aiMessageText += '链接：${links.join(', ')}\n';
        }

        final aiMessage = types.TextMessage(
          author: types.User(id: 'ai-id', firstName: _selectedApi),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: Uuid().v4(),
          text: aiMessageText.trim(),
        );

        setState(() {
          _messages.insert(0, aiMessage);
        });
      } catch (e) {
        print('解析响应失败: $e');
        final errorMessage = types.TextMessage(
          author: types.User(id: 'ai-id', firstName: _selectedApi),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: Uuid().v4(),
          text: '解析响应失败，请稍后再试。',
        );

        setState(() {
          _messages.insert(0, errorMessage);
        });
      }
    } else {
      print('请求失败，状态码: ${response.statusCode}');
      print('响应体: ${response.body}');

      final errorMessage = types.TextMessage(
        author: types.User(id: 'ai-id', firstName: _selectedApi),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: Uuid().v4(),
        text: '发送消息失败，请稍后再试。',
      );

      setState(() {
        _messages.insert(0, errorMessage);
      });
    }
  }

  String currentQuestion1 = '陈騊声曾在哪里求学';
  String currentQuestion2 = '陈騊声曾在哪里工作';

  String getRandomQuestion() {
    final random = Random();
    int index = random.nextInt(questions.length);
    return questions[index];
  }

  void updateQuestion() {
    setState(() {
      currentQuestion1 = getRandomQuestion();
      currentQuestion2 = getRandomQuestion();
      if (currentQuestion1.length < currentQuestion2.length) {
        String temp = currentQuestion1;
        currentQuestion1 = currentQuestion2;
        currentQuestion2 = temp;
      }
    });
  }

  void _sendSuggestedMessage(String text) {
    final message = types.PartialText(text: text);
    _handleSendPressed(message);
    print(message);
  }

  void _handleMessageTap(BuildContext context, types.Message message) {
    if (message is types.TextMessage) {
      final urlPattern = RegExp(
          r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
      final match = urlPattern.firstMatch(message.text);
      if (match != null) {
        final url = match.group(0);
        if (url != null) {
          if (url.endsWith('.jpg') || url.endsWith('.png') || url.endsWith('.jpeg') || url.endsWith('.gif')) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '图片预览',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Image.network(
                        url,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          }
                        },
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return const Text('图片加载失败');
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            _launchURL(url);
          }
        }
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
      );
    } else {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9ECE4),
      appBar: AppBar(
        title: Text('AI聊天'),
        centerTitle: true,
        backgroundColor: Color(0xFF642828),
        titleTextStyle: TextStyle(
          fontFamily: 'Tenor',
          color: Color(0xFFFFFFFF),
          fontSize: 20.0,
          fontWeight: FontWeight.normal,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => HomeMenu(data: GreatWallData()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          child: Transform.translate(
            offset: Offset(20.0, 0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(26.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20.0),
                    DropdownButton<String>(
                      value: _selectedApi,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedApi = newValue!;
                        });
                      },
                      items: <String>['GraphRAG', 'ClassicRAG']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.0),
                Expanded(
                  child: Chat(
                    messages: _messages,
                    onSendPressed: _handleSendPressed,
                    user: _user,
                    onMessageTap: _handleMessageTap, // 启用 onMessageTap 处理消息点击
                    inputOptions: InputOptions(
                      sendButtonVisibilityMode: SendButtonVisibilityMode.editing,
                    ),
                    theme: DefaultChatTheme(
                          primaryColor: Colors.blue,
                          secondaryColor: Color.fromARGB(255, 231, 231, 231),
                          backgroundColor: Colors.white,
                          messageBorderRadius: 15.0,
                          inputBackgroundColor: Colors.white,
                          inputTextColor: Colors.black,
                          inputBorderRadius: BorderRadius.circular(15.0),
                          inputTextStyle: TextStyle(fontSize: 16.0),
                          inputContainerDecoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(color: Color.fromARGB(136, 136, 126, 138), width: 1.0),
                          ),
                          messageMaxWidth: MediaQuery.of(context).size.width * 0.7,
                          //receivedMessageBodyTextStyle: TextStyle(color: _selectedApi == 'ClassicRAG'?Color(0xFF642828):Color(0xFF6C795B))
                        ),
                        showUserAvatars: false,
                        showUserNames: true,
                  ),
                ),
               SizedBox(height: 20.0),
                    Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 5.0,
                      runSpacing: 5.0,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6C795B), // 浅灰色背景
                              foregroundColor: Colors.white, // 黑色文字
                            ),
                            onPressed: () => _sendSuggestedMessage(currentQuestion1),
                            child: Text(currentQuestion1),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6C795B), // 浅灰色背景
                              foregroundColor: Colors.white, // 黑色文字
                            ),
                            onPressed: () => _sendSuggestedMessage(currentQuestion2),
                            child: Text(currentQuestion2),
                          ),
                        ),

                        IconButton(
                          onPressed: updateQuestion,
                          icon: Icon(Icons.refresh),
                          tooltip: '换一些问题',
                          color: Color(0xFF6C795B),
                          iconSize: 30.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
