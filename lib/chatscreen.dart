import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String username;

  const ChatScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _baseUrl = 'http://localhost:3000';  // Backend URL

  final Map<String, List<Map<String, String>>> _conversations = {};
  String _selectedUser = '';
  List<String> _usernames = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _loadUsernames();
  }

  Future<void> _loadConversations() async {
    if (_selectedUser.isEmpty) return;

    final response = await http.get(Uri.parse('$_baseUrl/msg2/${widget.username}'));

    if (response.statusCode == 200) {
      final List<dynamic> messages = jsonDecode(response.body);
      setState(() {
        var msg2;
        _conversations[_selectedUser] = msg2.map((msg) {
          if (msg is Map<String, dynamic>) {
            return {
              'user': msg['sender'],
              'message': msg['message']
            };
          }
          return {'user': '', 'message': ''}; // Hatalı veri durumunda varsayılan değer
        }).toList();
      });
    } else {
      print('Mesajlar yüklenemedi: ${response.body}');
    }
  }

  Future<void> _loadUsernames() async {
    final response = await http.get(Uri.parse('$_baseUrl/users')); // Kullanıcıların listelendiği endpoint

    if (response.statusCode == 200) {
      final List<dynamic> users = jsonDecode(response.body);
      setState(() {
        _usernames = users.map((user) => user['username'] as String).toList();
      });
    } else {
      print('Kullanıcılar yüklenemedi: ${response.body}');
    }
  }

  Future<void> _startNewConversation(String recipient) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/start-conversation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender': widget.username,
          'recipient': recipient,
        }),
      );

      if (response.statusCode == 201) {
        print('Yeni sohbet başlatıldı.');
        Navigator.pop(context);  // Sohbet başlatıldığında geri dön
      } else if (response.statusCode == 400) {
        print('Bu kişiyle zaten konuşma başlatılmış.');
      } else {
        print('Sohbet başlatılamadı: ${response.body}');
      }
    } catch (e) {
      print('Yeni sohbet başlatılırken hata oluştu: $e');
    }
  }

  void _sendMessage(String message) async {
    if (message.isEmpty || _selectedUser.isEmpty) return;

    final response = await http.post(
      Uri.parse('$_baseUrl/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender': widget.username,
        'recipient': _selectedUser,
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _conversations[_selectedUser]?.add({'user': 'Me', 'message': message});
      });
      _controller.clear();
      _scrollToBottom();
    } else {
      print('Mesaj gönderilirken hata oluştu: ${response.body}');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Mesajlaşma',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Row(
        children: [
          // Sol kısım: Kullanıcı listesi
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: _conversations.keys.length,
                itemBuilder: (context, index) {
                  String user = _conversations.keys.elementAt(index);
                  return ListTile(
                    title: Text(
                      user,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedUser == user ? Colors.teal : Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedUser = user;
                      });
                      _loadConversations(); // Mesajları yükle
                    },
                    selected: _selectedUser == user,
                    selectedTileColor: Colors.teal[100],
                  );
                },
              ),
            ),
          ),
          // Sağ kısım: Seçili kullanıcının mesajları
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _conversations[_selectedUser]?.length ?? 0,
                    itemBuilder: (context, index) {
                      final message = _conversations[_selectedUser]?[index];
                      return ListTile(
                        title: Align(
                          alignment: message?['user'] == 'Me'
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: message?['user'] == 'Me'
                                  ? Colors.teal
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              message?['message'] ?? '',
                              style: TextStyle(
                                color: message?['user'] == 'Me'
                                    ? Colors.white
                                    : Colors.black,
                                fontStyle: message?['user'] == 'Me'
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: "Mesaj yaz",
                            labelStyle: TextStyle(color: Colors.teal),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.teal,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.teal),
                        onPressed: () {
                          String userMessage = _controller.text;
                          _sendMessage(userMessage);
                        },
                      ),
                    ],
                  ),
                ),
                // Yeni sohbet başlatma butonu
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final recipient = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Yeni Sohbet Başlat'),
                            content: DropdownButtonFormField<String>(
                              value: _usernames.isNotEmpty ? _usernames[0] : null,
                              items: _usernames.map((username) {
                                return DropdownMenuItem<String>(
                                  value: username,
                                  child: Text(username),
                                );
                              }).toList(),
                              onChanged: (value) {
                                Navigator.of(context).pop(value);
                              },
                              decoration: InputDecoration(
                                labelText: 'Kullanıcı Seçin',
                              ),
                            ),
                          );
                        },
                      );

                      if (recipient != null && recipient.isNotEmpty) {
                        _startNewConversation(recipient);
                      }
                    },
                    child: Text('Yeni Sohbet Başlat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
