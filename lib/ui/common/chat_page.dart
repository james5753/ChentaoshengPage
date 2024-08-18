import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:flython/flython.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class QwenRAGModel extends Flython {
  static const int cmdRAGQuery = 1;

  Future<void> initializeModel() async {
    await initialize('Qwen2_RAG/Qwen_test.py', 'main', true);
  }

  Future<Map<String, dynamic>> queryRAGModel(String question) async {
    var command = {
      "cmd": cmdRAGQuery,
      "question": question,
    };
    return await runCommand(command);
  }
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  final types.User _user = types.User(id: 'user-id');
  final QwenRAGModel ragModel = QwenRAGModel(); // 实例化QwenRAGModel
  bool _isInitialized = false;

  // List of available models
  String _selectedModel = 'API Model'; // Default selected model
  final List<String> _models = ['API Model', 'Local Python Model'];

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
    '陈騊声作为一个酷爱诗文的科学家，举一些他创作的诗句'
  ];

  String currentQuestion1 = '陈騊声曾在哪里求学';
  String currentQuestion2 = '陈騊声曾在哪里工作';

  @override
  void initState() {
    super.initState();
    _initializeRAGModel();
  }

  Future<void> _initializeRAGModel() async {
    await ragModel.initializeModel();
    _isInitialized = true;
  }

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

    String aiMessageText = '';
    if (_selectedModel == 'API Model') {
      final response = await http.post(
        Uri.parse('https://graphrag-adbjhlgvps.us-west-1.fcapp.run'),
        headers: {'Content-Type': 'application/json', 'Accept-Charset': 'utf-8'},
        body: jsonEncode({
          'prompt': message.text,
          'scope': 'local',
        }),
      );

      if (response.statusCode == 200) {
        print('请求成功，状态码: ${response.statusCode}');
        print('响应体: ${response.body}'); // 打印响应体

        try {
          // 手动将响应体转换为 UTF-8 编码
          final utf8Body = utf8.decode(response.bodyBytes);

          // 尝试解析为 JSON
          dynamic responseData;
          try {
            responseData = jsonDecode(utf8Body);
          } catch (e) {
            responseData = utf8Body; // 如果 JSON 解析失败，直接使用文本
          }

          aiMessageText = responseData is Map && responseData.containsKey('response')
              ? '${responseData['response']}'
              : '$responseData';

          final aiMessage = types.TextMessage(
            author: types.User(id: 'ai-id', firstName: '陈騊声(AI)'),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: Uuid().v4(),
            text: aiMessageText,
          );

          setState(() {
            _messages.insert(0, aiMessage);
          });
        } catch (e) {
          print('解析响应失败: $e');
          final errorMessage = types.TextMessage(
            author: types.User(id: 'ai-id', firstName: '陈騊声(AI)'),
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
          author: types.User(id: 'ai-id', firstName: '陈騊声(AI)'),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: Uuid().v4(),
          text: '发送消息失败，请稍后再试。',
        );

        setState(() {
          _messages.insert(0, errorMessage);
        });
      }
    } else if (_selectedModel == 'Local Python Model') {
      if (!_isInitialized) {
        aiMessageText = '模型正在初始化，请稍后再试。';
      } else {
        try {
          final result = await ragModel.queryRAGModel(message.text);
          aiMessageText = result["answer"] ?? "无回应";
        } catch (e) {
          aiMessageText = "运行本地模型时出错: $e";
          print("Error running local model: $e");
        }
      }

      final aiMessage = types.TextMessage(
        author: types.User(id: 'ai-id', firstName: '陈騊声(AI)'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: Uuid().v4(),
        text: aiMessageText,
      );

      setState(() {
        _messages.insert(0, aiMessage);
      });
    }
  }

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI聊天'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 228, 206, 206),
        titleTextStyle: TextStyle(
          fontFamily: 'Tenor',
          color: Color.fromARGB(255, 113, 84, 79),
          fontSize: 20.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: _selectedModel,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedModel = newValue!;
                  });
                },
                items: _models.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Expanded(
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
                        children: [
                          SizedBox(height: 20.0),
                          Expanded(
                            child: Chat(
                              messages: _messages,
                              onSendPressed: _handleSendPressed,
                              user: _user,
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
                                messageMaxWidth: MediaQuery.of(context).size.width * 0.6,
                              ),
                              showUserAvatars: true,
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
                                  onPressed: () => _sendSuggestedMessage(currentQuestion1),
                                  child: Text(currentQuestion1),
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                                child: ElevatedButton(
                                  onPressed: () => _sendSuggestedMessage(currentQuestion2),
                                  child: Text(currentQuestion2),
                                ),
                              ),
                              IconButton(
                                onPressed: updateQuestion,
                                icon: Icon(Icons.refresh),
                                tooltip: '换一些问题',
                                color: Colors.lightBlue[200],
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
          ],
        ),
      ),
    );
  }
}
