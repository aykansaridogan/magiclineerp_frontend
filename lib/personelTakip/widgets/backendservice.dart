import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendService {
  static const String baseUrl = 'http://2a07-159-146-53-63.ngrok-free.app';

  static Future<void> saveGiris(String formattedDate, String kullaniciadi, String girisSaati) async {
    final response = await http.post(
      Uri.parse('$baseUrl/saveGiris'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'formattedDate': formattedDate,
        'kullaniciadi': kullaniciadi,
        'girisSaati': girisSaati,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Giriş saati kaydedilemedi.');
    }
  }

  static Future<void> saveCikis(String formattedDate, String kullaniciadi, String cikisSaati) async {
    final response = await http.post(
      Uri.parse('$baseUrl/saveCikis'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'formattedDate': formattedDate,
        'kullaniciadi': kullaniciadi,
        'cikisSaati': cikisSaati,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Çıkış saati kaydedilemedi.');
    }
  }
}
