import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HesapIslemScreen extends StatefulWidget {
  const HesapIslemScreen({Key? key}) : super(key: key);

  @override
  State<HesapIslemScreen> createState() => _HesapIslemScreenState();
}

class _HesapIslemScreenState extends State<HesapIslemScreen> {
  final kullaniciAdiController = TextEditingController();
  final mevcutSifreController = TextEditingController();
  final yeniSifreController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    kullaniciAdiController.dispose();
    mevcutSifreController.dispose(); // Dispose metodu güncellendi
    yeniSifreController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Değişiklikler kaydedilecek'),
          content: Text('Emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hayır'),
            ),
            TextButton(
              onPressed: () {
                _saveChanges();
                Navigator.of(context).pop();
              },
              child: Text('Evet'),
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() async {
  final uri = Uri.parse('https://2a07-159-146-53-63.ngrok-free.app/changepassword');
  final response = await http.post(
    uri,
    body: {
      'kullaniciadi': kullaniciAdiController.text,
      'sifre': mevcutSifreController.text, // mevcut şifre için mevcutSifreController
      'yeniSifre': yeniSifreController.text,
    },
  );

  final scaffoldMessenger = ScaffoldMessenger.of(context);
  if (response.statusCode == 200) {
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text('Şifre başarıyla değiştirildi')),
    );
  } else {
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text('Hata: Şifre değiştirilemedi. ${response.body}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hesap İşlemleri'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: kullaniciAdiController,
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kullanıcı adı gereklidir';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: mevcutSifreController, // Mevcut şifre için controller
                decoration: InputDecoration(
                  labelText: 'Mevcut Şifre',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mevcut şifre gereklidir';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: yeniSifreController,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Yeni şifre gereklidir';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    _showConfirmationDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text('Değişiklikleri Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
