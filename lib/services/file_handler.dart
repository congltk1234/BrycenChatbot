import 'dart:io';
import 'dart:typed_data';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

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
