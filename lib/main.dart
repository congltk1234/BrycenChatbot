import 'const/theme.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connection_notifier/connection_notifier.dart';

void main() async {
  await ConnectionNotifierTools.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectionNotifier(
      alignment: AlignmentDirectional.topCenter,
      height: 100,
      child: MaterialApp(
        title: 'Intern Chatbot',
        debugShowCheckedModeBanner: false,
        theme: configThemes,
        initialRoute: HomeScreen.id,
        routes: {
          HomeScreen.id: (_) => const HomeScreen(),
        },
      ),
    );
  }
}
