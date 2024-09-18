import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class UpcomingBirthdays extends StatefulWidget {
  @override
  _UpcomingBirthdaysState createState() => _UpcomingBirthdaysState();
}

class _UpcomingBirthdaysState extends State<UpcomingBirthdays> {
  List<Map<String, dynamic>> upcomingBirthdays = [];

  @override
  void initState() {
    super.initState();
    fetchUpcomingBirthdays();
  }

  Future<void> fetchUpcomingBirthdays() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/upcoming-birthdays'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          upcomingBirthdays = data.map((person) {
            return {
              'name': person['name'] ?? '', // Null değer kontrolü
              'dogumtarihi': person['dgtarih'] != null ? DateTime.parse(person['dgtarih']) : null, // Null değer kontrolü
            };
          }).toList();

          // Yaklaşan doğum günlerini gün bazında sırala
          upcomingBirthdays.sort((a, b) {
            DateTime? dateA = a['dogumtarihi'];
            DateTime? dateB = b['dogumtarihi'];
            if (dateA == null || dateB == null) return 0;
            int daysLeftA = calculateDaysLeft(dateA);
            int daysLeftB = calculateDaysLeft(dateB);
            return daysLeftA - daysLeftB;
          });
        });
      } else {
        throw Exception('Failed to load upcoming birthdays');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  int calculateDaysLeft(DateTime? birthday) {
    if (birthday == null) return 0;

    DateTime now = DateTime.now();
    DateTime nextBirthday = DateTime(now.year, birthday.month, birthday.day);
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }
    return nextBirthday.difference(now).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: upcomingBirthdays.length,
      itemBuilder: (context, index) {
        int daysLeft = calculateDaysLeft(upcomingBirthdays[index]['dogumtarihi']);
        return Card(
          child: ListTile(
            leading: Image.network(
              'https://media.tenor.com/btmyl_V4L4gAAAAi/birthday-bday.gif',
              width: 50.0,
              height: 50.0,
            ),
            title: Text(upcomingBirthdays[index]['name']),
            subtitle: Text(upcomingBirthdays[index]['dogumtarihi'] != null
                ? DateFormat('dd/MM/yyyy').format(upcomingBirthdays[index]['dogumtarihi']!)
                : 'Unknown Date'), // Null kontrolü
            trailing: Text('$daysLeft gün kaldı', style: TextStyle(color: Colors.red)),
          ),
        );
      },
    );
  }
}
