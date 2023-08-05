import 'package:brycen_chatbot/firebase_options.dart';
import 'package:brycen_chatbot/widget/chatTitle.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'Drawer Demo';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late List<ChatTitle> _widgetOptions;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    menuList();

    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text('Drawler demo'),
              TextButton(
                  child: Text('Chat'),
                  onPressed: () {
                    scaffoldKey.currentState!.openDrawer();
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
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: _buildTiles(),
          ),
        ),
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: _buildTiles(),
          ),
        ),
      ),
    );
  }

  void menuList() async {
    final users = await FirebaseFirestore.instance.collection("users").get();

    List<ChatTitle> widgetList = [];

    for (var element in users.docs) {
      // final option = Text(element.data()['Username']);
      widgetList.add(ChatTitle(
          id: element.id,
          title: element.data()['Username'],
          // chatDate: element.data()['createdAt'],
          apiKey: element.data()['APIkey']));
    }

    setState(() {
      _widgetOptions = widgetList;
    });
  }

  List<Widget> _buildTiles() {
    List<Widget> tiles = [
      ListTile(
        horizontalTitleGap: 0.0,
        leading: const Icon(Icons.add),
        title: Text('New Chat'),
        onTap: () {},
      ),
    ];

    for (var element in _widgetOptions) {
      tiles.add(ListTile(
        title: Text(element.title),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuItemPage(
                chatTitle: element,
              ),
            ),
          );
          // Navigator.pop(context);
        },
      ));
    }

    return tiles;
  }
}

class MenuItemPage extends StatelessWidget {
  final ChatTitle chatTitle;

  const MenuItemPage({super.key, required this.chatTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${chatTitle.title}"),
      ),
      body: Center(
          child: Text(
        'Your API is ${chatTitle.apiKey}',
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
    );
  }
}
