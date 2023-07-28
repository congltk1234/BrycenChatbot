import 'package:brycen_chatbot/models/chat_model.dart';
import 'package:brycen_chatbot/providers/chat_provider.dart';
import 'package:brycen_chatbot/services/voice_handle.dart';
import 'package:brycen_chatbot/widget/chat/toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum InputMode {
  text,
  voice,
}

class TextAndVoiceField extends ConsumerStatefulWidget {
  const TextAndVoiceField({super.key});

  @override
  ConsumerState<TextAndVoiceField> createState() => _TextAndVoiceFieldState();
}

class _TextAndVoiceFieldState extends ConsumerState<TextAndVoiceField> {
  InputMode _inputMode = InputMode.voice;
  final _messageController = TextEditingController();
  var _isReplying = false;
  var _isListening = false;
  final VoiceHandler voiceHandler = VoiceHandler();

  @override
  void initState() {
    voiceHandler.initSpeech();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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
      sendTextMessage(result);
    }
  }

  void sendTextMessage(String message) {
    setReplyingState(true);

    addToChatList(message, true, DateTime.now().toString());
    addToChatList('Typing...', false, 'typing');

    Future.delayed(const Duration(milliseconds: 2000), () {
      addToChatList(
          'Bot Response: ' + message, false, DateTime.now().toString());
      print('delay');
      setReplyingState(false);
      removeTyping();
    });
  }

  void addToChatList(String message, bool isUser, String id) {
    final chats = ref.read(chatsProvider.notifier);
    chats.add(ChatModel(
      id: id,
      message: message,
      isUser: isUser,
    ));
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

  void removeTyping() {
    final chats = ref.read(chatsProvider.notifier);
    chats.removeTyping();
  }
}
