import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewConversationScreen extends StatefulWidget {
  final String username;

  const NewConversationScreen({Key? key, required this.username}) : super(key: key);

  @override
  _NewConversationScreenState createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  late Future<List<String>> _usernames;
  String? _selectedUser;

  @override
  void initState() {
    super.initState();
    _usernames = _fetchUsernames();
  }

  Future<List<String>> _fetchUsernames() async {
    final response = await http.get(Uri.parse('http://192.168.1.71:3000/users'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item['username'] as String).toList();
    } else {
      throw Exception('Kullanıcılar yüklenemedi');
    }
  }

  Future<void> _startNewConversation() async {
    if (_selectedUser == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.71:3000/start-conversation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender': widget.username,
          'recipient': _selectedUser,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bu kişiyle zaten konuşma başlatılmış.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sohbet başlatılamadı: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Sohbet Başlat'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<String>>(
            future: _usernames,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Kullanıcılar yüklenemedi'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Kullanıcı bulunamadı'));
              } else {
                return Expanded(
                  child: ListView(
                    children: snapshot.data!.map((username) {
                      return ListTile(
                        title: Text(username),
                        trailing: _selectedUser == username
                            ? Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedUser = username;
                          });
                        },
                      );
                    }).toList(),
                  ),
                );
              }
            },
          ),
          ElevatedButton(
            onPressed: _startNewConversation,
            child: Text('Yeni Sohbet Başlat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }
}
