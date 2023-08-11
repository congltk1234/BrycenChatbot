import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ignore: must_be_immutable
class ChatItem extends StatelessWidget {
  ChatItem({
    super.key,
    required this.humanMessage,
    required this.botResponse,
    required this.timeStamp,
    required this.tokens,
    this.shouldAnimate = false,
  });
  final String humanMessage;
  final String botResponse;
  final String timeStamp;
  final bool shouldAnimate;
  final int tokens;

  FlutterTts flutterT2S = FlutterTts();
  bool _isSpeaking = false;

  void _speak() async {
    _isSpeaking = !_isSpeaking;
    if (_isSpeaking) {
      await flutterT2S.speak(botResponse);
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
          /// TimeStamp
          Text(
            timeStamp,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),

          /// User Message
          if (humanMessage != '') const SizedBox(height: 5),
          if (humanMessage != '')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 45),
                    if (tokens > 0)
                      Text(
                        'Used Tokens: ${tokens.toString()}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      // .withOpacity(0.8),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(0),
                      )),
                  child: Text(
                    humanMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),

          /// Bot Messages
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const ProfileContainer(),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65),
                decoration: BoxDecoration(
                    color: Colors.grey[350],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(15),
                    )),
                child: shouldAnimate
                    ? AnimatedTextKit(
                        isRepeatingAnimation: false,
                        repeatForever: false,
                        displayFullTextOnTap: true,
                        totalRepeatCount: 1,
                        animatedTexts: [
                          TyperAnimatedText(botResponse.trim(),
                              textStyle: const TextStyle(
                                  // color: Colors.black,
                                  )),
                        ],
                      )
                    : Text(
                        botResponse.trim(),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
              ),
              if (botResponse.length > 40)
                Column(
                  children: [
                    IconButton(
                      onPressed: _speak,
                      icon: Icon(
                          _isSpeaking ? Icons.volume_mute : Icons.volume_up),
                      iconSize: 20,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.copy,
                        size: 20,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: botResponse));
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
              if (botResponse.length < 40)
                Row(
                  children: [
                    IconButton(
                      onPressed: _speak,
                      iconSize: 20,
                      icon: Icon(
                          _isSpeaking ? Icons.volume_mute : Icons.volume_up),
                    ),
                    GestureDetector(
                      child: const Icon(
                        Icons.copy,
                        size: 20,
                      ),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: botResponse));
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
        ],
      ),
    );
  }
}

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({
    super.key,
  });

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
