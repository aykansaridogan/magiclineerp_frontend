import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:MagiclineERP/constants/constants.dart' as constants;

class Izinler extends StatefulWidget {
  @override
  _IzinlerState createState() => _IzinlerState();
}

class _IzinlerState extends State<Izinler> {
  final TextEditingController mazeretBildirimTarihiController = TextEditingController();
  final TextEditingController mazeretIzniSureController = TextEditingController();
  final TextEditingController mazeretIzniNedenleriController = TextEditingController();
  final TextEditingController mazeretIzniAyrilmaTarihiController = TextEditingController();
  final TextEditingController mazeretIzniDonusTarihiController = TextEditingController();
  final TextEditingController yerineGorevlendirenAdiController = TextEditingController();

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime now = DateTime.now();
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final formattedDate = '${selectedDate.toLocal()}'.split(' ')[0];
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mazeret İzin Belgesi'),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDateField(
              context,
              mazeretBildirimTarihiController,
              'Mazeret Bildirim Tarihi',
            ),
            _buildTextField(mazeretIzniSureController, 'Mazeret İzin Süresi'),
            _buildTextField(mazeretIzniNedenleriController, 'Mazeret İzni Talebi Nedenleri'),
            _buildDateField(
              context,
              mazeretIzniAyrilmaTarihiController,
              'Mazeret İznine Ayrılma Tarihi',
            ),
            _buildDateField(
              context,
              mazeretIzniDonusTarihiController,
              'Mazeret İzninden Dönüş Tarihi',
            ),
            _buildTextField(yerineGorevlendirenAdiController, 'Mazeret İzni Süresince Yerine Görevlendiren Personelin Adı'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await generatePDF(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Text('PDF Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () => _selectDate(context, controller),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(),
              hintText: 'Seçiniz',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> generatePDF(BuildContext context) async {
    final pdf = pw.Document();

    try {
      // Load the font
      final fontData = await rootBundle.load('../assets/arial.ttf');
      final ttf = pw.Font.ttf(fontData);

      // Get the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/izin1.pdf';
      final file = File(filePath);

      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Talepte Bulunan Personelin;', style: pw.TextStyle(font: ttf)),
              pw.Text('Mazeret Bildirim Tarihi: ${mazeretBildirimTarihiController.text}', style: pw.TextStyle(font: ttf)),
              pw.SizedBox(height: 15),
              pw.Text('Adı: ${constants.personelListesi[0][0].toString()}', style: pw.TextStyle(font: ttf)),
              pw.SizedBox(height: 15),
              pw.Text('Mazeret İzin Süresi: ${mazeretIzniSureController.text}', style: pw.TextStyle(font: ttf)),
              pw.SizedBox(height: 15),
              pw.Text('Mazeret İzni Talebi Nedenleri: ${mazeretIzniNedenleriController.text}', style: pw.TextStyle(font: ttf)),
              pw.SizedBox(height: 15),
              pw.Text('Mazeret İznine Ayrılma Tarihi: ${mazeretIzniAyrilmaTarihiController.text}', style: pw.TextStyle(font: ttf)),
              pw.Text('Mazeret İzninden Dönüş Tarihi: ${mazeretIzniDonusTarihiController.text}', style: pw.TextStyle(font: ttf)),
              pw.SizedBox(height: 20),
              pw.Text('Mazeret İzni Süresince Yerine Görevlendiren Personelin Adı: ${yerineGorevlendirenAdiController.text.toUpperCase()}', style: pw.TextStyle(font: ttf, fontSize: 20)),
              pw.SizedBox(height: 20),
              pw.Text('Not 1: Personele Mazeret izni verilmesi ve süresinin belirlenmesi işverenin yetkisindedir.', style: pw.TextStyle(font: ttf)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
                cellAlignments: {0: pw.Alignment.center},
                headers: ['Personel', 'Kısım Amiri', 'Yönetici/Üst Yönetici'],
                data: [
                  [' ', ' ', ' '],
                  [' ', ' ', ' '],
                  ['İmza', ' ', ' '],
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Not 2: Aşağıda yazılı mazeret izinleri dışındaki izinler ücretsiz olarak kullandırılacaktır. Bu tür izinlerin verilmesi işverenin yetkisi dahilindedir.', style: pw.TextStyle(font: ttf)),
              pw.Bullet(text: 'Evlilik (3 Güne kadar belgelendirilecek)', style: pw.TextStyle(font: ttf)),
              pw.Bullet(text: 'Eşinin, çocuğunun, anne, baba ve kardeşlerinin ölümü (3 Güne kadar belgelendirilecek)', style: pw.TextStyle(font: ttf)),
              pw.Bullet(text: 'Eşinin doğum yapması (5 Güne kadar belgelendirilecek)', style: pw.TextStyle(font: ttf)),
              pw.Bullet(text: 'Çocuğunun evlenmesi (1 Güne kadar belgelendirilecek)', style: pw.TextStyle(font: ttf)),
              pw.Bullet(text: 'Ev değiştirilmesi (1 Güne kadar belgelendirilecek)', style: pw.TextStyle(font: ttf)),
              pw.Bullet(text: 'Hastalık (3 Güne kadar belgelendirilecek)', style: pw.TextStyle(font: ttf)),
            ],
          ),
        ),
      );

      // Save the PDF file
      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF başarıyla oluşturuldu!')),
      );

      // Open the PDF file
     final result = await OpenFile.open(file.path);
     if (result != 'done') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF açılamadı: $result')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF oluşturulamadı: $e')),
      );
    }
  }
}
