import 'dart:convert';

import 'package:brycen_chatbot/firebase_options.dart';
import 'package:brycen_chatbot/models/user.dart';
// import 'package:brycen_chatbot/widget/chatTitle.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
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
  late List<UserModel> _widgetOptions;
  late UserModel currentUser;

  @override
  void initState() {
    menuList();
    _fetchValue();
    super.initState();
  }

  void _fetchValue() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map<String, dynamic> json = jsonDecode(pref.getString('userData')!);
    setState(() {
      currentUser = UserModel.fromJson(json);
    });
    print('get User ${currentUser.username}');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // _fetchValue();

    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text('Drawler demo'),
              Text('Current User: \n ${currentUser.username}'),
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
    List<UserModel> widgetList = [];
    for (var element in users.docs) {
      // final option = Text(element.data()['Username']);
      widgetList.add(UserModel(
          uid: element.id,
          username: element.data()['Username'],
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
      tiles.add(
        ListTile(
          title: Text(element.username!),
          onTap: () async {
            Navigator.pop(context);
            final result = await Navigator.of(context).push<UserModel>(
              MaterialPageRoute(
                builder: (context) => MenuItemPage(
                  user: element,
                ),
              ),
            );

            print('selected ${result!.username}');
            setState(() {
              currentUser = result;
            });
          },
        ),
      );
    }

    return tiles;
  }
}

class MenuItemPage extends StatelessWidget {
  final UserModel user;

  const MenuItemPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${user.username}"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(user);
          return false;
        },
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your API is \n ${user.apiKey}',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 10),
            ElevatedButton(
              child: Text('Stored user to sharedprefrence'),
              onPressed: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                // Map json = jsonDecode(jsonString);
                String a = jsonEncode(user);
                pref.setString('userData', a);
                print('Stored');
              },
            ),
          ],
        )),
      ),
    );
  }
}
