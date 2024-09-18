import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserInfoScreen extends StatefulWidget {
  final String username;

  const UserInfoScreen({Key? key, required this.username}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late Future<String?> _userName;

  @override
  void initState() {
    super.initState();
    _userName = _fetchUserName();
  }

  Future<String?> _fetchUserName() async {
    final response = await http.get(Uri.parse('http://192.168.1.71:3000/userinfo?kullaniciadi=${widget.username}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name'] as String?;
    } else {
      throw Exception('Kullanıcı adı alınamadı');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcı Bilgisi'),
      ),
      body: FutureBuilder<String?>(
        future: _userName,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Kullanıcı adı alınamadı: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Kullanıcı adı bulunamadı'));
          } else {
            return Center(child: Text('Kullanıcı Adı: ${snapshot.data}'));
          }
        },
      ),
    );
  }
}
