import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonelEklePopup extends StatefulWidget {
  @override
  _PersonelEklePopupState createState() => _PersonelEklePopupState();
}

class _PersonelEklePopupState extends State<PersonelEklePopup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tcNoController = TextEditingController();
  final TextEditingController unvanController = TextEditingController();
  final TextEditingController sirketHattiController = TextEditingController(text: '+90');
  final TextEditingController kisiselHattiController = TextEditingController(text: '+90');
  final TextEditingController epostaController = TextEditingController();
  final TextEditingController adresController = TextEditingController();
  final TextEditingController dgTarihController = TextEditingController();
  final TextEditingController kullaniciadiController = TextEditingController(); 
  final TextEditingController sifreController = TextEditingController(); 

  Future<void> _addPersonel() async {
    // TC No'nun doğruluğunu kontrol et
    if (!RegExp(r'^\d{11}$').hasMatch(tcNoController.text)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('TC No 11 haneli olmalıdır ve sadece rakamlardan oluşmalıdır'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Şirket Hattı ve Kişisel Hat'ın formatını kontrol et
    if (!RegExp(r'^\+90\d{10}$').hasMatch(sirketHattiController.text) || !RegExp(r'^\+90\d{10}$').hasMatch(kisiselHattiController.text)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('Şirket Hattı ve Kişisel Hat +90 ile başlamalı ve 10 haneli olmalıdır'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
      return;
    }

    final response = await http.post(
      Uri.parse('https://2a07-159-146-53-63.ngrok-free.app/addpersonel'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameController.text,
        'tc_no': tcNoController.text,
        'unvan': unvanController.text,
        'sirketHatti': sirketHattiController.text,
        'kisiselHat': kisiselHattiController.text,
        'eposta': epostaController.text,
        'adres': adresController.text,
        'dgtarih': dgTarihController.text,
        'kullanicadi': kullaniciadiController.text, 
        'sifre': sifreController.text, 
      }),
    );

    if (response.statusCode == 200) {
      print('Personel başarıyla eklendi');
      Navigator.of(context).pop(nameController.text);
    } else {
      print('Personel ekleme hatası: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Personel Ekle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'İsim'),
            ),
            TextFormField(
              controller: tcNoController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              decoration: InputDecoration(labelText: 'TC No'),
            ),
            TextFormField(
              controller: unvanController,
              decoration: InputDecoration(labelText: 'Ünvan'),
            ),
            TextFormField(
              controller: sirketHattiController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Şirket Hattı'),
            ),
            TextFormField(
              controller: kisiselHattiController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Kişisel Hattı'),
            ),
            TextFormField(
              controller: epostaController,
              decoration: InputDecoration(labelText: 'Eposta'),
            ),
            TextFormField(
              controller: adresController,
              decoration: InputDecoration(labelText: 'Adres'),
            ),
            TextFormField(
              controller: dgTarihController,
              decoration: InputDecoration(labelText: 'Doğum Tarihi'),
            ),
            TextFormField(
              controller: kullaniciadiController,
              decoration: InputDecoration(labelText: 'Kullanıcı Adı'), 
            ),
            TextFormField(
              controller: sifreController,
              decoration: InputDecoration(labelText: 'Şifre'), 
              obscureText: true, 
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addPersonel();
              },
              child: Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
