import 'package:brycen_chatbot/screens/chat_screen.dart';
import 'package:brycen_chatbot/screens/summarize_screen.dart';
import 'package:brycen_chatbot/values/share_keys.dart';
import 'package:brycen_chatbot/widget/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const id = 'home_screen';

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  // controllers for form text controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _enteredAPIKey = TextEditingController();
  final TextEditingController _enteredUsername = TextEditingController();

  late SharedPreferences prefs;
  var _initUID = '';
  var _initAPIKey = '';
  var _initUsername = '';

  bool _isValid = false;
  // bool _isLoading = false;
  bool passwordVisible = true;
  var _isExpired = false;
  bool? _isAPI;
  String? errorText;

  @override
  void initState() {
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
          // ignore: use_build_context_synchronously
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
    });
    final key_status = await checkApiKey(_initAPIKey);
    setState(() {
      _isExpired = !key_status;
    });
  }

  @override
  Widget build(BuildContext context) {
    var userForm = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
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
                suffixIcon: IconButton(
                  icon: Icon(passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(
                      () {
                        passwordVisible = !passwordVisible;
                      },
                    );
                  },
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
      appBar: const ConfigAppBar(title: 'Home Screen'),
      // drawer: MainDrawer(),
      body: Center(
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
                      Navigator.pushNamed(context, ChatScreen.id);
                    },
                    child: const Text('Chatbot'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, SummarizeScreen.id);
                    },
                    child: const Text('Summary'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
