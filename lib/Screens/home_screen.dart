import 'package:ai_bot/Res/api_key.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatUser _currentUser =
      ChatUser(id: "1", firstName: "Saad", lastName: "Ahmed");
  final ChatUser _aiUser = ChatUser(id: '2', lastName: "AI Bot");
  final List<ChatUser> _typingUser = <ChatUser>[];
  final List<ChatMessage> _message = <ChatMessage>[];
  final _openAi = OpenAI.instance.build(
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 5),
      ),
      token: OpenAi_API_KEY,
      enableLog: true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat GPT"),
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: DashChat(
          currentUser: _currentUser,
          typingUsers: _typingUser,
          onSend: getChatResponse,
          messageOptions: const MessageOptions(
            containerColor: Colors.grey,
            currentUserContainerColor: Colors.black,
            textColor: Colors.white,
          ),
          messages: _message,
        ));
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _message.insert(0, m);
      _typingUser.add(_aiUser);
    });
    List<Map<String, dynamic>> messageHistory = _message.reversed.map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text).toJson();
      } else {
        return Messages(role: Role.assistant, content: m.text).toJson();
      }
    }).toList();
    final request = ChatCompleteText(
        model: GptTurbo0301ChatModel(),
        messages: messageHistory,
        maxToken: 200);
    final response = await _openAi.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _message.insert(
              0,
              ChatMessage(
                  user: _aiUser,
                  createdAt: DateTime.now(),
                  text: element.message!.content));
        });
      }
    }
    setState(() {
      _typingUser.remove(_aiUser);
    });
  }
}
