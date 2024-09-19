import 'dart:convert';
import 'package:MagicERP/homeappbar.dart';
import 'package:MagicERP/utils/button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlamak için
import 'package:http/http.dart' as http;

class HomePageScreen extends StatelessWidget {
  final String username;
  List<Map<String, String>> cardInfoList = [
      {
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpctgvrl2drOxNM-h04eFvD32tUhl08GrrLg&s',
        'description': 'Personel',
      },
      {
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ0UaRcB77QCaV8itm2Zs_bhJv7ccLKozn-w6ut9KkNig&s',
        'description': 'Ürün',
      },
    
      {
        'imageUrl':
            'https://e7.pngegg.com/pngimages/830/840/png-clipart-assembly-line-production-line-manufacturing-computer-icons-factory-production-miscellaneous-material-thumbnail.png',
        'description': 'Üretim',
      },
      {
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDzlzFHoaORHjnvNftWLS3NRG_JVioHmgnHA&s',
        'description': 'Arge',
      },
      {
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS2CdXwoDNhXOReLMzxnpGtATc8Sw0vWyuI1Q&s',
        'description': 'Teknik Servis',
      },
      {
        'imageUrl':
            'https://cdn-icons-png.flaticon.com/512/9138/9138046.png',
        'description': 'İstasyonlar',
      },
      {
        'imageUrl':
            'https://w7.pngwing.com/pngs/853/413/png-transparent-sign-up-account-sign-in-login-user-register-3d-icon-thumbnail.png',
        'description': 'Hesap',
      },
      
      // Diğer kart baloncuklarını da buraya ekleyebilirsiniz
    ];
  HomePageScreen({Key? key, required this.username}) : super(key: key);

  // Tarih formatını parse eden bir fonksiyon
  String? parseDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr); // ISO 8601 formatında tarihi parse ediyoruz
      return DateFormat('d MMMM y', 'tr_TR').format(date);
    } catch (e) {
      print('Invalid date format for $dateStr: $e');
      return null;
    }
  }

  // Backend API'den bu ay doğan kişileri çekmek için bir fonksiyon
  Future<List<Map<String, dynamic>>> fetchPeopleBornThisMonth() async {
    final response = await http.get(Uri.parse('http://localhost:3000/upcoming-birthdays'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      DateTime now = DateTime.now();
      int currentMonth = now.month;

      // Bu ay doğan kişileri filtreleyelim
      List<Map<String, dynamic>> peopleBornThisMonth = jsonResponse.where((person) {
        try {
          DateTime birthday = DateTime.parse(person['dgtarih']);
          return birthday.month == currentMonth; // Yılı kontrol etmiyoruz
        } catch (e) {
          print('Invalid date format for ${person['name']}: ${person['dgtarih']}');
          return false;
        }
      }).map((person) => {
        'name': person['name'],
        'birthday': person['dgtarih'],
      }).toList();

      return peopleBornThisMonth;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Kart baloncuklarının dizilimini oluşturalım
    List<Widget> cardWidgets = cardInfoList.map((cardInfo) {
      return CardBaloncugu(
        imageUrl: cardInfo['imageUrl']!,
        description: cardInfo['description']!,
        username: username,
      );
    }).toList();

    // Ekran genişliğine göre kartları 4'lü veya daha küçük gruplara ayır
    int cardsPerRow = screenWidth > 800 ? 4 : screenWidth > 600 ? 3 : 2;

    // Kart baloncuklarını sırayla gruplara ayıralım
    List<Widget> rows = [];
    for (int i = 0; i < cardWidgets.length; i += cardsPerRow) {
      List<Widget> rowChildren = [];
      for (int j = i; j < i + cardsPerRow && j < cardWidgets.length; j++) {
        rowChildren.add(Expanded(child: cardWidgets[j]));
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowChildren,
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          HomeAppBar(username: username),
          Expanded(
            child: SingleChildScrollView( // Ana içeriği kaydırılabilir hale getirdik
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: screenWidth > 1000
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kart baloncukları bölümü
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                ...rows,
                              ],
                            ),
                          ),
                          // Ay Doğanlar bölümü sağda görünür
                          Expanded(
                            flex: 1,
                            child: birthdaySection(context),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          // Mobil ve küçük ekranlarda üst üste göster
                          Column(
                            children: [
                              ...rows,
                            ],
                          ),
                          SizedBox(height: 20),
                          // Ay Doğanlar bölümü aşağıda görünür
                          birthdaySection(context),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ay Doğanlar bölümü
  Widget birthdaySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bu Ay Doğanlar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchPeopleBornThisMonth(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Veriler yüklenirken hata oluştu: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('Bu ay doğan kimse yok.');
              } else {
                final peopleBornThisMonth = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      for (var person in peopleBornThisMonth)
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(person['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                              // Doğum tarihini istenen formatta gösterelim
                              Text(parseDate(person['birthday']!) ?? 'Geçersiz tarih formatı'),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
