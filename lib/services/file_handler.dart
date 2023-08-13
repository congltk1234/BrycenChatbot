import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;

final storageRef = FirebaseStorage.instance.ref();

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
  request.files.add(await http.MultipartFile.fromPath('file', filePath));
  var response = await request.send();
  var newresponse = await http.Response.fromStream(response);
  final responseData = json.decode(newresponse.body);
  print(responseData['text']);
  return responseData['text'];
}

Future<String> uploadFile(String uid, File file) async {
  final name = file.path.split('/').last;
  final path = "$uid/$name";
  print(path);
  final ref = storageRef.child(path);
  var uploadTask = ref.putFile(file);
  final snapshot = await uploadTask.whenComplete(() {});
  final urlDownload = await snapshot.ref.getDownloadURL();
  return urlDownload;
}

Future<void> downloadFile(String url, String path) async {
  final localFile = File(path);

  final response = await Dio().get(
    url,
    options: Options(
      responseType: ResponseType.bytes,
      followRedirects: false,
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  final raf = localFile.openSync(mode: FileMode.write);
  raf.writeFromSync(response.data);
  await raf.close();
}

Future<void> deleteFile(String uid, String path) async {
  final name = path.split('/').last;
// Create a reference to the file to delete
  final desertRef = storageRef.child('$uid/$name');
// Delete the file
  await desertRef.delete();
}
