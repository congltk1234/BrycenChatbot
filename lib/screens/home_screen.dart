// import 'package:brycen_chatbot/widget/app_bar.dart';
import 'package:flutter/material.dart';
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
  bool? _isAPI;
  final _apiController = TextEditingController();
  final key = GlobalKey<FormState>();
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
    final isValid = key.currentState!.validate();
    if (isValid) {
      key.currentState!.save();
    }
    if (_isAPI == true) {
      print('Accept');
      return;
    }
    _apiController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo '),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: key,
              child: TextFormField(
                controller: _apiController,
                obscureText: false,
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
                  _apiController.text = value!;
                },
                enableSuggestions: false,
                decoration: InputDecoration(
                  errorText: errorText,
                  contentPadding: const EdgeInsets.only(right: 40),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submit,
        tooltip: 'button',
        child: const Icon(Icons.account_circle),
      ),
    );
  }
}
