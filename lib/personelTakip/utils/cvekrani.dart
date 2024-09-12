import 'package:deneme/personelTakip/widgets/sonuclar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'dart:io'; // For File

class CVListScreen extends StatefulWidget {
  @override
  _CVListScreenState createState() => _CVListScreenState();
}

class _CVListScreenState extends State<CVListScreen> {
  String currentFolderPath = '';
  List<String> files = [];
  List<String> folders = [];
  String? selectedFile;
  PDFDocument? document;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFiles(); // Sayfa yüklendiğinde dosyaları getir
  }

  Future<void> fetchFiles() async {
    try {
      final response = await http.get(
        Uri.parse('http://2a07-159-146-53-63.ngrok-free.app/files?folderPath=$currentFolderPath'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          files = List<String>.from(data['files']);
          folders = List<String>.from(data['folders']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dosyalar getirilemedi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  Future<void> loadPdf(String filePath) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://2a07-159-146-53-63.ngrok-free.app/pdf?filePath=$filePath'),
      );

      if (response.statusCode == 200) {
        final pdfData = response.bodyBytes;

        // Geçici dosya oluşturup PDF verilerini bu dosyaya yazalım
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/temp.pdf');
        await tempFile.writeAsBytes(pdfData);

        // PDFDocument.fromFile() kullanarak PDFDocument oluşturun
        document = await PDFDocument.fromFile(tempFile);

        setState(() {
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF dosyası getirilemedi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  Future<void> deleteFile(String filePath, int index) async {
    try {
      final response = await http.delete(
        Uri.parse('https://2adc-159-146-53-63.ngrok-free.app/files'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'filePath': filePath}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dosya başarıyla silindi')),
        );
        setState(() {
          files.removeAt(index);
          selectedFile = null; // Silinen dosya görüntüleniyorsa, seçimi kaldır
          document = null; // Seçilen dosya silindiğinde PDF görünümünü temizle
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dosya silme başarısız oldu')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CV Listesi'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: ListView(
              children: [
                // Klasörleri listele
                ...folders.map((folder) => ListTile(
                  title: Text(folder),
                  onTap: () {
                    setState(() {
                      currentFolderPath = '$currentFolderPath/$folder'; // Klasör yolunu güncelle
                      fetchFiles();
                    });
                  },
                )),
                // Dosyaları listele
                ...files.map((file) => ListTile(
                  title: Text(file),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SonuclarPDFEkrani(
                          filePath: '$currentFolderPath/$file',
                          baslik: file,
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Silmek istediğinizden emin misiniz?"),
                            actions: <Widget>[
                              TextButton(
                                child: Text("İptal"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text("Sil"),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await deleteFile('$currentFolderPath/$file', files.indexOf(file));
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                )),
              ],
            ),
          ),
          VerticalDivider(), // List ve preview arasına ayırıcı çizgi
          Expanded(
            flex: 3,
            child: selectedFile != null
                ? isLoading
                    ? Center(child: CircularProgressIndicator()) // Yükleniyor göstergesi
                    : document != null
                        ? PDFViewer(
                            document: document!,
                            lazyLoad: false,
                            zoomSteps: 1,
                            numberPickerConfirmWidget: const Text(
                              "Confirm",
                            ),
                          )
                        : Center(child: Text('PDF yüklenemedi'))
                : Center(child: Text('Bir dosya seçin')),
          ),
        ],
      ),
    );
  }
}
