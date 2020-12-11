import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'chat_message.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:permission/permission.dart';
import 'package:flutter_speech/flutter_speech.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  SpeechRecognition _speech;

  bool _isAvailable = false;
  bool _isListening = false;
  String transcription = '';

  void activateSpeechRecognizer() {
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
    _speech.activate('en_US').then((res) {
      setState(() => _isAvailable = res);
    });

    print(' activateSpeechRecognizer ');
  }

  void start() {
    print('on presses mic start');
    if (_isAvailable && !_isListening) {
      _speech.activate('en_US').then((_) {
        return _speech.listen().then((result) {
          print('_ChatScreenState.start => result $result');
          setState(() {
            _isListening = result;
          });
        });
      });
    }
  }

  void cancel() =>
      _speech.cancel().then((_) => setState(() => _isListening = false));

  void stop() => _speech.stop().then((_) {
        setState(() => _isListening = false);
      });

  void onSpeechAvailability(bool result) =>
      setState(() => _isAvailable = result);

  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  void onRecognitionResult(String text) {
    print('_ChatScreenState.onRecognitionResult... $text');
    setState(() => _handleSubmitted(text));
  }

  void onRecognitionComplete(String text) {
    print('_ChatScreenState.onRecognitionComplete... $text');
    setState(() => _isListening = false);
  }

  void errorHandler() => activateSpeechRecognizer();

  @override
  void initState() {
    super.initState();
    activateSpeechRecognizer();
    requestPermission();
  }

  void requestPermission() async {
    final res =
        await Permission.requestPermissions([PermissionName.Microphone]);
    print(res);
  }

  Widget createMicButton() {
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: new IconButton(
        icon: new Icon(Icons.mic),
        onPressed: start,
      ),
    );
  }

  Widget createTextField() {
    return Flexible(
      child: TextField(
        decoration: InputDecoration.collapsed(hintText: 'Enter your message'),
        controller: _textController,
        onSubmitted: _handleSubmitted,
      ),
    );
  }

  _handleSubmitted(String query) async {
    // query = 'Hi Pun Kung';
    _textController.clear();

    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: 'assets/gcp-api.json').build();
    Dialogflow dialogflow = Dialogflow(
      authGoogle: authGoogle,
      language: Language.english,
    );
    AIResponse aiResponse = await dialogflow.detectIntent(query);
    String rsp = aiResponse.getMessage();

    ChatMessage message = ChatMessage(
      query: query,
      response: rsp,
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
            createMicButton(),
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
