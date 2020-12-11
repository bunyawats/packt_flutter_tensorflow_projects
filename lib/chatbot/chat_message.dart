import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  final String query;
  final String response;

  ChatMessage({this.query, this.response});

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              widget.query,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black45,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              widget.response,
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
