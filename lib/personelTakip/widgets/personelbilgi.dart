import 'package:MagicERP/personelTakip/widgets/personeldetay.dart';
import 'package:MagicERP/personelTakip/widgets/personelekle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonelInfoWidget extends StatefulWidget {
  final String username;

  PersonelInfoWidget({required this.username});

  @override
  _PersonelInfoWidgetState createState() => _PersonelInfoWidgetState();
}

class _PersonelInfoWidgetState extends State<PersonelInfoWidget> {
  List<String> personelListesi = [];
  List<bool> selectedPersonel = [];

  @override
  void initState() {
    super.initState();
    _fetchPersonelNames();
  }

  Future<void> _fetchPersonelNames() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/personelnames'),
      );
      if (response.statusCode == 200) {
        final List<dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          setState(() {
            personelListesi = List<String>.from(data);
            selectedPersonel = List<bool>.filled(personelListesi.length, false);
          });
        }
      } else {
        _showMessage('Error fetching personnel names: ${response.statusCode}');
      }
    } catch (error) {
      _showMessage('Error fetching personnel names: $error');
    }
  }

  void _addPersonelToList(String name) {
    setState(() {
      personelListesi.add(name);
      selectedPersonel.add(false);
    });
  }

  Future<void> _removePersonel(int index) async {
    final String name = personelListesi[index];
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/removepersonel/$name'),
      );
      if (response.statusCode == 200) {
        setState(() {
          personelListesi.removeAt(index);
          selectedPersonel.removeAt(index);
        });
        _showMessage('Personnel successfully removed.');
      } else {
        _showMessage('Error removing personnel: ${response.statusCode}');
      }
    } catch (error) {
      _showMessage('Error removing personnel: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool get canModify => widget.username == 'ferdanedonmez' || widget.username == 'aykansr';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personel Bilgileri'),
        backgroundColor: Colors.teal,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: isMobile
                      ? ListView.builder(
                          itemCount: personelListesi.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(personelListesi[index]),
                              onTap: canModify
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PersonDetailsWidget(
                                            personName: personelListesi[index],
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              trailing: canModify
                                  ? Checkbox(
                                      value: selectedPersonel[index],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedPersonel[index] = value ?? false;
                                        });
                                      },
                                    )
                                  : null,
                            );
                          },
                        )
                      : Row(
                          children: [
                            // Sol panel: Kullanıcı listesi
                            Expanded(
                              flex: 2,
                              child: ListView.builder(
                                itemCount: personelListesi.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(personelListesi[index]),
                                    onTap: canModify
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PersonDetailsWidget(
                                                  personName: personelListesi[index],
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                    trailing: canModify
                                        ? Checkbox(
                                            value: selectedPersonel[index],
                                            onChanged: (value) {
                                              setState(() {
                                                selectedPersonel[index] = value ?? false;
                                              });
                                            },
                                          )
                                        : null,
                                  );
                                },
                              ),
                            ),
                            // Sağ panel: Seçim ve butonlar
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  if (canModify) ...[
                                    ElevatedButton(
                                      onPressed: () async {
                                        final result = await showDialog<String>(
                                          context: context,
                                          builder: (context) => PersonelEklePopup(),
                                        );
                                        if (result != null && result.isNotEmpty) {
                                          _addPersonelToList(result);
                                        }
                                      },
                                      child: Text('Personel Ekle'),
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: _confirmDelete,
                                      child: Text('Seçilenleri Sil'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete the selected personnel?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              for (int i = personelListesi.length - 1; i >= 0; i--) {
                if (selectedPersonel[i]) {
                  _removePersonel(i);
                }
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
