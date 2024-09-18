import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

class SonuclarPDFEkrani extends StatefulWidget {
  final String filePath;
  final String baslik;

  SonuclarPDFEkrani({
    required this.filePath,
    required this.baslik,
  });

  @override
  _SonuclarPDFEkraniState createState() => _SonuclarPDFEkraniState();
}

class _SonuclarPDFEkraniState extends State<SonuclarPDFEkrani> {
  late Future<Uint8List> _pdfData;

  @override
  void initState() {
    super.initState();
    _pdfData = fetchPdf(widget.filePath);
  }

  Future<Uint8List> fetchPdf(String filePath) async {
    final encodedFilePath = Uri.encodeComponent(filePath);
    final url = 'http://localhost:3000/pdf?filePath=$encodedFilePath'; // IP adresinizi burada güncelleyin

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response.bodyBytes; // PDF dosyasını byte array olarak döndürür
      } else {
        throw Exception('PDF dosyası alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('PDF dosyası alınamadı: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.baslik),
      ),
      body: FutureBuilder<Uint8List>(
        future: _pdfData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return PdfView(
              controller: PdfController(
                document: PdfDocument.openData(snapshot.data!),
              ),
            );
          } else {
            return Center(child: Text('PDF dosyası bulunamadı'));
          }
        },
      ),
    );
  }
}
