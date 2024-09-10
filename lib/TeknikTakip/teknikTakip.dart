import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class TechnicalSupportWidget extends StatefulWidget {
  @override
  _TechnicalSupportWidgetState createState() => _TechnicalSupportWidgetState();
}

class _TechnicalSupportWidgetState extends State<TechnicalSupportWidget> {
  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> malfunctions = [];
  bool isLoading = true;
  bool showMalfunctions = false;
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loginAndFetchStations();
  }

  Future<void> _loginAndFetchStations() async {
    try {
      // Login request
      final loginResponse = await http.post(
        Uri.parse('https://app.tridenstechnology.com/auth/realms/magicline_sarj/protocol/openid-connect/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'client_id': 'web',
          'username': 'aykansaridogan@magiclinesarj.com',
          'password': '4334KutahyA,,',
        }.map((key, value) => MapEntry(key, value.toString())),
      );

      if (loginResponse.statusCode == 200) {
        final loginData = jsonDecode(loginResponse.body);
        authToken = loginData['access_token']; // Get the token from the response

        // Fetch infrastructure data
        final infrastructureResponse = await http.get(
          Uri.parse('https://magicline-sarj.tridenstechnology.com/api/v1/roaming-platforms/magicline-sarj/stations?page=1&count=1000&list=https://magicline-sarj.tridenstechnology.com/ev-charge/stations/list'),
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        );

        if (infrastructureResponse.statusCode == 200) {
          final List<dynamic> data = jsonDecode(infrastructureResponse.body);
          print('Infrastructure Response Body: ${infrastructureResponse.body}');
          setState(() {
            stations = data.where((station) {
              return station['operational_status'] == 'Inoperative';
            }).map((station) {
              return {
                'name': station['name'] ?? 'Bilinmeyen İstasyon',
                'status': station['operational_status'] ?? 'Bilinmiyor',
                'reportDate': DateTime.now().toString(),
              };
            }).toList();
            isLoading = false;
          });
        } else {
          print('Error: ${infrastructureResponse.statusCode}');
          print('Response Body: ${infrastructureResponse.body}');
          throw Exception('Failed to load infrastructure data');
        }
      } else {
        print('Error: ${loginResponse.statusCode}');
        print('Response Body: ${loginResponse.body}');
        throw Exception('Failed to login');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMalfunctionsFromExcel() async {
    final ByteData data = await rootBundle.load('../assets/ulasimnumaralari.xlsx');
    final List<int> bytes = data.buffer.asUint8List();
    final Excel excel = Excel.decodeBytes(bytes);

    List<Map<String, dynamic>> loadedMalfunctions = [];
    for (var table in excel.tables.keys) {
      print(table); // sheet Name
      for (var row in excel.tables[table]!.rows) {
        if (row.isNotEmpty) {
          loadedMalfunctions.add({
            'station': row[0] ?? 'Bilinmeyen İstasyon',
            'malfunctionNumber': row[1] ?? 'Bilinmiyor',
          });
        }
      }
    }

    setState(() {
      malfunctions = loadedMalfunctions;
      showMalfunctions = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teknik Destek'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Teknik Destek Paneli',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadMalfunctionsFromExcel,
              child: Text('İstasyon Arıza Numaraları'),
            ),
            SizedBox(height: 20),
            if (showMalfunctions)
              _buildMalfunctionTable(),
            SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              _buildStationTable(),
            SizedBox(height: 20),
            _buildFeedbackForm(context),
            SizedBox(height: 20),
            _buildNotificationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStationTable() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Çalışmayan İstasyonlar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 10),
            DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('İstasyon Adı')),
                DataColumn(label: Text('Durum')),
                DataColumn(label: Text('Rapor Tarihi')),
              ],
              rows: stations.map((station) {
                return DataRow(cells: <DataCell>[
                  DataCell(Text(station['name'])),
                  DataCell(Text(station['status'])),
                  DataCell(Text(station['reportDate'])),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMalfunctionTable() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'İstasyon Arıza Numaraları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 10),
            DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('İstasyon Adı')),
                DataColumn(label: Text('Arıza Numarası')),
              ],
              rows: malfunctions.map((malfunction) {
                return DataRow(cells: <DataCell>[
                  DataCell(Text(malfunction['station'])),
                  DataCell(Text(malfunction['malfunctionNumber'])),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackForm(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Geri Bildirim Formu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Adınız',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Mesajınız',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Geri Bildirim Gönderildi'),
                      content: Text('Geri bildiriminiz başarıyla gönderildi. Teşekkürler!'),
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
              },
              child: Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Bildirimler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 10),
            _buildNotificationTile('Çalışmayan İstasyonlar', 'İstasyon A ve B çalışmıyor.'),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(String title, String message) {
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message),
      tileColor: Colors.grey[200],
    );
  }
}
