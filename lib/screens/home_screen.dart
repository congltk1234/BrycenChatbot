import 'package:brycen_chatbot/screens/chat_screen.dart';
import 'package:brycen_chatbot/screens/summarize_screen.dart';
import 'package:brycen_chatbot/values/share_keys.dart';
import 'package:brycen_chatbot/widget/app_bar.dart';
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
  var _initAPIKey = '';
  var _initUsername = '';
  bool _isValid = false;
  bool _isLoading = false;
  bool passwordVisible = true;
  var _isExpired = true;
  bool? _isAPI;
  String? errorText;
  //
  //
  @override
  void initState() {
    _getLocalValue();
    super.initState();
    setState(() {
      _isLoading = false;
    });
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
        "prompt": "Say this is a test",
        "max_tokens": 5,
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
      prefs.setString(ShareKeys.APIkey, _enteredAPIKey.text);
      prefs.setString(ShareKeys.Username, _enteredUsername.text);
      print('Accept');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Successed'),
        ),
      );
      return;
    }
  }

  void _getLocalValue() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _initAPIKey = prefs.getString(ShareKeys.APIkey) ?? '';
      _initUsername = prefs.getString(ShareKeys.Username) ?? '';
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
    var UserForm = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
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
      UserForm = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          children: [
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
      appBar: ConfigAppBar(title: 'Home Screen'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            UserForm,
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
