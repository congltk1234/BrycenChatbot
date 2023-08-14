// ignore_for_file: avoid_print, use_build_context_synchronously, non_constant_identifier_names
import 'dart:io';
import 'package:brycen_chatbot/widget/internet_error.dart';

import '../models/chatTitle.dart';
import '../providers/menu_provider.dart';
import 'chat_screen.dart';
import 'summarize_screen.dart';
import '../values/share_keys.dart';
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
    setState(() {
      _isLoading = true;
    });
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
    ScaffoldMessenger.of(context).clearSnackBars();

    final message = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _isAPI = true;
      print(message['choices'][0]['text']);
      return true;
    } else {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Successed'),
        ),
      );

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
        content: const Text('not connected'),
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
    final keyStatus = await checkApiKey(_initAPIKey);
    setState(() {
      _isExpired = !keyStatus;
      _isLoading = false;
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
              textAlign: TextAlign.center,
              autofocus: true,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary),
              textCapitalization: TextCapitalization.words,
              controller: _enteredUsername,
              decoration: InputDecoration(
                hintText: 'Your Name:',
                prefixIcon: Icon(Icons.account_circle,
                    color: Theme.of(context).colorScheme.secondary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
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
            const SizedBox(height: 10),
            TextFormField(
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              controller: _enteredAPIKey,
              obscureText: passwordVisible,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.4),
                labelText: 'API Key',
                prefixIcon: IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                      color: passwordVisible
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey),
                  onPressed: () {
                    setState(
                      () {
                        passwordVisible = !passwordVisible;
                      },
                    );
                  },
                ),
                hintText: "Insert your OpenAPI key...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // added line
                  mainAxisSize: MainAxisSize.min, // added line
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.clear),
                      onPressed: _enteredAPIKey.clear,
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
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).colorScheme.primary),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white)),
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
                text: 'Hello ',
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
      drawer: SafeArea(
        child: DrawerMenu(context, chatTitle, true),
      ),
      endDrawer: SafeArea(child: DrawerMenu(context, summarizeTitle, false)),
      body: ConnectionNotifierToggler(
        onConnectionStatusChanged: (connected) {
          if (connected == null) return;
        },
        disconnected: const InternetError(),
        connected: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: ExactAssetImage('assets/images/background.png'),
                  fit: BoxFit.fill,
                  alignment: Alignment.topCenter)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                userForm,
                if (_isValid)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: !_isLoading
                            ? () {
                                ref
                                    .read(chatTitleProvider.notifier)
                                    .fetchDatafromFireStore(_initUID);
                                scaffoldKey.currentState!.openDrawer();
                              }
                            : null,
                        child: const Text('Chatbot'),
                      ),
                      ElevatedButton(
                        onPressed: !_isLoading
                            ? () {
                                ref
                                    .read(summaryProvider.notifier)
                                    .fetchDatafromFireStore(_initUID);
                                scaffoldKey.currentState!.openEndDrawer();
                              }
                            : null,
                        child: const Text('Summary'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Drawer DrawerMenu(
      BuildContext context, List<ChatTitleModel> widgetOptions, bool mode) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 3 / 5,
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              tileColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.78),
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
                itemBuilder: (BuildContext context, int index) {
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
                              onPressed: () async {
                                final instance = FirebaseFirestore.instance;
                                final batch = instance.batch();
                                Navigator.pop(ctx);
                                var document = instance
                                    .collection("users")
                                    .doc(_initUID)
                                    .collection(mode ? "chat" : "summarize")
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
                                    .collection(mode ? "chat" : "summarize")
                                    .doc(widgetOptions[index].chatid!)
                                    .delete()
                                    .then((value) => print("ChatTitle Deleted"))
                                    .catchError((error) =>
                                        print("Failed to delete: $error"));
                                setState(() {
                                  widgetOptions.removeAt(index);
                                });
                              },
                              child: const Text('Okay'),
                            ),
                            TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  setState(() {});
                                },
                                child: const Text('Cancel')),
                          ],
                        ),
                      );
                    },
                    child: ListTile(
                      shape: const RoundedRectangleBorder(
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
              tileColor: Theme.of(context).colorScheme.secondaryContainer,
              leading: Icon(mode ? Icons.edit_document : Icons.aod),
              title: Text(mode ? 'Summarize' : 'Chat Bot'),
              onTap: () {
                mode
                    ? ref
                        .read(summaryProvider.notifier)
                        .fetchDatafromFireStore(_initUID)
                    : ref
                        .read(chatTitleProvider.notifier)
                        .fetchDatafromFireStore(_initUID);
                mode
                    ? scaffoldKey.currentState!.openEndDrawer()
                    : scaffoldKey.currentState!.openDrawer();
              },
            ),
            ListTile(
              tileColor:
                  Theme.of(context).colorScheme.secondary.withOpacity(0.15),
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              tileColor:
                  Theme.of(context).colorScheme.secondary.withOpacity(0.15),
              leading: const Icon(Icons.settings),
              title: const Text('Setting'),
              onTap: () {},
            )
          ],
        ),
      ),
    );
  }
}
