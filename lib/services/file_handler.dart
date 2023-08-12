import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;

Future<String> doc2text(String path) async {
  final fileDoc = File(path);
  final Uint8List bytes = await fileDoc.readAsBytes();
  final fileContent = docxToText(bytes);
  return fileContent;
}

Future<String> pdf2text(String path) async {
  final fileDoc = File(path);
  final Uint8List bytes = await fileDoc.readAsBytes();
  final pdfDocument = PdfDocument(inputBytes: bytes);
  PdfTextExtractor extractor = PdfTextExtractor(pdfDocument);
  final fileContent = extractor.extractText();
  print("pdf done");
  return fileContent;
}

Future<String> speech2text(
  String apiKey,
  String filePath,
) async {
  var url = Uri.https("api.openai.com", "v1/audio/transcriptions");
  var request = http.MultipartRequest('POST', url);
  request.headers.addAll(({"Authorization": "Bearer $apiKey"}));
  request.fields["model"] = 'whisper-1';
  // request.fields["language"] = "en";
  request.files.add(await http.MultipartFile.fromPath('file', filePath));
  var response = await request.send();
  var newresponse = await http.Response.fromStream(response);
  final responseData = json.decode(newresponse.body);
  return responseData['text'];
}
