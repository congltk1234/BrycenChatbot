import 'dart:convert';

import 'package:brycen_chatbot/firebase_options.dart';
import 'package:brycen_chatbot/models/chatTitle.dart';
import 'package:brycen_chatbot/models/user.dart';
import 'package:brycen_chatbot/providers/menu_provider.dart';
// import 'package:brycen_chatbot/widget/chatTitle.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'Drawer Demo';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _selectedIndex = 0;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  // late List<UserModel> _widgetOptions;
  late ChatTitleModel currentTitle;

  @override
  void initState() {
    // menuList();
    _fetchValue();
    ref
        .read(chatTitleProvider.notifier)
        .fetchDatafromFireStore('VC0AAVpP10HLI3ghTO5D');

    super.initState();
  }

  void _fetchValue() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map<String, dynamic> json = jsonDecode(pref.getString('chatTitle')!);
    setState(() {
      currentTitle = ChatTitleModel.fromJson(json);
    });
    print('get Title ${currentTitle.chattitle}');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // _fetchValue();

    // final List<UserModel> _widgetOptions = ref.watch(summaryProvider);

    final List<ChatTitleModel> _widgetOptions = ref.watch(chatTitleProvider);
    final provideUser = ref.watch(usersProvider);
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text('Drawler demo'),
              Text('Current User: \n ${provideUser.username}'),
              TextButton(
                  child: Text('Chat'),
                  onPressed: () {
                    scaffoldKey.currentState!.openDrawer();
                    // ref.read(summaryProvider.notifier).addData(provideUser);
                  }),
              TextButton(
                  child: Text('Summarize'),
                  onPressed: () {
                    // scaffoldKey.currentState!.openDrawer();
                    scaffoldKey.currentState!.openEndDrawer();
                  }),
            ],
          ),
        ),
      ),
      // https://blog.logrocket.com/how-to-add-navigation-drawer-flutter/
      // https://docs.flutter.dev/cookbook/design/drawer
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: _buildTiles(_widgetOptions),
          ),
        ),
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: _buildTiles(_widgetOptions),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTiles(List<ChatTitleModel> widgetOptions) {
    List<Widget> tiles = [
      ListTile(
        horizontalTitleGap: 0.0,
        leading: const Icon(Icons.add),
        title: Text('New Chat'),
        onTap: () {
          ref.read(chatTitleProvider.notifier).newChat(currentTitle);
        },
      ),
    ];

    for (var element in widgetOptions) {
      tiles.add(
        ListTile(
          title: Text(element.chattitle!),
          onTap: () async {
            Navigator.pop(context);
            final result = await Navigator.of(context).push<ChatTitleModel>(
              MaterialPageRoute(
                builder: (context) => MenuItemPage(
                  title: element,
                ),
              ),
            );
            print('selected ${result!.chattitle}');
            setState(() {
              currentTitle = result;
            });
          },
        ),
      );
    }

    return tiles;
  }
}

class MenuItemPage extends ConsumerWidget {
  final ChatTitleModel title;

  const MenuItemPage({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${title.chattitle}"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(title);
          return false;
        },
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your API is \n ${title.chatid}',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 10),
            ElevatedButton(
              child: Text('Stored user to sharedprefrence'),
              onPressed: () async {
//https://stackoverflow.com/questions/53931513/store-data-as-an-object-in-shared-preferences-in-flutter
                SharedPreferences pref = await SharedPreferences.getInstance();
                String a = jsonEncode(title);
                pref.setString('chatTitle', a);
                print('Stored');
                ref.read(chatTitleProvider.notifier).newChat(title);
              },
            ),
          ],
        )),
      ),
    );
  }
}
