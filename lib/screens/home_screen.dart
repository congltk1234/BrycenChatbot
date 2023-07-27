// import 'package:brycen_chatbot/widget/app_bar.dart';
import 'package:brycen_chatbot/widget/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
  var _isValid = false;

  bool? _isAPI;
  String? errorText;

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
        "max_tokens": 7,
        "temperature": 0,
      }),
    );
    final message = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _isAPI = true;
      print(message['choices'][0]['text']);
      return true;
    } else {
      print(message['error']['message']);
      return false;
    }
  }

  Future<void> _submit() async {
    // _apiController.clear();
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
    if (_isAPI == true) {
      print('Accept');
      return;
    }
    _enteredAPIKey.clear();
  }

  @override
  Widget build(BuildContext context) {
    var userInfo = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                text: 'Hello ', // default text style
                children: <TextSpan>[
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
                    //_initAPIKey.substring(0, 5) +
                    '***',
                // _initAPIKey.substring(48, 51),
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.primary,
                ))),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        _isValid = false;
                      });
                    },
                    child: Text('change')),
              ],
            ),
          ],
        ));

    var inputForm = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                controller: _enteredUsername,
                // textInputAction: TextInputAction.continueAction,
                decoration: const InputDecoration(
                  hintText: 'Your Name:',
                ),

                onSaved: (value) {
                  _enteredUsername.text = value!;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _enteredAPIKey,
                obscureText: false,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  errorText: errorText,
                  contentPadding: const EdgeInsets.only(right: 40),
                  labelText: 'API Key',
                  prefixIcon: Icon(Icons.key,
                      color: Theme.of(context).colorScheme.secondary),
                  hintText: "Insert your OpenAPI key...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
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
                enableSuggestions: false,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // _addNewUserKey();
                        _submit;
                        setState(() {
                          // _initAPIKey = _enteredAPIKey.text;
                          // _initUsername = _enteredUsername.text;
                          // _isValid = true;
                        });
                      }
                    },
                    child:
                        // _isLoading
                        // ? const SizedBox(
                        //     height: 16,
                        //     width: 16,
                        //     child: CircularProgressIndicator(),
                        //   )
                        // :
                        const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
    return Scaffold(
      appBar: ConfigAppBar(title: 'Summarize Screen'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: inputForm,
        ),
      ),
    );
  }
}
