import 'package:MagicERP/ArgeTakip/widget/arge.dart';
import 'package:MagicERP/IstasyonTakip/istasyonTakip.dart';
import 'package:MagicERP/TeknikTakip/teknikTakip.dart';
import 'package:MagicERP/UretimTakip/uretimtakip.dart';
import 'package:MagicERP/UrunTakip/uruntakip.dart';
import 'package:MagicERP/authentication/hesapislem.dart';
import 'package:MagicERP/personelTakip/widgets/personeltakip.dart';
import 'package:MagicERP/ArgeTakip/widget/arge.dart';
import 'package:MagicERP/IstasyonTakip/istasyonTakip.dart' as dsad;
import 'package:flutter/material.dart';

class CardBaloncugu extends StatelessWidget {
  final String imageUrl;
  final String description;
  final String username;

  CardBaloncugu({required this.imageUrl, required this.description, required this.username});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(left: 1.0, top: 4), // Padding'i iyice küçülttük
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0), // Köşe yarıçapını daha da küçülttük
        ),
        elevation: 1, // Minimal gölge verdik
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                if (description == 'Personel') {
                  return PersonelTracker(username: username);
                } else if (description == 'Ürün') {
                  return ProductTracker();
                } else if (description == 'Üretim') {
                  return ProductionTrackingWidget(username: username);
                } else if (description == 'İstasyonlar') {
                  return EnergyChart();
                } else if (description == 'Teknik Servis') {
                  return TechnicalSupportWidget();
                } else if (description == 'Arge') {
                  return ArgeTrack();
                } else if (description == 'Hesap') {
                  return HesapIslemScreen();
                }
                return Container();
              },
            ));
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6.0),
                  topRight: Radius.circular(6.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0), // Daha da küçük üst padding
                  child: Image.network(
                    imageUrl,
                    width: screenWidth * 0.12, // Resmi iyice küçülttük
                    height: screenWidth * 0.12, // Yüksekliği de küçüldü
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.015), // Küçük padding
                child: Text(
                  description,
                  style: TextStyle(fontSize: screenWidth * 0.025), // Daha küçük font boyutu
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
