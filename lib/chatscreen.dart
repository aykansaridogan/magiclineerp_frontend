import 'dart:convert';
import 'dart:async';
import 'package:MagicERP/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String username;

  const ChatScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _baseUrl = 'http://localhost:3000'; // Backend URL

  final Map<String, List<Map<String, String>>> _conversations = {};
  String _selectedUser = '';
  List<String> _usernames = [];

  @override
  void initState() {
    super.initState();
    _loadUsernames();
    _startPolling();
  }

  void _startPolling() {
    Timer.periodic(
      Duration(seconds: 5),
      (Timer timer) {
        if (_selectedUser.isNotEmpty) {
          _loadConversations();
        }
      },
    );
  }

  Future<void> _loadConversations() async {
    if (_selectedUser.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/messages/${widget.username}/${_selectedUser}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = jsonDecode(response.body);

        setState(() {
          _conversations[_selectedUser] = messages
              .map((msg) {
                if (msg is Map<String, dynamic>) {
                  return {
                    'user': msg['sender']?.toString() ?? '',
                    'message': msg['message']?.toString() ?? '',
                    'timestamp': formatDate(msg['timestamp']),
                    'status': msg['status']?.toString() ?? 'unread',
                  };
                }
                return {
                  'user': '',
                  'message': '',
                  'timestamp': '',
                  'status': 'unread',
                };
              })
              .cast<Map<String, String>>()
              .toList();
        });

        // Mark messages as read
        await _markMessagesAsRead();
      } else {
        print('Mesajlar yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Mesajlar yüklenirken hata oluştu: $e');
    }
  }

  Future<void> _markMessagesAsRead() async {
    if (_selectedUser.isEmpty) return;

    try {
      final response = await http.put(
        Uri.parse(
          '$_baseUrl/messages/${widget.username}/${_selectedUser}/markAsRead',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _conversations[_selectedUser]?.forEach((message) {
            message['status'] = 'read';
          });
        });
      } else {
        print('Mesajlar okundu olarak işaretlenirken hata oluştu: ${response.body}');
      }
    } catch (e) {
      print('Mesajlar okundu olarak işaretlenirken hata oluştu: $e');
    }
  }

  Future<void> _loadUsernames() async {
    final response = await http.get(Uri.parse('$_baseUrl/users'));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> users = jsonDecode(response.body);
        setState(() {
          _usernames = users
              .map((user) => (user['kullanicadi'] as String?) ?? '')
              .where((username) => username.isNotEmpty && username != widget.username)
              .toList();
        });
      } catch (e) {
        print('Kullanıcılar yüklenirken hata oluştu: $e');
      }
    } else {
      print('Kullanıcılar yüklenemedi: ${response.body}');
    }
  }

  void _sendMessage(String message) async {
    if (message.isEmpty || _selectedUser.isEmpty) return;

    final response = await http.post(
      Uri.parse('$_baseUrl/msg2'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender': widget.username,
        'recipient': _selectedUser,
        'message': message,
        'status': 'unread',
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        if (_conversations[_selectedUser] == null) {
          _conversations[_selectedUser] = [];
        }
        _conversations[_selectedUser]?.add({
          'user': widget.username,
          'message': message,
          'timestamp': formatDate(DateTime.now().toIso8601String()),
          'status': 'unread',
        });
      });
      _controller.clear();
      _scrollToBottom();

      // Anlık güncelleme için mesajları yeniden yükleyin
      await _loadConversations();
    } else {
      print('Mesaj gönderilirken hata oluştu: ${response.body}');
    }
  }

  String formatDate(String isoDateString) {
    try {
      final date = DateTime.parse(isoDateString);
      final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
      return formatter.format(date);
    } catch (e) {
      print('Tarih formatlama hatası: $e');
      return isoDateString;
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
    final screenWidth = MediaQuery.of(context).size.width; // Ekran genişliği
    final screenHeight = MediaQuery.of(context).size.height; // Ekran yüksekliği

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Mesajlaşma',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePageScreen(username: widget.username),
              ),
            ); // HomePageScreen'e yönlendir
          },
        ),
      ),
      body: Row(
        children: [
          // Sol kısım: Kullanıcı listesi
          Expanded(
            flex: screenWidth > 600 ? 1 : 2, // Ekran genişliğine göre flex ayarı
            child: Container(
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: _usernames.length,
                itemBuilder: (context, index) {
                  String user = _usernames[index];
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
            flex: screenWidth > 600 ? 3 : 4, // Daha geniş ekranlarda daha fazla yer kapla
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _conversations[_selectedUser]?.length ?? 0,
                    itemBuilder: (context, index) {
                      final message = _conversations[_selectedUser]?[index];
                      bool isMe = message?['user'] == widget.username;
                      bool isUnread = message?['status'] == 'unread';
                      return ListTile(
                        title: Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01, // Ekran boyutuna göre padding
                              horizontal: screenWidth * 0.04, // Ekran genişliğine göre padding
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.teal
                                  : (isUnread
                                      ? Colors.red[100]
                                      : Colors.grey[300]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message?['message'] ?? '',
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                    fontStyle: isMe
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    fontSize: screenWidth * 0.04, // Responsive font size
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message?['timestamp'] ?? '',
                                  style: TextStyle(
                                    color: isMe ? Colors.white70 : Colors.black54,
                                    fontSize: screenWidth * 0.03, // Responsive font size
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02), // Responsive padding
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Mesajınızı yazın...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          _sendMessage(_controller.text);
                        },
                      ),
                    ],
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
