import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class GirisCikis extends StatefulWidget {
  final String username;

  GirisCikis({required this.username});

  @override
  _GirisCikisState createState() => _GirisCikisState();
}

class _GirisCikisState extends State<GirisCikis> {
  late DateTime _currentDate;
  late String _formattedDate;
  late bool _isGirisSigned;
  late bool _isCikisSigned;
  late String? _girisSaati;
  late String? _cikisSaati;

  final DateTime _minDate = DateTime.now().subtract(Duration(days: 30)); // Example: 30 days ago
  final DateTime _maxDate = DateTime.now().add(Duration(days: 30)); // Example: 30 days from now

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _formattedDate = _formatDate(_currentDate);
    _loadSignatures();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadSignatures() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGirisSigned = prefs.getBool('$_formattedDate-Giris-${widget.username}') ?? false;
      _isCikisSigned = prefs.getBool('$_formattedDate-Cikis-${widget.username}') ?? false;
      _girisSaati = prefs.getString('$_formattedDate-GirisSaati-${widget.username}');
      _cikisSaati = prefs.getString('$_formattedDate-CikisSaati-${widget.username}');
    });
  }

  Future<void> _saveSignatures() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_formattedDate-Giris-${widget.username}', _isGirisSigned);
    await prefs.setBool('$_formattedDate-Cikis-${widget.username}', _isCikisSigned);
    await prefs.setString('$_formattedDate-GirisSaati-${widget.username}', _girisSaati ?? '');
    await prefs.setString('$_formattedDate-CikisSaati-${widget.username}', _cikisSaati ?? '');
  }

  bool _isWithinGirisTime(DateTime now) {
    final startTime = DateTime(now.year, now.month, now.day, 08, 0);
    final endTime = DateTime(now.year, now.month, now.day, 09, 15);
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool _isWithinCikisTime(DateTime now) {
    final startTime = DateTime(now.year, now.month, now.day, 17, 45);
    final endTime = DateTime(now.year, now.month, now.day, 18, 0);
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  Future<void> _handleGirisSignature(bool? value) async {
    if (value == null || _isGirisSigned) return;

    DateTime now = DateTime.now();
    if (!_isWithinGirisTime(now)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Giriş imzası yalnızca 08:00 - 09:15 arasında yapılabilir.'),
      ));
      return;
    }

    final response = await _saveGirisToBackend(now);

    if (response != null && response.statusCode == 200) {
      setState(() {
        _isGirisSigned = value;
        _girisSaati = now.toIso8601String().split('T')[1].split('.')[0];
        _saveSignatures();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Giriş saati kaydedilemedi: ${response?.body ?? 'Bilinmeyen hata'}'),
      ));
    }
  }

  Future<void> _handleCikisSignature(bool? value) async {
    if (value == null || _isCikisSigned) return;

    DateTime now = DateTime.now();
    if (!_isWithinCikisTime(now)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Çıkış imzası yalnızca 14:00 - 18:00 arasında yapılabilir.'),
      ));
      return;
    }

    final response = await _saveCikisToBackend(now);

    if (response != null && response.statusCode == 200) {
      setState(() {
        _isCikisSigned = value;
        _cikisSaati = now.toIso8601String().split('T')[1].split('.')[0];
        _saveSignatures();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Çıkış saati kaydedilemedi: ${response?.body ?? 'Bilinmeyen hata'}'),
      ));
    }
  }

  Future<http.Response?> _saveGirisToBackend(DateTime now) async {
    try {
      final response = await http.post(
        Uri.parse('https://2a07-159-146-53-63.ngrok-free.app/saveGiris'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'formattedDate': _formattedDate,
          'kullaniciadi': widget.username,
          'girisSaati': now.toIso8601String().split('T')[1].split('.')[0],
        }),
      );
      return response;
    } catch (e) {
      print('Giriş kaydı gönderim hatası: $e');
      return null;
    }
  }

  Future<http.Response?> _saveCikisToBackend(DateTime now) async {
    try {
      final response = await http.post(
        Uri.parse('https://2a07-159-146-53-63.ngrok-free.app/saveCikis'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'formattedDate': _formattedDate,
          'kullaniciadi': widget.username,
          'cikisSaati': now.toIso8601String().split('T')[1].split('.')[0],
        }),
      );
      return response;
    } catch (e) {
      print('Çıkış kaydı gönderim hatası: $e');
      return null;
    }
  }

  Future<void> _showAttendanceHistory() async {
    // Show a loading indicator or similar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Veriler Yükleniyor'),
          content: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Make the API request to fetch attendance data
      final response = await http.get(Uri.parse('http://2a07-159-146-53-63.ngrok-free.app/getAttendance/$_formattedDate'));

      if (response.statusCode == 200) {
        // Parse the JSON data from the response
        final List<dynamic> data = jsonDecode(response.body);

        Navigator.pop(context); // Close the loading dialog

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Giriş/Çıkış Geçmişi'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.map((entry) {
                    // Create a widget for each entry
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Kullanıcı: ${entry['kullaniciadi']}, Giriş: ${entry['giris_saati'] ?? '---'}, Çıkış: ${entry['cikis_saati'] ?? '---'}',
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Close the dialog
                  child: Text('Kapat'),
                ),
              ],
            );
          },
        );
      } else {
        Navigator.pop(context); // Close the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Veriler alınamadı.'),
        ));
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Bir hata oluştu: $e'),
      ));
    }
  }

  void _previousDay() {
    if (_currentDate.isAfter(_minDate)) {
      setState(() {
        _currentDate = _currentDate.subtract(Duration(days: 1));
        _formattedDate = _formatDate(_currentDate);
        _loadSignatures();
      });
    }
  }

  void _nextDay() {
    if (_currentDate.isBefore(_maxDate)) {
      setState(() {
        _currentDate = _currentDate.add(Duration(days: 1));
        _formattedDate = _formatDate(_currentDate);
        _loadSignatures();
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Giriş/Çıkış'),
      automaticallyImplyLeading: false, // Removes the back button

    ),
    body: Column(
      children: [
        // Date Display without Navigation Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formattedDate,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
       if (widget.username == 'aykansr' || widget.username == 'ferdanedonmez')
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _showAttendanceHistory,
                icon: Icon(Icons.history),
                label: Text('Giriş/Çıkış Geçmişi'),
              ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: _isGirisSigned,
              onChanged: _handleGirisSignature,
            ),
            Text('Giriş'),
            SizedBox(width: 20),
            Checkbox(
              value: _isCikisSigned,
              onChanged: _handleCikisSignature,
            ),
            Text('Çıkış'),
          ],
        ),
      ],
    ),
  );
}
}
