import 'package:deneme/ArgeTakip/widget/arge.dart';
import 'package:deneme/IstasyonTakip/istasyonTakip.dart';
import 'package:deneme/TeknikTakip/teknikTakip.dart';
import 'package:deneme/UretimTakip/uretimtakip.dart';
import 'package:deneme/UrunTakip/uruntakip.dart';
import 'package:deneme/authentication/hesapislem.dart';
import 'package:deneme/personelTakip/widgets/personeltakip.dart';
import 'package:deneme/ArgeTakip/widget/arge.dart';
import 'package:deneme/IstasyonTakip/istasyonTakip.dart';
import 'package:flutter/material.dart';


class CardBaloncugu extends StatelessWidget {
  final String imageUrl;
  final String description;
  final String username;

  // Sayfaların adlarını saklamak için bir dizi oluştur
  final List<String> pageNames = ['PersonelTracker', 'UrunTracker',];

  CardBaloncugu({required this.imageUrl, required this.description, required this.username});
  
 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 3,
        child: InkWell(
          onTap: () {
            // İlgili sayfaya gitmek için index'i kullan
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                if (description == 'Personel') {
                  return PersonelTracker(username: username,);
                } else if (description == 'Ürün') {
                  return ProductTracker();
                }  else if (description == 'Üretim'){
                  return ProductionTrackingWidget(username: username,);
                } else if (description == 'İstasyonlar'){
                  return StationWidget();
                } else if (description == 'Teknik Servis'){
                  return TechnicalSupportWidget();
                } else if (description == 'Arge'){
                  return ArgeTrack();
                } else if (description == 'Hesap') {
                  return HesapIslemScreen();
                }
                // Diğer sayfalar için gerektiği kadar else if ekleyebilirsin
                return Container(); // Varsayılan olarak bir boş sayfa döndür
              },
            ));
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  description,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
