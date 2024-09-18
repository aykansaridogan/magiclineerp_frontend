import 'package:MagiclineERP/UretimTakip/modals/location.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductionTrackingWidget extends StatefulWidget {
  final String username;

  ProductionTrackingWidget({Key? key, required this.username}) : super(key: key);

  @override
  _ProductionTrackingWidgetState createState() => _ProductionTrackingWidgetState();
}

class _ProductionTrackingWidgetState extends State<ProductionTrackingWidget> {
  late String currentUsername;
  List<Location> locations = [];

  @override
  void initState() {
    super.initState();
    currentUsername = widget.username;
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('https://localhost:3000/locations'));

      if (response.statusCode == 200) {
        final List<dynamic> locationData = jsonDecode(response.body);
        setState(() {
          locations = locationData.map((data) {
            return Location.fromJson(data);
          }).toList();
        });
      } else {
        throw Exception('Failed to load locations. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  Future<void> _addLocation(String name) async {
    try {
      final response = await http.post(
        Uri.parse('https://localhost:3000/locations'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        final newLocation = Location.fromJson(jsonDecode(response.body));
        setState(() {
          locations.add(newLocation);
        });
      } else {
        throw Exception('Failed to add location');
      }
    } catch (e) {
      print('Error adding location: $e');
    }
  }

  Future<void> _updateStage(int stageId, bool isCompleted) async {
    try {
      final response = await http.put(
        Uri.parse('https://localhost:3000/stages/$stageId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, bool>{
          'is_completed': isCompleted,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          final updatedStage = jsonDecode(response.body);
          for (var location in locations) {
            for (var stage in location.stages) {
              if (stage.id == stageId) {
                stage.isCompleted = updatedStage['is_completed'];
              }
            }
          }
        });
      } else {
        throw Exception('Failed to update stage');
      }
    } catch (e) {
      print('Error updating stage: $e');
    }
  }

  bool _canEditStage(String stageName) {
    if (stageName == 'Keşif' || stageName == 'Onay') {
      return currentUsername == 'alperates';
    } else if (stageName == 'Montaj' || stageName == 'Kurulum') {
      return currentUsername == 'fatihaydemir';
    } else if (stageName == 'AR-GE Kontrol') {
      return currentUsername == 'aykansr' || currentUsername == 'berataktas';
    }
    return false;
  }

  void _showAddLocationDialog(BuildContext context) {
    TextEditingController locationController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Yeni Konum Ekle'),
          content: TextField(
            controller: locationController,
            decoration: InputDecoration(labelText: 'Konum Adı'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if (locationController.text.isNotEmpty) {
                  _addLocation(locationController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Üretim Takip Sistemi'),
      ),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(locations[index].name),
            children: locations[index].stages.map((stage) {
              bool canEdit = _canEditStage(stage.name);
              return ListTile(
                title: Text(stage.name),
                trailing: canEdit
                    ? Checkbox(
                        value: stage.isCompleted,
                        onChanged: (value) {
                          _updateStage(stage.id, value ?? false);
                        },
                      )
                    : null,
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddLocationDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}



