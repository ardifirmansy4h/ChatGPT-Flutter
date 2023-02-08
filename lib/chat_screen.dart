import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';

import 'package:flutter_chat/chatmessage.dart';
import 'package:flutter_chat/threedots.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  ChatGPT? chatGPT;

  StreamSubscription? _subscription;
  bool _isTyping = false;
  void initState() {
    super.initState();
    chatGPT = ChatGPT.instance;
  }

  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  void _sendMessage() {
    ChatMessage message =
        ChatMessage(text: _controller.text, sender: "Ardi Firmansyah");

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });
    _controller.clear();

    final request = CompleteReq(
        prompt: message.text, model: kTranslateModelV3, max_tokens: 200);
    _subscription = chatGPT!
        .builder("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")
        .onCompleteStream(request: request)
        .listen(
      (response) {
        Vx.log(response!.choices[0].text);
        ChatMessage botMessage =
            ChatMessage(text: response.choices[0].text, sender: "Robot");

        setState(() {
          _isTyping = false;
          _messages.insert(0, botMessage);
        });
      },
    );
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration:
                InputDecoration.collapsed(hintText: "Ketikkan pertanyaan"),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () => _sendMessage(),
        )
      ],
    ).px(16);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Chat GPT Ardi")),
        body: Column(
          children: [
            Flexible(
              child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              ),
            ),
            if (_isTyping) ThreeDots(),
            Divider(
              height: 2.0,
            ),
            Container(
              decoration: BoxDecoration(
                color: context.cardColor,
              ),
              child: _buildTextComposer(),
            )
          ],
        ),
      ),
    );
  }
}
