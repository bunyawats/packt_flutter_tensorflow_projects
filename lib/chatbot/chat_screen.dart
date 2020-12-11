import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  Widget createTextField() {
    return Flexible(
      child: TextField(
        decoration: InputDecoration.collapsed(hintText: 'Enter your message'),
        controller: _textController,
        onSubmitted: _handleSubmitted,
      ),
    );
  }

  _handleSubmitted(String query) {
    _textController.clear();
    ChatMessage message = ChatMessage(
      query: query,
      response: 'This is the response string',
    );
    setState(() {
      _messages.insert(0, message);
    });
  }

  Widget createSendButton() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: IconButton(
          icon: Icon(Icons.send),
          onPressed: () => _handleSubmitted(_textController.text),
        ));
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Colors.blue),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            createTextField(),
            createSendButton(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          ),
        ),
        Divider(
          height: 1,
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _buildTextComposer(),
        )
      ],
    );
  }
}
