import 'package:brycen_chatbot/services/voice_handle.dart';
import 'package:brycen_chatbot/values/share_keys.dart';
import 'package:brycen_chatbot/widget/chat/toggle_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum InputMode {
  text,
  voice,
}

class TextAndVoiceField extends StatefulWidget {
  const TextAndVoiceField({super.key});

  @override
  State<TextAndVoiceField> createState() => _TextAndVoiceFieldState();
}

class _TextAndVoiceFieldState extends State<TextAndVoiceField> {
  late SharedPreferences prefs;
  var _initUID = '';
  var _initAPIKey = '';
  var _initUsername = '';

  InputMode _inputMode = InputMode.voice;
  final _messageController = TextEditingController();
  var _isReplying = false;
  var _isListening = false;
  final VoiceHandler voiceHandler = VoiceHandler();

  @override
  void initState() {
    voiceHandler.initSpeech();
    _getLocalValue();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _getLocalValue() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _initAPIKey = prefs.getString(ShareKeys.APIkey)!;
      _initUsername = prefs.getString(ShareKeys.Username)!;
      _initUID = prefs.getString(ShareKeys.UID)!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            onChanged: (value) {
              value.isNotEmpty
                  ? setInputMode(InputMode.text)
                  : setInputMode(InputMode.voice);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        ToggleButton(
          inputMode: _inputMode,
          isReplying: _isReplying,
          isListening: _isListening,
          sendTextMessage: () {
            final message = _messageController.text;
            _messageController.clear();
            sendTextMessage(message);
            setState(() {
              _messageController.clear();
              setInputMode(InputMode.voice);
            });
          },
          sendVoiceMessage: () {
            sendVoiceMessage();
          },
        ),
      ],
    );
  }

  void setInputMode(InputMode inputMode) {
    setState(() {
      _inputMode = inputMode;
    });
  }

  void sendVoiceMessage() async {
    if (!voiceHandler.isEnabled) {
      print('Not supported');
      return;
    }
    if (voiceHandler.speechToText.isListening) {
      await voiceHandler.stopListening();
      setListeningState(false);
    } else {
      setListeningState(true);
      final result = await voiceHandler.startListening();
      setListeningState(false);
      setState(() {
        _messageController.text = result;
        setInputMode(InputMode.text);
      });
    }
  }

  void sendTextMessage(String message) async {
    setReplyingState(true);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_initUID)
        .collection("chat")
        .add({
      "text": message,
      "createdAt": Timestamp.now(),
      "isUser": true,
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      print('delay');
      setReplyingState(false);
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_initUID)
        .collection("chat")
        .add({
      "text": 'Bot Response: ' + message,
      "createdAt": Timestamp.now(),
      "isUser": false,
    });
  }

  void setReplyingState(bool isReplying) {
    setState(() {
      _isReplying = isReplying;
    });
  }

  void setListeningState(bool isListening) {
    setState(() {
      _isListening = isListening;
    });
  }
}
