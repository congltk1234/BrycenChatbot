import 'dart:io';

import 'package:brycen_chatbot/models/chatTitle.dart';
import 'package:brycen_chatbot/providers/menu_provider.dart';
import 'package:brycen_chatbot/screens/chat_screen.dart';
import 'package:brycen_chatbot/screens/summarize_screen.dart';
import 'package:brycen_chatbot/values/share_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_notifier/connection_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  static const id = 'home_screen';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // controllers for form text controllers
  late ChatTitleModel currentTitle;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _enteredAPIKey = TextEditingController();
  final TextEditingController _enteredUsername = TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late SharedPreferences prefs;
  var _initUID = '';
  var _initAPIKey = '';
  var _initUsername = '';

  bool _isValid = false;
  bool _isLoading = false;
  bool passwordVisible = true;
  var _isExpired = false;
  bool? _isAPI;
  String? errorText;
  String? newID;
  @override
  void initState() {
    checkInternet();
    _getLocalValue();
    super.initState();
  }

  Future<bool> checkApiKey(String apiKey) async {
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/completions"),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "model": "text-davinci-003",
        "prompt": "Testing",
        "max_tokens": 2,
        "temperature": 0,
      }),
    );
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).clearSnackBars();

    final message = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _isAPI = true;
      print(message['choices'][0]['text']);
      return true;
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(message['error']['message']),
        ),
      );
      return false;
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await prefs.setString(ShareKeys.APIkey, _enteredAPIKey.text);
      await prefs.setString(ShareKeys.Username, _enteredUsername.text);
      print('Accept');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Successed'),
        ),
      );

      // send to fitebase
      ////// Handle login
      print('Kiểm userID local');
      setState(() {
        _isExpired = false;
      });
      if (_initUID == '') {
        try {
          final uid = await FirebaseFirestore.instance
              .collection('users')
              .where('APIkey', isEqualTo: _enteredAPIKey.text)
              .where('Username', isEqualTo: _enteredUsername.text)
              .get();

          await prefs.setString(ShareKeys.UID, uid.docs.first.reference.id);
          setState(() {
            _initUID = uid.docs.first.reference.id;
            print('Lưu userID đã có');
          });
          return;
        } catch (e) {
          await FirebaseFirestore.instance.collection('users').add({
            'createdAt': Timestamp.now(),
            'modifiedAt': Timestamp.now(),
            'Username': _enteredUsername.text,
            'APIkey': _enteredAPIKey.text,
          });
          print('Thêm mới userID');
        }
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_initUID)
            .update({
          'modifiedAt': Timestamp.now(),
          'Username': _enteredUsername.text,
          'APIkey': _enteredAPIKey.text,
        });
        print('Cập nhật Username/Key mới');
      }
      final uid = await FirebaseFirestore.instance
          .collection('users')
          .where('APIkey', isEqualTo: _enteredAPIKey.text)
          .where('Username', isEqualTo: _enteredUsername.text)
          .get();

      await prefs.setString(ShareKeys.UID, uid.docs.first.reference.id);
      setState(() {
        _initUID = uid.docs.first.reference.id;
        print('Lưu userID vừa tạo vào local');
      });
      return;
    }
  }

  void checkInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      print('not connected');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text('not connected'),
      ));
    }
  }

  void _getLocalValue() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _initAPIKey = prefs.getString(ShareKeys.APIkey) ?? '';
      _initUsername = prefs.getString(ShareKeys.Username) ?? '';
      _initUID = prefs.getString(ShareKeys.UID) ?? '';
      if (_initAPIKey != '' && _initUsername != '') {
        _isValid = true;
        _enteredAPIKey.text = _initAPIKey;
        _enteredUsername.text = _initUsername;
      }

      ref.read(chatTitleProvider.notifier).fetchDatafromFireStore(_initUID);
      ref.read(summaryProvider.notifier).fetchDatafromFireStore(_initUID);
    });
    final key_status = await checkApiKey(_initAPIKey);
    setState(() {
      _isExpired = !key_status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<ChatTitleModel> chatTitle = ref.watch(chatTitleProvider);
    final List<ChatTitleModel> summarizeTitle = ref.watch(summaryProvider);
    var userForm = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 30,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              width: 200,
              child: Image.asset('assets/images/brycen_square.png'),
            ),
            TextFormField(
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              controller: _enteredUsername,
              decoration: InputDecoration(
                hintText: 'Your Name:',
                prefixIcon: Icon(Icons.account_circle,
                    color: Theme.of(context).colorScheme.secondary),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: _enteredUsername.clear,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Không được để trống tên";
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _enteredAPIKey,
              obscureText: passwordVisible,
              decoration: InputDecoration(
                labelText: 'API Key',
                prefixIcon: Icon(Icons.key,
                    color: Theme.of(context).colorScheme.secondary),
                hintText: "Insert your OpenAPI key...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // added line
                  mainAxisSize: MainAxisSize.min, // added line
                  children: [
                    IconButton(
                      padding: EdgeInsets.all(0),
                      icon: const Icon(Icons.clear),
                      onPressed: _enteredAPIKey.clear,
                    ),
                    IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(
                          () {
                            passwordVisible = !passwordVisible;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              onChanged: (value) async {
                final check = await checkApiKey(value);
                setState(() => _isAPI = check);
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Không được để trống API key.";
                }

                if (value.trim().length != 51) {
                  return "Độ dài API Key không hợp lệ.";
                }
                if (!_isAPI!) {
                  return "API Key không tồn tại.";
                }
                return null;
              },
              onSaved: (value) {
                _enteredAPIKey.text = value!;
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _submit();
                  setState(() {
                    _initAPIKey = _enteredAPIKey.text;
                    _initUsername = _enteredUsername.text;
                    _isValid = true;
                  });
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );

    if (_isValid) {
      userForm = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          children: [
            Image.asset('assets/images/logoBrycen.png'),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                ),
                text: 'Hello ', // default text style
                children: [
                  TextSpan(
                      text: _initUsername,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  const TextSpan(
                    text: ', Your API key is:',
                  ),
                ],
              ),
            ),
            Text.rich(TextSpan(
                text:
                    '${_initAPIKey.substring(0, 5)}***${_initAPIKey.substring(48, 51)}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  decoration: _isExpired ? TextDecoration.lineThrough : null,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _isExpired
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                ))),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isExpired)
                  const Text(
                    'Expired Key',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _isValid = false;
                      });
                    },
                    child: const Text(
                      'change Key',
                      style: TextStyle(decoration: TextDecoration.underline),
                    )),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      // appBar: const ConfigAppBar(title: 'Home Screen'),
      drawer: SafeArea(
        child: DrawerMenu(context, chatTitle, true),
      ),
      endDrawer: SafeArea(child: DrawerMenu(context, summarizeTitle, false)),
      body: ConnectionNotifierToggler(
        onConnectionStatusChanged: (connected) {
          if (connected == null) return;
        },
        disconnected: Center(
            key: UniqueKey(),
            child: TextButton(
              onPressed: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logoBrycen.png'),
                  const Text(
                    'Please check your internet connection',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            )),
        connected: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              userForm,
              if (_isValid)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        scaffoldKey.currentState!.openDrawer();
                      },
                      child: const Text('Chatbot'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        scaffoldKey.currentState!.openEndDrawer();
                      },
                      child: const Text('Summary'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Drawer DrawerMenu(
      BuildContext context, List<ChatTitleModel> widgetOptions, bool mode) {
    // mode
    //     ? ref.read(chatTitleProvider.notifier).fetchDatafromFireStore(_initUID)
    //     : ref.read(summaryProvider.notifier).fetchDatafromFireStore(_initUID);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              tileColor: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              textColor: Colors.white,
              iconColor: Colors.white,
              leading: const Icon(Icons.add),
              title: const Text(
                'New Chat',
                textScaleFactor: 1.2,
              ),
              onTap: () async {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(_initUID)
                    .collection(mode ? "chat" : "summarize")
                    .add(
                  {
                    "createdAt": Timestamp.now(),
                    "chatTitle": 'New chat',
                    "memory": "",
                    'modifiedAt': Timestamp.now(),
                  },
                ).then((value) {
                  setState(() {
                    newID = value.id;
                  });
                });

                mode
                    ? ref.read(chatTitleProvider.notifier).newChat(
                          ChatTitleModel(
                            chatid: newID,
                            chattitle: 'New Chat',
                            memory: '',
                          ),
                        )
                    : ref.read(summaryProvider.notifier).newChat(
                          ChatTitleModel(
                            chatid: newID,
                            chattitle: 'New Chat',
                            memory: '',
                          ),
                        );
                // ignore: use_build_context_synchronously
                mode
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            uid: _initUID,
                            userName: _initUsername,
                            apiKey: _initAPIKey,
                            chatTitleID: newID!,
                            chatTitle: 'New Chat',
                          ),
                        ),
                      )
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SummarizeScreen(
                            uid: _initUID,
                            userName: _initUsername,
                            apiKey: _initAPIKey,
                            chatTitleID: newID!,
                            chatTitle: 'New Chat',
                            hasFile: false,
                          ),
                        ),
                      );
                mode
                    ? ref
                        .read(chatTitleProvider.notifier)
                        .fetchDatafromFireStore(_initUID)
                    : ref
                        .read(summaryProvider.notifier)
                        .fetchDatafromFireStore(_initUID);
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: widgetOptions.length,
                // scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  // final chatTitles = chatTitle.reversed.toList();
                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      color: Colors.red,
                    ),
                    onDismissed: (DismissDirection direction) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          actionsAlignment: MainAxisAlignment.spaceAround,
                          title: const Text('Delete chat?'),
                          content: const Text(
                              "Warning: You can't undo this action!"),
                          actions: [
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.05)),
                              ),
                              onPressed: !_isLoading
                                  ? () async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      final instance =
                                          FirebaseFirestore.instance;
                                      final batch = instance.batch();
                                      var document = instance
                                          .collection("users")
                                          .doc(_initUID)
                                          .collection(
                                              mode ? "chat" : "summarize")
                                          .doc(widgetOptions[index].chatid!);
                                      if (mode) {
                                        var snapshots = await document
                                            .collection('chat_history')
                                            .get();
                                        for (var doc in snapshots.docs) {
                                          batch.delete(doc.reference);
                                        }
                                      } else {
                                        var snapshots = await document
                                            .collection('QuestionAnswering')
                                            .get();
                                        for (var doc in snapshots.docs) {
                                          batch.delete(doc.reference);
                                        }
                                        snapshots = await document
                                            .collection('embeddedVectors')
                                            .get();
                                        for (var doc in snapshots.docs) {
                                          batch.delete(doc.reference);
                                        }
                                        snapshots = await document
                                            .collection('suggestion')
                                            .get();
                                        for (var doc in snapshots.docs) {
                                          batch.delete(doc.reference);
                                        }
                                      }
                                      await batch.commit();

                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(_initUID)
                                          .collection(
                                              mode ? "chat" : "summarize")
                                          .doc(widgetOptions[index].chatid!)
                                          .delete()
                                          .then((value) =>
                                              print("ChatTitle Deleted"))
                                          .catchError((error) => print(
                                              "Failed to delete: $error"));

                                      setState(() {
                                        widgetOptions.removeAt(index);
                                        _isLoading = false;
                                      });
                                      Navigator.pop(ctx);
                                    }
                                  : null,
                              child: const Text('Okay'),
                            ),
                            TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {});
                                },
                                child: const Text('Cancel')),
                          ],
                        ),
                      );
                    },
                    child: ListTile(
                      // trailing: Icon(
                      //   Icons.arrow_forward_ios,
                      //   color: Colors.black26,
                      //   size: 15,
                      // ),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black, width: 0.1),
                      ),
                      leading: Icon(
                        Icons.chat_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: Text(
                        widgetOptions[index].chattitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => mode
                                ? ChatScreen(
                                    uid: _initUID,
                                    userName: _initUsername,
                                    apiKey: _initAPIKey,
                                    chatTitleID: widgetOptions[index].chatid!,
                                    chatTitle: widgetOptions[index].chattitle!,
                                  )
                                : SummarizeScreen(
                                    uid: _initUID,
                                    userName: _initUsername,
                                    apiKey: _initAPIKey,
                                    chatTitleID: widgetOptions[index].chatid!,
                                    chatTitle: widgetOptions[index].chattitle!,
                                    hasFile: true,
                                  ),
                          ),
                        );
                        mode
                            ? ref
                                .read(chatTitleProvider.notifier)
                                .fetchDatafromFireStore(_initUID)
                            : ref
                                .read(summaryProvider.notifier)
                                .fetchDatafromFireStore(_initUID);
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(mode ? Icons.summarize : Icons.aod),
              title: Text(mode ? 'Summarize' : 'Chat Bot'),
              onTap: () {
                mode
                    ? scaffoldKey.currentState!.openEndDrawer()
                    : scaffoldKey.currentState!.openDrawer();
                // Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Setting'),
              onTap: () {},
            )
          ],
        ),
      ),
    );
  }
}
