import 'package:brycen_chatbot/widget/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class FileDataScreen extends StatefulWidget {
  // final Uint8List fileData;
  final String filepath;
  final String filename;
  FileDataScreen({
    required this.filepath,
    required this.filename,
  });

  @override
  State<FileDataScreen> createState() => _FileDataScreenState();
}

class _FileDataScreenState extends State<FileDataScreen> {
  String file_content = '';

  void _openFile(String path) {
    OpenFile.open(path);
  }

  @override
  void initState() {
    _openFile(widget.filepath);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ConfigAppBar(title: widget.filename),
      // appBar: AppBar(
      //   title: Text(filename),
      // ),
      body: Center(
        child: Text(
          widget.filepath.split('.').last,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
