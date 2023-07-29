import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatItem extends StatelessWidget {
  ChatItem({
    super.key,
    required this.text,
    required this.isUser,
  });
  final String text;
  final bool isUser;

  FlutterTts flutterT2S = FlutterTts();
  bool _isSpeaking = false;

  void _speak() async {
    _isSpeaking = !_isSpeaking;
    if (_isSpeaking) {
      await flutterT2S.speak(text);
    } else {
      flutterT2S.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ProfileContainer(isUser: isUser),
          if (!isUser) const SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(15),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey.shade800,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                  bottomLeft: Radius.circular(isUser ? 15 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 15),
                )),
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
          if (!isUser)
            IconButton(
              onPressed: _speak,
              icon: Icon(_isSpeaking ? Icons.volume_mute : Icons.volume_up),
              // color: Colors.white,
            )
        ],
      ),
    );
  }
}

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({
    super.key,
    required this.isUser,
  });

  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isUser
            ? Theme.of(context).colorScheme.secondary
            : Colors.grey.shade800,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
          bottomLeft: Radius.circular(isUser ? 0 : 15),
          bottomRight: Radius.circular(isUser ? 15 : 0),
        ),
      ),
      child: Icon(isUser ? Icons.people : Icons.computer),
    );
  }
}
