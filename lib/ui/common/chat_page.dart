import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  final types.User _user = types.User(id: 'user-id');

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    // 模拟 AI 回复
    Future.delayed(Duration(seconds: 1), () {
      final aiMessage = types.TextMessage(
        author: types.User(id: 'ai-id', firstName: '陈騊声(AI)'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: Uuid().v4(),
        text: '这是 陈騊声(AI) 的回复: ${message.text}',
      );

      setState(() {
        _messages.insert(0, aiMessage);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 160.0), // 增加标题左边的间隔
          child: Text('AI聊天'),
        ),
        automaticallyImplyLeading: false, // 取消按钮回退的功能
        backgroundColor: Color.fromARGB(255, 221, 160, 160), // 设置AppBar的背景颜色
        titleTextStyle: TextStyle(
          color: Color.fromARGB(168, 0, 0, 0), // 设置标题文字颜色
          fontSize: 20.0, // 设置标题文字大小
          fontWeight: FontWeight.bold, // 设置标题文字粗细
          ),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // 设置聊天框宽度为屏幕宽度的80%
          height: MediaQuery.of(context).size.height * 0.7, // 设置聊天框高度为屏幕高度的70%
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0), // 设置Container的圆角
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 8), // 阴影偏移量
              ),
            ],
          ),
          child:Padding  (
            padding: const EdgeInsets.all(30.0),
            child: Chat(
              messages: _messages,
              onSendPressed: _handleSendPressed,
              user: _user,
              theme: DefaultChatTheme(
                primaryColor: Colors.blue,
                secondaryColor: Colors.grey,
                backgroundColor: Colors.white,
                messageBorderRadius: 15.0, // 设置消息气泡的圆角半径
                inputBackgroundColor: Colors.white, // 输入框背景颜色
                inputTextColor: Colors.black, // 输入框文字颜色
                inputBorderRadius: BorderRadius.circular(15.0), // 输入框圆角
                inputTextStyle: TextStyle(fontSize: 16.0), // 输入框文字样式
                inputContainerDecoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: Color.fromARGB(136, 136, 126, 138), width: 1.0), // 输入框边框颜色和宽度
                ),
              ),
            showUserAvatars: true,
            showUserNames: true,
            ),
          )
        )
      ),
    );
  }
}