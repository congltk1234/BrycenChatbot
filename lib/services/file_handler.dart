import 'dart:io';
import 'dart:typed_data';
import 'package:docx_to_text/docx_to_text.dart';

Future<String> doc2text(String path) async {
  final fileDoc = File(path);
  final Uint8List bytes = await fileDoc.readAsBytes();
  final fileContent = docxToText(bytes);
  return fileContent;
}
