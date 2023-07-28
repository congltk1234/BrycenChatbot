import 'package:brycen_chatbot/const/theme.dart';
import 'package:brycen_chatbot/firebase_options.dart';
import 'package:brycen_chatbot/screens/chat_screen.dart';
import 'package:brycen_chatbot/screens/home_screen.dart';
import 'package:brycen_chatbot/screens/summarize_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intern Chatbot',
      debugShowCheckedModeBanner: false,
      theme: configThemes,
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (_) => const HomeScreen(),
        ChatScreen.id: (_) => const ChatScreen(),
        SummarizeScreen.id: (_) => const SummarizeScreen(),
      },
    );
  }
}
