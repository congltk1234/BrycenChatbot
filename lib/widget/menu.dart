import 'package:brycen_chatbot/firebase_options.dart';
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
    return const MaterialApp(
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

  var _widgetOptions;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    menuList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Text(_widgetOptions[_selectedIndex]['Username']),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: _buildTiles(),
        ),
      ),
    );
  }

  void menuList() async {
    final users = await FirebaseFirestore.instance.collection("users").get();

    List widgetList = [];

    for (var element in users.docs) {
      // final option = Text(element.data()['Username']);
      widgetList.add({
        'Username': element.data()['Username'],
        'APIkey': element.data()['APIkey']
      });
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
        title: Text(element['Username']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuItemPage(
                apiKey: element['APIkey'],
              ),
            ),
          );
        },
      ));
    }

    return tiles;
  }
}

class MenuItemPage extends StatelessWidget {
  final String apiKey;

  const MenuItemPage({super.key, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Another Page"),
      ),
      body: Center(
          child: Text(
        'Your API is $apiKey',
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
    );
  }
}
