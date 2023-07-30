import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ignore: must_be_immutable
class ChatItem extends StatelessWidget {
  ChatItem(
      {super.key,
      required this.text,
      required this.isUser,
      required this.timeStamp,
      this.shouldAnimate = false,
      this.tokens = 0});
  final String text;
  final String timeStamp;
  final bool isUser;
  final bool shouldAnimate;
  final int tokens;

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
        vertical: 5,
        horizontal: 12,
      ),
      child: Column(
        children: [
          if (isUser) Text(timeStamp),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) ProfileContainer(isUser: isUser),
              if (!isUser) const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width *
                        (!isUser ? 0.7 : 0.5)),
                decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey[350],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                      bottomLeft: Radius.circular(isUser ? 15 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 15),
                    )),
                child: shouldAnimate
                    ? AnimatedTextKit(
                        isRepeatingAnimation: false,
                        repeatForever: false,
                        displayFullTextOnTap: true,
                        totalRepeatCount: 1,
                        animatedTexts: [
                          TyperAnimatedText(text.trim(),
                              textStyle: const TextStyle(
                                  // color: Colors.black,
                                  )),
                        ],
                      )
                    : Text(
                        text,
                        style: TextStyle(
                          color: isUser
                              ? Theme.of(context).colorScheme.onSecondary
                              : Colors.black,
                        ),
                      ),
              ),
              if (!isUser && (text.length > 40))
                Column(
                  children: [
                    IconButton(
                      onPressed: _speak,
                      icon: Icon(
                          _isSpeaking ? Icons.volume_mute : Icons.volume_up),
                    ),
                    GestureDetector(
                      child: const Icon(Icons.copy),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('copied'),
                          backgroundColor: Colors.green,
                          duration: Duration(milliseconds: 1000),
                        ));
                      },
                    ),
                  ],
                ),
              if (!isUser && (text.length < 40))
                Row(
                  children: [
                    IconButton(
                      onPressed: _speak,
                      icon: Icon(
                          _isSpeaking ? Icons.volume_mute : Icons.volume_up),
                    ),
                    GestureDetector(
                      child: const Icon(Icons.copy),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('copied'),
                          backgroundColor: Colors.green,
                          duration: Duration(milliseconds: 1000),
                        ));
                      },
                    ),
                  ],
                ),
            ],
          ),
          if (tokens != 0)
            Row(
              children: [
                const SizedBox(width: 50),
                Text(
                  'Used Tokens: ${tokens.toString()}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
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
      padding: const EdgeInsets.all(5),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[350],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: const ImageIcon(AssetImage('assets/images/openai.png')),
    );
  }
}
